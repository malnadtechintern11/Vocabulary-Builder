import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_tables.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../words/data/models/word_model.dart';
import '../../domain/entities/quiz_question.dart';
import '../models/quiz_result_model.dart';

/// Contract for Quiz local persistence and generation
abstract class QuizLocalDataSource {
  Future<List<QuizQuestion>> generateQuestions({
    required QuizType type,
    String? difficulty,
    int count = 10,
  });

  Future<QuizResultModel> saveQuizResult(QuizResultModel result);
  Future<List<QuizResultModel>> getQuizHistory();
  Future<Map<String, dynamic>> getQuizStatistics();
}

/// SQLite-backed implementation of QuizLocalDataSource
class QuizLocalDataSourceImpl implements QuizLocalDataSource {
  final AppDatabase databaseHelper;

  QuizLocalDataSourceImpl({AppDatabase? databaseHelper})
      : databaseHelper = databaseHelper ?? AppDatabase.instance;

  @override
  Future<List<QuizQuestion>> generateQuestions({
    required QuizType type,
    String? difficulty,
    int count = 10,
  }) async {
    try {
      final db = await databaseHelper.database;
      final whereClauses = <String>[];
      final whereArgs = <dynamic>[];

      if (difficulty != null && difficulty.isNotEmpty && difficulty != 'all') {
        whereClauses.add('${DatabaseTables.colDifficulty} = ?');
        whereArgs.add(difficulty.toLowerCase());
      }

      final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

      final results = await db.query(
        DatabaseTables.tableWords,
        where: whereString,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      );

      final allWords = results.map((row) => WordModel.fromDbMap(row)).toList();

      if (allWords.length < 4) {
        throw const ValidationException('Need at least 4 words in database to generate a quiz');
      }

      final random = Random();
      final pool = List<WordModel>.from(allWords)..shuffle(random);
      List<WordModel> selectedTargets;

      if (type == QuizType.weakWordsPractice) {
        final weakRows = await db.query(
          DatabaseTables.tableWordQuizStats,
          where: '${DatabaseTables.colStatsTimesIncorrect} > 0',
          orderBy: '${DatabaseTables.colStatsTimesIncorrect} DESC',
          limit: count,
        );
        final weakIds = weakRows.map((r) => r[DatabaseTables.colStatsWordId] as int).toSet();
        final weakTargetWords = allWords.where((w) => weakIds.contains(w.id)).toList()..shuffle(random);
        if (weakTargetWords.isNotEmpty) {
          final remainder = pool.where((w) => !weakIds.contains(w.id)).take(count - weakTargetWords.length);
          selectedTargets = [...weakTargetWords, ...remainder];
        } else {
          selectedTargets = pool.take(min(count, pool.length)).toList();
        }
      } else {
        selectedTargets = pool.take(min(count, pool.length)).toList();
      }

      final questions = <QuizQuestion>[];

      for (int i = 0; i < selectedTargets.length; i++) {
        final target = selectedTargets[i];
        final question = _buildQuestionForType(
          type: type,
          target: target,
          allWords: allWords,
          index: i,
          random: random,
        );
        if (question != null) {
          questions.add(question);
        }
      }

      return questions;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppDatabaseException('Failed to generate quiz questions: $e', e);
    }
  }

