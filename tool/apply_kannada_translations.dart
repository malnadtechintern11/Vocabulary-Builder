// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:vocabulary_builder/data/sentences_data.dart';
import 'package:vocabulary_builder/models/sentence.dart';
import 'data/beginner_kannada.dart';
import 'data/intermediate_kannada.dart';
import 'data/advanced_kannada.dart';

void main() {
  print('Applying Kannada translations to all 600 sentences...');

  final all = SentencesData.sentences;
  assert(all.length == 600, 'Expected 600 sentences, got ${all.length}');

  final updatedSentences = <Sentence>[];

  for (final s in all) {
    String? kn;
    if (s.id.startsWith('b')) {
      kn = beginnerKannada[s.id];
    } else if (s.id.startsWith('i')) {
      kn = intermediateKannada[s.id];
    } else if (s.id.startsWith('a')) {
      kn = advancedKannada[s.id];
    }

    if (kn == null || kn.trim().isEmpty) {
      throw Exception('Missing Kannada translation for sentence ${s.id}: "${s.text}"');
    }

    updatedSentences.add(s.copyWith(kannadaMeaning: kn.trim()));
  }

  print('Successfully mapped translations for all ${updatedSentences.length} sentences.');

  final bList = updatedSentences.where((s) => s.difficulty.toLowerCase() == 'beginner').toList();
  final iList = updatedSentences.where((s) => s.difficulty.toLowerCase() == 'intermediate').toList();
  final aList = updatedSentences.where((s) => s.difficulty.toLowerCase() == 'advanced').toList();

  assert(bList.length == 200, 'Expected 200 Beginner, got ${bList.length}');
  assert(iList.length == 200, 'Expected 200 Intermediate, got ${iList.length}');
  assert(aList.length == 200, 'Expected 200 Advanced, got ${aList.length}');

  String generateDartFile(List<Sentence> list, String varName) {
    final buf = StringBuffer();
    buf.writeln("import '../../models/sentence.dart';\n");
    buf.writeln("/// Static collection of ${list.length} offline sentences with English and Kannada meanings");
    buf.writeln("const List<Sentence> $varName = [");
    for (final s in list) {
      buf.writeln("  Sentence(");
      buf.writeln("    id: '${s.id}',");
      buf.writeln("    text: ${jsonEncode(s.text)},");
      buf.writeln("    meaning: ${jsonEncode(s.meaning)},");
      buf.writeln("    kannadaMeaning: ${jsonEncode(s.kannadaMeaning)},");
      buf.writeln("    difficulty: '${s.difficulty}',");
      buf.writeln("    category: '${s.category}',");
      buf.writeln("    vocabularyWords: [");
      for (final v in s.vocabularyWords) {
        buf.writeln("      SentenceWord(word: ${jsonEncode(v.word)}, meaning: ${jsonEncode(v.meaning)}),");
      }
      buf.writeln("    ],");
      buf.writeln("  ),");
    }
    buf.writeln("];\n");
    return buf.toString();
  }

  File('lib/data/sentences/beginner_sentences.dart')
      .writeAsStringSync(generateDartFile(bList, 'beginnerSentences'));
  File('lib/data/sentences/intermediate_sentences.dart')
      .writeAsStringSync(generateDartFile(iList, 'intermediateSentences'));
  File('lib/data/sentences/advanced_sentences.dart')
      .writeAsStringSync(generateDartFile(aList, 'advancedSentences'));

  // Update assets/data/sentences.json
  final jsonList = updatedSentences.map((s) => s.toJson()).toList();
  File('assets/data/sentences.json')
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(jsonList));

  print('Files generated successfully:');
  print('- lib/data/sentences/beginner_sentences.dart (200 sentences)');
  print('- lib/data/sentences/intermediate_sentences.dart (200 sentences)');
  print('- lib/data/sentences/advanced_sentences.dart (200 sentences)');
  print('- assets/data/sentences.json (600 sentences total)');
}
