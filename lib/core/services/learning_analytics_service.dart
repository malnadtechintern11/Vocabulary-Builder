import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../database/database_tables.dart';

/// Data class representing user's streak status
class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final String lastActiveDate;
  final bool isActiveToday;

  const StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActiveDate,
    required this.isActiveToday,
  });
}

/// Data class representing a single day's activity
class DailyActivityItem {
  final String date; // YYYY-MM-DD
  final String dayName; // Mon, Tue, etc.
  final int wordsLearned;
  final int quizzesCompleted;
  final bool isGoalAchieved;
  final bool isToday;

  const DailyActivityItem({
    required this.date,
    required this.dayName,
    required this.wordsLearned,
    required this.quizzesCompleted,
    required this.isGoalAchieved,
    required this.isToday,
  });
}

/// Data class for an achievement badge
class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int targetValue;
  final int currentValue;
  final bool isUnlocked;
  final String? unlockedAt;

  const AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.targetValue,
    required this.currentValue,
    required this.isUnlocked,
    this.unlockedAt,
  });

  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : (isUnlocked ? 1.0 : 0.0);
}

/// Data class for category strength analytics
class CategoryAnalytics {
  final List<Map<String, dynamic>> categoryStats;
  final List<String> strongCategories;
  final List<String> weakCategories;

  const CategoryAnalytics({
    required this.categoryStats,
    required this.strongCategories,
    required this.weakCategories,
  });
}

/// Data class for a personalized learning recommendation
class LearningRecommendation {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String actionLabel;
  final String route;

  const LearningRecommendation({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.actionLabel,
    required this.route,
  });
}

/// Service handling all offline learning analytics, streaks, goals, weak words, and achievements
class LearningAnalyticsService {
  final AppDatabase databaseHelper;

  static const String _prefDailyGoalTarget = 'daily_learning_goal_target';
  static const String _prefCurrentStreak = 'learning_current_streak';
  static const String _prefLongestStreak = 'learning_longest_streak';
  static const String _prefLastActiveDate = 'learning_last_active_date';

  LearningAnalyticsService({AppDatabase? databaseHelper})
      : databaseHelper = databaseHelper ?? AppDatabase.instance;

  String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  // ==================== 1. DAILY GOAL SYSTEM ====================