  QuizQuestion? _buildQuestionForType({
    required QuizType type,
    required WordModel target,
    required List<WordModel> allWords,
    required int index,
    required Random random,
  }) {
    switch (type) {
      case QuizType.meaningMatch:
        final otherWords = allWords.where((w) => w.id != target.id).toList()..shuffle(random);
        final distractorOptions = otherWords.take(3).map((w) => w.meaning).toList();
        final options = [target.meaning, ...distractorOptions]..shuffle(random);
        final correctIndex = options.indexOf(target.meaning);

        final knSuffix = target.kannadaMeaning.isNotEmpty ? ' (ಕನ್ನಡ: ${target.kannadaMeaning})' : '';
        return QuizQuestion(
          id: 'q_${index}_${target.id}',
          prompt: 'What is the correct meaning of "${target.word}"?',
          contextSnippet: target.phonetic.isNotEmpty ? 'Phonetic: ${target.phonetic} (${target.partOfSpeech})' : null,
          options: options,
          correctOptionIndex: correctIndex,
          explanation: '"${target.word}" (${target.partOfSpeech}) means: ${target.meaning}$knSuffix',
          type: type,
          targetWordId: target.id,
          targetWord: target.word,
        );

      case QuizType.synonymMatch:
        if (target.synonyms.isEmpty) {
          return _buildQuestionForType(
            type: QuizType.meaningMatch,
            target: target,
            allWords: allWords,
            index: index,
            random: random,
          );
        }
        final correctSynonym = target.synonyms[random.nextInt(target.synonyms.length)];
        final otherSynonyms = allWords
            .where((w) => w.id != target.id)
            .expand((w) => w.synonyms)
            .where((s) => !target.synonyms.contains(s))
            .toSet()
            .toList()
          ..shuffle(random);

        final distractors = otherSynonyms.take(3).toList();
        while (distractors.length < 3) {
          final dummy = allWords[random.nextInt(allWords.length)].word;
          if (dummy != target.word && !distractors.contains(dummy) && dummy != correctSynonym) {
            distractors.add(dummy);
          }
        }

        final options = [correctSynonym, ...distractors]..shuffle(random);
        final correctIndex = options.indexOf(correctSynonym);

        final knCtx = target.kannadaMeaning.isNotEmpty ? ' | ಕನ್ನಡ: ${target.kannadaMeaning}' : '';
        return QuizQuestion(
          id: 'q_${index}_${target.id}',
          prompt: 'Which word is a closest SYNONYM for "${target.word}"?',
          contextSnippet: 'Meaning: ${target.meaning}$knCtx',
          options: options,
          correctOptionIndex: correctIndex,
          explanation: '"$correctSynonym" is a synonym for "${target.word}". All synonyms: ${target.synonyms.join(", ")}.',
          type: type,
          targetWordId: target.id,
          targetWord: target.word,
        );

      case QuizType.antonymMatch:
        if (target.antonyms.isEmpty) {
          return _buildQuestionForType(
            type: QuizType.meaningMatch,
            target: target,
            allWords: allWords,
            index: index,
            random: random,
          );
        }
        final correctAntonym = target.antonyms[random.nextInt(target.antonyms.length)];
        final otherAntonyms = allWords
            .where((w) => w.id != target.id)
            .expand((w) => w.antonyms)
            .where((a) => !target.antonyms.contains(a))
            .toSet()
            .toList()
          ..shuffle(random);

        final distractors = otherAntonyms.take(3).toList();
        while (distractors.length < 3) {
          final dummy = allWords[random.nextInt(allWords.length)].word;
          if (dummy != target.word && !distractors.contains(dummy) && dummy != correctAntonym) {
            distractors.add(dummy);
          }
        }

        final options = [correctAntonym, ...distractors]..shuffle(random);
        final correctIndex = options.indexOf(correctAntonym);

        final knCtx = target.kannadaMeaning.isNotEmpty ? ' | ಕನ್ನಡ: ${target.kannadaMeaning}' : '';
        return QuizQuestion(
          id: 'q_${index}_${target.id}',
          prompt: 'Which word is the ANTONYM (opposite) of "${target.word}"?',
          contextSnippet: 'Meaning: ${target.meaning}$knCtx',
          options: options,
          correctOptionIndex: correctIndex,
          explanation: '"$correctAntonym" is the antonym of "${target.word}". Antonyms: ${target.antonyms.join(", ")}.',
          type: type,
          targetWordId: target.id,
          targetWord: target.word,
        );

      case QuizType.fillInTheBlank:
        final blankedExample = target.example.replaceAll(
          RegExp(RegExp.escape(target.word), caseSensitive: false),
          '__________',
        );
        final otherWords = allWords.where((w) => w.id != target.id).toList()..shuffle(random);
        final distractors = otherWords.take(3).map((w) => w.word).toList();
        final options = [target.word, ...distractors]..shuffle(random);
        final correctIndex = options.indexOf(target.word);

        final knMeaning = target.kannadaMeaning.isNotEmpty ? ' (ಕನ್ನಡ: ${target.kannadaMeaning})' : '';
        return QuizQuestion(
          id: 'q_${index}_${target.id}',
          prompt: 'Fill in the blank with the most appropriate vocabulary word:',
          contextSnippet: '"$blankedExample"',
          options: options,
          correctOptionIndex: correctIndex,
          explanation: 'Full Sentence: "${target.example}" — ${target.meaning}$knMeaning',
          type: type,
          targetWordId: target.id,
          targetWord: target.word,
        );

      case QuizType.englishToKannada:
        if (target.kannadaMeaning.trim().isEmpty) {
          return _buildQuestionForType(
            type: QuizType.meaningMatch,
            target: target,
            allWords: allWords,
            index: index,
            random: random,
          );
        }
        final wordsWithKn = allWords.where((w) => w.id != target.id && w.kannadaMeaning.trim().isNotEmpty).toList()..shuffle(random);
        final knDistractors = wordsWithKn.take(3).map((w) => w.kannadaMeaning).toSet().toList();
        while (knDistractors.length < 3) {
          knDistractors.add('ಅರ್ಥ ಲಭ್ಯವಿಲ್ಲ');
        }

        final knOptions = [target.kannadaMeaning, ...knDistractors.take(3)]..shuffle(random);
        final correctKnIndex = knOptions.indexOf(target.kannadaMeaning);

        return QuizQuestion(
          id: 'q_${index}_${target.id}',
          prompt: 'What is the correct Kannada meaning (ಕನ್ನಡ ಅರ್ಥ) of "${target.word}"?',
          contextSnippet: 'English Definition: ${target.meaning}',
          options: knOptions,
          correctOptionIndex: correctKnIndex,
          explanation: '"${target.word}" translates to "${target.kannadaMeaning}". Meaning: ${target.meaning}',
          type: type,
          targetWordId: target.id,
          targetWord: target.word,
        );

      case QuizType.kannadaToEnglish:
        if (target.kannadaMeaning.trim().isEmpty) {
          return _buildQuestionForType(
            type: QuizType.meaningMatch,
            target: target,
            allWords: allWords,
            index: index,
            random: random,
          );
        }
        final otherWords = allWords.where((w) => w.id != target.id).toList()..shuffle(random);
        final distractors = otherWords.take(3).map((w) => w.word).toList();
        final options = [target.word, ...distractors]..shuffle(random);
        final correctIndex = options.indexOf(target.word);

        return QuizQuestion(
          id: 'q_${index}_${target.id}',
          prompt: 'Which English word corresponds to the Kannada meaning "${target.kannadaMeaning}"?',
          contextSnippet: 'Context hint: ${target.partOfSpeech.toUpperCase()}',
          options: options,
          correctOptionIndex: correctIndex,
          explanation: '"${target.word}" means "${target.kannadaMeaning}" in Kannada. English definition: ${target.meaning}',
          type: type,
          targetWordId: target.id,
          targetWord: target.word,
        );

      case QuizType.sentenceCompletion:
        final blanked = target.example.isNotEmpty
            ? target.example.replaceAll(RegExp(RegExp.escape(target.word), caseSensitive: false), '__________')
            : 'The __________ was clearly visible in the sentence.';
        final otherWords = allWords.where((w) => w.id != target.id).toList()..shuffle(random);
        final distractors = otherWords.take(3).map((w) => w.word).toList();
        final options = [target.word, ...distractors]..shuffle(random);
        final correctIndex = options.indexOf(target.word);

        final knInfo = target.kannadaMeaning.isNotEmpty ? ' | ಕನ್ನಡ: ${target.kannadaMeaning}' : '';
        return QuizQuestion(
          id: 'q_${index}_${target.id}',
          prompt: 'Complete the sentence by selecting the most suitable word:',
          contextSnippet: '"$blanked"',
          options: options,
          correctOptionIndex: correctIndex,
          explanation: 'Correct Sentence: "${target.example}" — ${target.meaning}$knInfo',
          type: type,
          targetWordId: target.id,
          targetWord: target.word,
        );

      case QuizType.weakWordsPractice:
        // Build with meaning or Kannada mode
        if (target.kannadaMeaning.isNotEmpty && index.isEven) {
          return _buildQuestionForType(
            type: QuizType.englishToKannada,
            target: target,
            allWords: allWords,
            index: index,
            random: random,
          );
        }
        return _buildQuestionForType(
          type: QuizType.meaningMatch,
          target: target,
          allWords: allWords,
          index: index,
          random: random,
        );

      case QuizType.smartMixed:
        final mixedTypes = [
          QuizType.meaningMatch,
          QuizType.englishToKannada,
          QuizType.kannadaToEnglish,
          QuizType.fillInTheBlank,
          QuizType.sentenceCompletion,
          if (target.synonyms.isNotEmpty) QuizType.synonymMatch,
        ];
        final pickedType = mixedTypes[index % mixedTypes.length];
        return _buildQuestionForType(
          type: pickedType,
          target: target,
          allWords: allWords,
          index: index,
          random: random,
        );
    }
  }

