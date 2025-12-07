/// UserGamification - Entity สำหรับเก็บข้อมูล gamification ของผู้ใช้
library;

import 'package:equatable/equatable.dart';

/// ระดับของผู้ใช้พร้อมชื่อเรียก
enum LevelTitle {
  beginner('Beginner', '🌱'),
  learner('Learner', '📚'),
  student('Student', '✏️'),
  scholar('Scholar', '🎓'),
  expert('Expert', '💡'),
  master('Master', '🏆'),
  grandmaster('Grandmaster', '👑'),
  legend('Legend', '🌟');

  final String title;
  final String emoji;

  const LevelTitle(this.title, this.emoji);

  static LevelTitle fromLevel(int level) {
    if (level < 5) return LevelTitle.beginner;
    if (level < 10) return LevelTitle.learner;
    if (level < 20) return LevelTitle.student;
    if (level < 30) return LevelTitle.scholar;
    if (level < 40) return LevelTitle.expert;
    if (level < 50) return LevelTitle.master;
    if (level < 75) return LevelTitle.grandmaster;
    return LevelTitle.legend;
  }
}

class UserGamification extends Equatable {
  final int totalXp;
  final int currentLevel;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final List<String> unlockedAchievements;
  final Map<String, int> questProgress; // questId -> currentValue
  final DateTime? lastDailyReset;
  final DateTime? lastWeeklyReset;
  final int totalVocabLearned;
  final int totalExamsTaken;
  final int totalReadingCompleted;
  final int totalGrammarCompleted;
  final int perfectExams; // จำนวนข้อสอบที่ได้ 100%
  final int consecutiveHighScoreExams; // ทำ 90%+ ติดต่อกัน

  const UserGamification({
    this.totalXp = 0,
    this.currentLevel = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.unlockedAchievements = const [],
    this.questProgress = const {},
    this.lastDailyReset,
    this.lastWeeklyReset,
    this.totalVocabLearned = 0,
    this.totalExamsTaken = 0,
    this.totalReadingCompleted = 0,
    this.totalGrammarCompleted = 0,
    this.perfectExams = 0,
    this.consecutiveHighScoreExams = 0,
  });

  /// สร้าง UserGamification ว่างสำหรับผู้ใช้ใหม่
  factory UserGamification.empty() {
    return UserGamification(
      lastActiveDate: DateTime.now(),
      lastDailyReset: DateTime.now(),
      lastWeeklyReset: DateTime.now(),
    );
  }

  /// คำนวณ XP ที่ต้องการสำหรับ level ถัดไป
  int get xpForNextLevel => (currentLevel + 1) * (currentLevel + 1) * 100;

  /// คำนวณ XP ที่มีใน level ปัจจุบัน
  int get xpInCurrentLevel {
    if (currentLevel == 0) return totalXp;
    final xpForCurrentLevel = currentLevel * currentLevel * 100;
    return totalXp - xpForCurrentLevel;
  }

  /// คำนวณ progress เป็น % ไปยัง level ถัดไป
  double get levelProgress {
    final required = xpForNextLevel - (currentLevel * currentLevel * 100);
    if (required <= 0) return 1.0;
    return (xpInCurrentLevel / required).clamp(0.0, 1.0);
  }

  /// ดึงชื่อ level
  LevelTitle get levelTitle => LevelTitle.fromLevel(currentLevel);

  /// ตรวจสอบว่ามี achievement หรือยัง
  bool hasAchievement(String achievementId) {
    return unlockedAchievements.contains(achievementId);
  }

  UserGamification copyWith({
    int? totalXp,
    int? currentLevel,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    List<String>? unlockedAchievements,
    Map<String, int>? questProgress,
    DateTime? lastDailyReset,
    DateTime? lastWeeklyReset,
    int? totalVocabLearned,
    int? totalExamsTaken,
    int? totalReadingCompleted,
    int? totalGrammarCompleted,
    int? perfectExams,
    int? consecutiveHighScoreExams,
  }) {
    return UserGamification(
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      questProgress: questProgress ?? this.questProgress,
      lastDailyReset: lastDailyReset ?? this.lastDailyReset,
      lastWeeklyReset: lastWeeklyReset ?? this.lastWeeklyReset,
      totalVocabLearned: totalVocabLearned ?? this.totalVocabLearned,
      totalExamsTaken: totalExamsTaken ?? this.totalExamsTaken,
      totalReadingCompleted:
          totalReadingCompleted ?? this.totalReadingCompleted,
      totalGrammarCompleted:
          totalGrammarCompleted ?? this.totalGrammarCompleted,
      perfectExams: perfectExams ?? this.perfectExams,
      consecutiveHighScoreExams:
          consecutiveHighScoreExams ?? this.consecutiveHighScoreExams,
    );
  }

  factory UserGamification.fromJson(Map<String, dynamic> json) {
    return UserGamification(
      totalXp: json['totalXp'] as int? ?? 0,
      currentLevel: json['currentLevel'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.parse(json['lastActiveDate'] as String)
          : null,
      unlockedAchievements: (json['unlockedAchievements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      questProgress: (json['questProgress'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      lastDailyReset: json['lastDailyReset'] != null
          ? DateTime.parse(json['lastDailyReset'] as String)
          : null,
      lastWeeklyReset: json['lastWeeklyReset'] != null
          ? DateTime.parse(json['lastWeeklyReset'] as String)
          : null,
      totalVocabLearned: json['totalVocabLearned'] as int? ?? 0,
      totalExamsTaken: json['totalExamsTaken'] as int? ?? 0,
      totalReadingCompleted: json['totalReadingCompleted'] as int? ?? 0,
      totalGrammarCompleted: json['totalGrammarCompleted'] as int? ?? 0,
      perfectExams: json['perfectExams'] as int? ?? 0,
      consecutiveHighScoreExams: json['consecutiveHighScoreExams'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalXp': totalXp,
      'currentLevel': currentLevel,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'unlockedAchievements': unlockedAchievements,
      'questProgress': questProgress,
      'lastDailyReset': lastDailyReset?.toIso8601String(),
      'lastWeeklyReset': lastWeeklyReset?.toIso8601String(),
      'totalVocabLearned': totalVocabLearned,
      'totalExamsTaken': totalExamsTaken,
      'totalReadingCompleted': totalReadingCompleted,
      'totalGrammarCompleted': totalGrammarCompleted,
      'perfectExams': perfectExams,
      'consecutiveHighScoreExams': consecutiveHighScoreExams,
    };
  }

  @override
  List<Object?> get props => [
        totalXp,
        currentLevel,
        currentStreak,
        longestStreak,
        lastActiveDate,
        unlockedAchievements,
        questProgress,
        lastDailyReset,
        lastWeeklyReset,
        totalVocabLearned,
        totalExamsTaken,
        totalReadingCompleted,
        totalGrammarCompleted,
        perfectExams,
        consecutiveHighScoreExams,
      ];
}