  Future<int> getDailyGoalTarget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefDailyGoalTarget) ?? 10;
  }

  Future<void> setDailyGoalTarget(int target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefDailyGoalTarget, target);
  }

  Future<int> getTodayWordsLearnedCount() async {
    try {
      final db = await databaseHelper.database;
      final todayStr = _formatDate(DateTime.now());
      final res = await db.query(
        DatabaseTables.tableDailyActivity,
        where: '${DatabaseTables.colActivityDate} = ?',
        whereArgs: [todayStr],
      );

      if (res.isNotEmpty) {
        return (res.first[DatabaseTables.colActivityWordsLearned] as int?) ?? 0;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<bool> recordWordLearned(int wordId) async {
    try {
      final db = await databaseHelper.database;
      final todayStr = _formatDate(DateTime.now());
      final target = await getDailyGoalTarget();

      final existing = await db.query(
        DatabaseTables.tableDailyActivity,
        where: '${DatabaseTables.colActivityDate} = ?',
        whereArgs: [todayStr],
      );

      bool newlyAchieved = false;
      if (existing.isEmpty) {
        final achieved = 1 >= target ? 1 : 0;
        newlyAchieved = achieved == 1;
        await db.insert(DatabaseTables.tableDailyActivity, {
          DatabaseTables.colActivityDate: todayStr,
          DatabaseTables.colActivityWordsLearned: 1,
          DatabaseTables.colActivityQuizzesCompleted: 0,
          DatabaseTables.colActivityGoalTarget: target,
          DatabaseTables.colActivityGoalAchieved: achieved,
        });
      } else {
        final currentCount = (existing.first[DatabaseTables.colActivityWordsLearned] as int?) ?? 0;
        final wasAchieved = ((existing.first[DatabaseTables.colActivityGoalAchieved] as int?) ?? 0) == 1;
        final updatedCount = currentCount + 1;
        final isAchieved = updatedCount >= target;
        newlyAchieved = isAchieved && !wasAchieved;

        await db.update(
          DatabaseTables.tableDailyActivity,
          {
            DatabaseTables.colActivityWordsLearned: updatedCount,
            DatabaseTables.colActivityGoalTarget: target,
            DatabaseTables.colActivityGoalAchieved: isAchieved ? 1 : 0,
          },
          where: '${DatabaseTables.colActivityDate} = ?',
          whereArgs: [todayStr],
        );
      }

      // Update streak
      await recordActivityToday();
      return newlyAchieved;
    } catch (e) {
      debugPrint('Error recording word learned: $e');
      return false;
    }
  }

  // ==================== 2. LEARNING STREAK SYSTEM ====================

  Future<StreakInfo> getStreakInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _formatDate(DateTime.now());
    final lastActive = prefs.getString(_prefLastActiveDate) ?? '';
    int currentStreak = prefs.getInt(_prefCurrentStreak) ?? 0;
    final longestStreak = prefs.getInt(_prefLongestStreak) ?? currentStreak;

    bool isActiveToday = lastActive == today;

    // Check if streak was broken (last active was before yesterday)
    if (lastActive.isNotEmpty && !isActiveToday) {
      final lastDate = DateTime.tryParse(lastActive);
      if (lastDate != null) {
        final diff = DateTime.now().difference(lastDate).inDays;
        if (diff > 1) {
          currentStreak = 0;
          await prefs.setInt(_prefCurrentStreak, 0);
        }
      }
    }

    return StreakInfo(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastActiveDate: lastActive,
      isActiveToday: isActiveToday,
    );
  }

  Future<StreakInfo> recordActivityToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _formatDate(DateTime.now());
    final lastActive = prefs.getString(_prefLastActiveDate) ?? '';
    int currentStreak = prefs.getInt(_prefCurrentStreak) ?? 0;
    int longestStreak = prefs.getInt(_prefLongestStreak) ?? 0;

    if (lastActive == today) {
      // Already active today
      return StreakInfo(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        lastActiveDate: today,
        isActiveToday: true,
      );
    }

    final yesterday = _formatDate(DateTime.now().subtract(const Duration(days: 1)));
    if (lastActive == yesterday) {
      // Continued streak from yesterday
      currentStreak += 1;
    } else {
      // Starting fresh streak
      currentStreak = 1;
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
      await prefs.setInt(_prefLongestStreak, longestStreak);
    }

    await prefs.setString(_prefLastActiveDate, today);
    await prefs.setInt(_prefCurrentStreak, currentStreak);

    return StreakInfo(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastActiveDate: today,
      isActiveToday: true,
    );
  }

  // ==================== 3. SMART REVISION & WEAK WORDS ====================

  Future<void> recordQuizQuestionAttempt({
    required int wordId,
    required String word,
    required bool isCorrect,
  }) async {
    try {
      final db = await databaseHelper.database;
      final now = DateTime.now().toIso8601String();

      final existing = await db.query(
        DatabaseTables.tableWordQuizStats,
        where: '${DatabaseTables.colStatsWordId} = ?',
        whereArgs: [wordId],
      );

      if (existing.isEmpty) {
        await db.insert(DatabaseTables.tableWordQuizStats, {
          DatabaseTables.colStatsWordId: wordId,
          DatabaseTables.colStatsWord: word,
          DatabaseTables.colStatsTimesTested: 1,
          DatabaseTables.colStatsTimesCorrect: isCorrect ? 1 : 0,
          DatabaseTables.colStatsTimesIncorrect: isCorrect ? 0 : 1,
          DatabaseTables.colStatsLastTestedAt: now,
        });
      } else {
        final row = existing.first;
        final tested = (row[DatabaseTables.colStatsTimesTested] as int) + 1;
        final correct = (row[DatabaseTables.colStatsTimesCorrect] as int) + (isCorrect ? 1 : 0);
        final incorrect = (row[DatabaseTables.colStatsTimesIncorrect] as int) + (isCorrect ? 0 : 1);

        await db.update(
          DatabaseTables.tableWordQuizStats,
          {
            DatabaseTables.colStatsTimesTested: tested,
            DatabaseTables.colStatsTimesCorrect: correct,
            DatabaseTables.colStatsTimesIncorrect: incorrect,
            DatabaseTables.colStatsLastTestedAt: now,
          },
          where: '${DatabaseTables.colStatsWordId} = ?',
          whereArgs: [wordId],
        );
      }
    } catch (e) {
      debugPrint('Error recording question attempt: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getWeakWords({int limit = 30}) async {
    try {
      final db = await databaseHelper.database;
      final query = '''
        SELECT s.*, w.${DatabaseTables.colMeaning}, w.${DatabaseTables.colKannadaMeaning},
               w.${DatabaseTables.colDifficulty}, w.${DatabaseTables.colCategory},
               w.${DatabaseTables.colPhonetic}, w.${DatabaseTables.colExample}
        FROM ${DatabaseTables.tableWordQuizStats} s
        JOIN ${DatabaseTables.tableWords} w ON s.${DatabaseTables.colStatsWordId} = w.${DatabaseTables.colId}
        WHERE s.${DatabaseTables.colStatsTimesIncorrect} > 0
          AND s.${DatabaseTables.colStatsTimesIncorrect} >= s.${DatabaseTables.colStatsTimesCorrect}
        ORDER BY s.${DatabaseTables.colStatsTimesIncorrect} DESC, s.${DatabaseTables.colStatsLastTestedAt} DESC
        LIMIT ?
      ''';

      return await db.rawQuery(query, [limit]);
    } catch (e) {
      debugPrint('Error getting weak words: $e');
      return [];
    }
  }

  Future<void> resolveWeakWord(int wordId) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        DatabaseTables.tableWordQuizStats,
        {
          DatabaseTables.colStatsTimesIncorrect: 0,
        },
        where: '${DatabaseTables.colStatsWordId} = ?',
        whereArgs: [wordId],
      );
    } catch (e) {
      debugPrint('Error resolving weak word: $e');
    }
  }

  // ==================== 4. ACHIEVEMENTS & BADGES SYSTEM ====================

  Future<List<AchievementBadge>> getAchievements() async {
    try {
      final db = await databaseHelper.database;

      // Query metrics
      final wordCountRes = await db.rawQuery('SELECT COUNT(*) as cnt FROM ${DatabaseTables.tableWords} WHERE ${DatabaseTables.colIsLearned} = 1');
      final masteredWords = Sqflite.firstIntValue(wordCountRes) ?? 0;

      final quizCountRes = await db.rawQuery('SELECT COUNT(*) as cnt FROM ${DatabaseTables.tableQuizResults}');
      final totalQuizzes = Sqflite.firstIntValue(quizCountRes) ?? 0;

      final perfectQuizRes = await db.rawQuery('SELECT COUNT(*) as cnt FROM ${DatabaseTables.tableQuizResults} WHERE ${DatabaseTables.colScorePercentage} = 100');
      final perfectQuizzes = Sqflite.firstIntValue(perfectQuizRes) ?? 0;

      final streak = await getStreakInfo();

      final kannadaRes = await db.rawQuery(
        "SELECT COUNT(*) as cnt FROM ${DatabaseTables.tableWords} WHERE ${DatabaseTables.colIsLearned} = 1 AND ${DatabaseTables.colKannadaMeaning} IS NOT NULL AND ${DatabaseTables.colKannadaMeaning} != ''",
      );
      final kannadaMastered = Sqflite.firstIntValue(kannadaRes) ?? 0;

      final goalAchievedRes = await db.rawQuery('SELECT COUNT(*) as cnt FROM ${DatabaseTables.tableDailyActivity} WHERE ${DatabaseTables.colActivityGoalAchieved} = 1');
      final goalDays = Sqflite.firstIntValue(goalAchievedRes) ?? 0;

      // Query unlocked badges from DB
      final unlockedRows = await db.query(DatabaseTables.tableAchievements);
      final unlockedMap = {
        for (var r in unlockedRows) r[DatabaseTables.colBadgeId] as String: r[DatabaseTables.colUnlockedAt] as String
      };

      final definitions = <_BadgeDefinition>[
        _BadgeDefinition('first_word', 'First Step', 'Learned your first vocabulary word', Icons.looks_one_rounded, const Color(0xFF10B981), 1, masteredWords),
        _BadgeDefinition('words_10', 'Lexicon Novice', 'Mastered 10 vocabulary words', Icons.local_library_rounded, const Color(0xFF0D9488), 10, masteredWords),
        _BadgeDefinition('words_50', 'Word Enthusiast', 'Mastered 50 vocabulary words', Icons.school_rounded, const Color(0xFF3B82F6), 50, masteredWords),
        _BadgeDefinition('words_100', 'Vocabulary Master', 'Mastered 100 vocabulary words', Icons.workspace_premium_rounded, const Color(0xFF8B5CF6), 100, masteredWords),
        _BadgeDefinition('words_250', 'Lexicon Scholar', 'Mastered 250 vocabulary words', Icons.military_tech_rounded, const Color(0xFFEC4899), 250, masteredWords),
        _BadgeDefinition('first_quiz', 'Quiz Cadet', 'Completed your first vocabulary quiz', Icons.quiz_rounded, const Color(0xFFF59E0B), 1, totalQuizzes),
        _BadgeDefinition('quiz_ace', 'Quiz Ace', 'Scored a perfect 100% on a quiz', Icons.emoji_events_rounded, const Color(0xFF10B981), 1, perfectQuizzes),
        _BadgeDefinition('quiz_10', 'Quiz Champion', 'Completed 10 vocabulary quizzes', Icons.stars_rounded, const Color(0xFF6366F1), 10, totalQuizzes),
        _BadgeDefinition('streak_3', 'Consistent Learner', 'Maintained a 3-day learning streak', Icons.local_fire_department_rounded, const Color(0xFFF97316), 3, streak.longestStreak),
        _BadgeDefinition('streak_7', 'Weekly Warrior', 'Maintained a 7-day learning streak', Icons.whatshot_rounded, const Color(0xFFEF4444), 7, streak.longestStreak),
        _BadgeDefinition('streak_30', 'Monthly Legend', 'Maintained a 30-day learning streak', Icons.auto_awesome_rounded, const Color(0xFFE11D48), 30, streak.longestStreak),
        _BadgeDefinition('daily_goal', 'Goal Crusher', 'Completed your daily learning target', Icons.check_circle_rounded, const Color(0xFF10B981), 1, goalDays),
        _BadgeDefinition('kannada_scholar', 'Dual Scholar', 'Mastered 10+ words with Kannada meanings', Icons.translate_rounded, const Color(0xFF0D9488), 10, kannadaMastered),
      ];

      final badges = <AchievementBadge>[];
      for (final def in definitions) {
        final isUnlocked = unlockedMap.containsKey(def.id) || def.currentValue >= def.targetValue;
        String? unlockedDate = unlockedMap[def.id];

        if (isUnlocked && unlockedDate == null) {
          unlockedDate = DateTime.now().toIso8601String();
          await db.insert(
            DatabaseTables.tableAchievements,
            {
              DatabaseTables.colBadgeId: def.id,
              DatabaseTables.colUnlockedAt: unlockedDate,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }

        badges.add(
          AchievementBadge(
            id: def.id,
            title: def.title,
            description: def.description,
            icon: def.icon,
            color: def.color,
            targetValue: def.targetValue,
            currentValue: def.currentValue,
            isUnlocked: isUnlocked,
            unlockedAt: unlockedDate,
          ),
        );
      }

      return badges;
    } catch (e) {
      debugPrint('Error getting achievements: $e');
      return [];
    }
  }

  // ==================== 5. 7-DAY WEEKLY ACTIVITY ====================

  Future<List<DailyActivityItem>> getWeeklyActivity() async {
    try {
      final db = await databaseHelper.database;
      final now = DateTime.now();
      final items = <DailyActivityItem>[];

      const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateStr = _formatDate(date);
        final dayName = dayNames[date.weekday - 1];
        final isToday = i == 0;

        final res = await db.query(
          DatabaseTables.tableDailyActivity,
          where: '${DatabaseTables.colActivityDate} = ?',
          whereArgs: [dateStr],
        );

        if (res.isNotEmpty) {
          final row = res.first;
          items.add(
            DailyActivityItem(
              date: dateStr,
              dayName: dayName,
              wordsLearned: (row[DatabaseTables.colActivityWordsLearned] as int?) ?? 0,
              quizzesCompleted: (row[DatabaseTables.colActivityQuizzesCompleted] as int?) ?? 0,
              isGoalAchieved: ((row[DatabaseTables.colActivityGoalAchieved] as int?) ?? 0) == 1,
              isToday: isToday,
            ),
          );
        } else {
          items.add(
            DailyActivityItem(
              date: dateStr,
              dayName: dayName,
              wordsLearned: 0,
              quizzesCompleted: 0,
              isGoalAchieved: false,
              isToday: isToday,
            ),
          );
        }
      }

      return items;
    } catch (e) {
      debugPrint('Error getting weekly activity: $e');
      return [];
    }
  }

  // ==================== 6. CATEGORY INTELLIGENCE ====================

  Future<CategoryAnalytics> getCategoryAnalytics() async {
    try {
      final db = await databaseHelper.database;
      final res = await db.rawQuery('''
        SELECT ${DatabaseTables.colCategory},
               COUNT(*) as total,
               SUM(${DatabaseTables.colIsLearned}) as learned
        FROM ${DatabaseTables.tableWords}
        GROUP BY ${DatabaseTables.colCategory}
      ''');

      final stats = <Map<String, dynamic>>[];
      for (final row in res) {
        final cat = row[DatabaseTables.colCategory] as String? ?? 'General';
        final total = (row['total'] as int?) ?? 0;
        final learned = (row['learned'] as int?) ?? 0;
        final pct = total > 0 ? (learned / total) * 100.0 : 0.0;

        stats.add({
          'category': cat,
          'total': total,
          'learned': learned,
          'percentage': pct,
        });
      }

      // Sort by percentage descending
      stats.sort((a, b) => (b['percentage'] as double).compareTo(a['percentage'] as double));

      final strong = stats.take(2).map((s) => s['category'] as String).toList();
      final weak = stats.reversed.take(2).map((s) => s['category'] as String).toList();

      return CategoryAnalytics(
        categoryStats: stats,
        strongCategories: strong,
        weakCategories: weak,
      );
    } catch (e) {
      debugPrint('Error getting category analytics: $e');
      return const CategoryAnalytics(categoryStats: [], strongCategories: [], weakCategories: []);
    }
  }

  // ==================== 7. PERSONALIZED RECOMMENDATIONS ====================

  Future<List<LearningRecommendation>> getRecommendations() async {
    final list = <LearningRecommendation>[];
    try {
      final weakWords = await getWeakWords(limit: 5);
      if (weakWords.isNotEmpty) {
        list.add(
          LearningRecommendation(
            id: 'weak_words',
            title: 'Strengthen ${weakWords.length} Weak Words',
            subtitle: 'You frequently missed "${weakWords.first[DatabaseTables.colStatsWord]}" and others. Quick practice boosts retention!',
            icon: Icons.flash_on_rounded,
            color: const Color(0xFFF59E0B),
            actionLabel: 'Practice Now',
            route: '/progress',
          ),
        );
      }

      final todayWords = await getTodayWordsLearnedCount();
      final target = await getDailyGoalTarget();
      if (todayWords < target) {
        final remaining = target - todayWords;
        list.add(
          LearningRecommendation(
            id: 'daily_goal',
            title: 'Daily Goal: $remaining words to go',
            subtitle: 'Complete today’s goal to keep your progress on track and earn the Goal Crusher badge.',
            icon: Icons.track_changes_rounded,
            color: const Color(0xFF4F46E5),
            actionLabel: 'Learn Words',
            route: '/words',
          ),
        );
      }

      final streak = await getStreakInfo();
      if (!streak.isActiveToday && streak.currentStreak > 0) {
        list.add(
          LearningRecommendation(
            id: 'keep_streak',
            title: 'Protect Your ${streak.currentStreak}-Day Streak!',
            subtitle: 'Study a few words today to avoid resetting your learning streak to zero.',
            icon: Icons.local_fire_department_rounded,
            color: const Color(0xFFEF4444),
            actionLabel: 'Study Now',
            route: '/words',
          ),
        );
      }

      final catAnalytics = await getCategoryAnalytics();
      if (catAnalytics.weakCategories.isNotEmpty) {
        final weakCat = catAnalytics.weakCategories.first;
        list.add(
          LearningRecommendation(
            id: 'focus_category',
            title: 'Boost ${weakCat[0].toUpperCase() + weakCat.substring(1)} Words',
            subtitle: 'Your mastery in $weakCat is lower than other categories. Take a targeted quiz to build confidence.',
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF0D9488),
            actionLabel: 'Start Quiz',
            route: '/quiz',
          ),
        );
      }
    } catch (e) {
      debugPrint('Error generating recommendations: $e');
    }

    return list;
  }
}

class _BadgeDefinition {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int targetValue;
  final int currentValue;

  const _BadgeDefinition(
    this.id,
    this.title,
    this.description,
    this.icon,
    this.color,
    this.targetValue,
    this.currentValue,
  );
}
