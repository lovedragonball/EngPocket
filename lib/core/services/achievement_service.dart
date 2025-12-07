/// Achievement Service - จัดการระบบ Achievement
library;

import 'dart:async';
import '../models/achievement.dart';
import '../models/user_gamification.dart';
import '../../features/gamification/data/achievement_data.dart';
import 'xp_service.dart';

/// ผลลัพธ์จากการตรวจสอบ Achievement
class AchievementCheckResult {
  final List<Achievement> newlyUnlocked;
  final int totalXpGained;

  const AchievementCheckResult({
    required this.newlyUnlocked,
    required this.totalXpGained,
  });

  bool get hasNewAchievements => newlyUnlocked.isNotEmpty;
}

class AchievementService {
  static AchievementService? _instance;

  AchievementService._();

  static AchievementService get instance {
    _instance ??= AchievementService._();
    return _instance!;
  }

  // Stream controller สำหรับ broadcast achievement unlocks
  final _achievementController = StreamController<Achievement>.broadcast();
  Stream<Achievement> get onAchievementUnlocked =>
      _achievementController.stream;

  /// ตรวจสอบและปลดล็อค achievements
  Future<AchievementCheckResult> checkAchievements() async {
    final xpService = XpService.instance;
    final data = await xpService.loadData();

    final newlyUnlocked = <Achievement>[];
    int totalXp = 0;

    for (final achievement in AchievementData.all) {
      // ข้ามถ้าปลดล็อคแล้ว
      if (data.hasAchievement(achievement.id)) continue;

      // ตรวจสอบเงื่อนไข
      final shouldUnlock = _checkAchievementCondition(achievement, data);

      if (shouldUnlock) {
        newlyUnlocked.add(achievement);
        totalXp += achievement.xpReward;
      }
    }

    // บันทึก achievements ที่ปลดล็อคใหม่
    if (newlyUnlocked.isNotEmpty) {
      final updatedAchievements = [
        ...data.unlockedAchievements,
        ...newlyUnlocked.map((a) => a.id),
      ];

      final updatedData = data.copyWith(
        unlockedAchievements: updatedAchievements,
      );
      await xpService.saveData(updatedData);

      // ให้ XP
      if (totalXp > 0) {
        await xpService.addXp(XpSource.achievementUnlock,
            customAmount: totalXp);
      }

      // Broadcast events
      for (final achievement in newlyUnlocked) {
        _achievementController.add(achievement);
      }
    }

    return AchievementCheckResult(
      newlyUnlocked: newlyUnlocked,
      totalXpGained: totalXp,
    );
  }

  /// ตรวจสอบเงื่อนไขของ achievement
  bool _checkAchievementCondition(
      Achievement achievement, UserGamification data) {
    final now = DateTime.now();

    switch (achievement.id) {
      // Vocabulary Achievements
      case 'vocab_first_10':
        return data.totalVocabLearned >= 10;
      case 'vocab_50':
        return data.totalVocabLearned >= 50;
      case 'vocab_100':
        return data.totalVocabLearned >= 100;
      case 'vocab_250':
        return data.totalVocabLearned >= 250;
      case 'vocab_500':
        return data.totalVocabLearned >= 500;
      case 'vocab_1000':
        return data.totalVocabLearned >= 1000;

      // Exam Achievements
      case 'exam_first':
        return data.totalExamsTaken >= 1;
      case 'exam_5':
        return data.totalExamsTaken >= 5;
      case 'exam_10':
        return data.totalExamsTaken >= 10;
      case 'exam_25':
        return data.totalExamsTaken >= 25;
      case 'exam_perfect':
        return data.perfectExams >= 1;
      case 'exam_perfect_5':
        return data.perfectExams >= 5;
      case 'exam_90_streak_3':
        return data.consecutiveHighScoreExams >= 3;

      // Streak Achievements
      case 'streak_3':
        return data.currentStreak >= 3 || data.longestStreak >= 3;
      case 'streak_7':
        return data.currentStreak >= 7 || data.longestStreak >= 7;
      case 'streak_14':
        return data.currentStreak >= 14 || data.longestStreak >= 14;
      case 'streak_30':
        return data.currentStreak >= 30 || data.longestStreak >= 30;
      case 'streak_60':
        return data.currentStreak >= 60 || data.longestStreak >= 60;
      case 'streak_100':
        return data.currentStreak >= 100 || data.longestStreak >= 100;
      case 'streak_365':
        return data.currentStreak >= 365 || data.longestStreak >= 365;

      // Level Achievements
      case 'level_5':
        return data.currentLevel >= 5;
      case 'level_10':
        return data.currentLevel >= 10;
      case 'level_25':
        return data.currentLevel >= 25;
      case 'level_50':
        return data.currentLevel >= 50;

      // Reading Achievements
      case 'reading_first':
        return data.totalReadingCompleted >= 1;
      case 'reading_5':
        return data.totalReadingCompleted >= 5;
      case 'reading_10':
        return data.totalReadingCompleted >= 10;
      case 'reading_25':
        return data.totalReadingCompleted >= 25;

      // Grammar Achievements
      case 'grammar_first':
        return data.totalGrammarCompleted >= 1;
      case 'grammar_5':
        return data.totalGrammarCompleted >= 5;
      case 'grammar_10':
        return data.totalGrammarCompleted >= 10;
      // grammar_all - ต้องตรวจสอบว่าเรียนครบทุกบท (จะ implement เพิ่มภายหลัง)

      // XP Achievements
      case 'xp_1000':
        return data.totalXp >= 1000;
      case 'xp_5000':
        return data.totalXp >= 5000;
      case 'xp_10000':
        return data.totalXp >= 10000;

      // Time-based Achievements
      case 'night_owl':
        return now.hour >= 0 && now.hour < 5;
      case 'early_bird':
        return now.hour >= 5 && now.hour < 6;

      default:
        return false;
    }
  }