  @override
  Future<QuizResultModel> saveQuizResult(QuizResultModel result) async {
    try {
      final db = await databaseHelper.database;
      final id = await db.insert(
        DatabaseTables.tableQuizResults,
        result.toDbMap(),
      );

      return QuizResultModel(
        id: id,
        quizType: result.quizType,
        totalQuestions: result.totalQuestions,
        correctAnswers: result.correctAnswers,
        scorePercentage: result.scorePercentage,
        completedAt: result.completedAt,
      );
    } catch (e) {
      throw AppDatabaseException('Failed to save quiz result: $e', e);
    }
  }

  @override
  Future<List<QuizResultModel>> getQuizHistory() async {
    try {
      final db = await databaseHelper.database;
      final results = await db.query(
        DatabaseTables.tableQuizResults,
        orderBy: '${DatabaseTables.colCompletedAt} DESC',
        limit: 50,
      );

      return results.map((row) => QuizResultModel.fromDbMap(row)).toList();
    } catch (e) {
      throw AppDatabaseException('Failed to fetch quiz history: $e', e);
    }
  }

  @override
  Future<Map<String, dynamic>> getQuizStatistics() async {
    try {
      final db = await databaseHelper.database;
      final countRes = await db.rawQuery('SELECT COUNT(*) as count FROM ${DatabaseTables.tableQuizResults}');
      final avgRes = await db.rawQuery('SELECT AVG(${DatabaseTables.colScorePercentage}) as avg_score FROM ${DatabaseTables.tableQuizResults}');
      final totalAnsweredRes = await db.rawQuery('SELECT SUM(${DatabaseTables.colTotalQuestions}) as total_q, SUM(${DatabaseTables.colCorrectAnswers}) as total_c FROM ${DatabaseTables.tableQuizResults}');

      final totalQuizzes = Sqflite.firstIntValue(countRes) ?? 0;
      final avgScore = (avgRes.first['avg_score'] as num?)?.toDouble() ?? 0.0;
      final totalQ = (totalAnsweredRes.first['total_q'] as num?)?.toInt() ?? 0;
      final totalC = (totalAnsweredRes.first['total_c'] as num?)?.toInt() ?? 0;

      return {
        'totalQuizzes': totalQuizzes,
        'averageScore': avgScore,
        'totalQuestionsAnswered': totalQ,
        'totalCorrectAnswers': totalC,
      };
    } catch (e) {
      throw AppDatabaseException('Failed to calculate quiz stats: $e', e);
    }
  }
}