  /// ดึง achievements ที่ปลดล็อคแล้ว
  Future<List<Achievement>> getUnlockedAchievements() async {
    final data = await XpService.instance.loadData();

    return data.unlockedAchievements
        .map((id) => AchievementData.getById(id))
        .whereType<Achievement>()
        .toList();
  }

  /// ดึง achievements ทั้งหมดพร้อมสถานะ
  Future<List<({Achievement achievement, bool isUnlocked, double progress})>>
      getAllAchievementsWithStatus() async {
    final data = await XpService.instance.loadData();

    return AchievementData.all.map((achievement) {
      final isUnlocked = data.hasAchievement(achievement.id);
      final progress = isUnlocked ? 1.0 : _calculateProgress(achievement, data);

      return (
        achievement: achievement,
        isUnlocked: isUnlocked,
        progress: progress,
      );
    }).toList();
  }

  /// คำนวณ progress ของ achievement
  double _calculateProgress(Achievement achievement, UserGamification data) {
    if (achievement.targetValue == null) return 0.0;

    final target = achievement.targetValue!;
    int current = 0;

    switch (achievement.id) {
      // Vocabulary
      case 'vocab_first_10':
      case 'vocab_50':
      case 'vocab_100':
      case 'vocab_250':
      case 'vocab_500':
      case 'vocab_1000':
        current = data.totalVocabLearned;
        break;

      // Exam
      case 'exam_first':
      case 'exam_5':
      case 'exam_10':
      case 'exam_25':
        current = data.totalExamsTaken;
        break;
      case 'exam_perfect':
      case 'exam_perfect_5':
        current = data.perfectExams;
        break;

      // Streak
      case 'streak_3':
      case 'streak_7':
      case 'streak_14':
      case 'streak_30':
      case 'streak_60':
      case 'streak_100':
      case 'streak_365':
        current = data.longestStreak > data.currentStreak
            ? data.longestStreak
            : data.currentStreak;
        break;

      // Level
      case 'level_5':
      case 'level_10':
      case 'level_25':
      case 'level_50':
        current = data.currentLevel;
        break;

      // Reading
      case 'reading_first':
      case 'reading_5':
      case 'reading_10':
      case 'reading_25':
        current = data.totalReadingCompleted;
        break;

      // Grammar
      case 'grammar_first':
      case 'grammar_5':
      case 'grammar_10':
        current = data.totalGrammarCompleted;
        break;

      // XP
      case 'xp_1000':
      case 'xp_5000':
      case 'xp_10000':
        current = data.totalXp;
        break;

      default:
        return 0.0;
    }

    return (current / target).clamp(0.0, 1.0);
  }

  /// ดึงสถิติ achievements
  Future<
      ({
        int unlocked,
        int total,
        int commonUnlocked,
        int rareUnlocked,
        int epicUnlocked,
        int legendaryUnlocked
      })> getAchievementStats() async {
    final data = await XpService.instance.loadData();

    final unlocked = data.unlockedAchievements
        .map((id) => AchievementData.getById(id))
        .whereType<Achievement>()
        .toList();

    return (
      unlocked: unlocked.length,
      total: AchievementData.count,
      commonUnlocked:
          unlocked.where((a) => a.rarity == AchievementRarity.common).length,
      rareUnlocked:
          unlocked.where((a) => a.rarity == AchievementRarity.rare).length,
      epicUnlocked:
          unlocked.where((a) => a.rarity == AchievementRarity.epic).length,
      legendaryUnlocked:
          unlocked.where((a) => a.rarity == AchievementRarity.legendary).length,
    );
  }

  /// Dispose streams
  void dispose() {
    _achievementController.close();
  }
}
