/// Achievement - Entity สำหรับ Achievement
library;

import 'package:equatable/equatable.dart';

/// หมวดหมู่ของ Achievement
enum AchievementCategory {
  vocabulary('📚', 'Vocabulary'),
  exam('📝', 'Exams'),
  streak('🔥', 'Streaks'),
  level('⭐', 'Levels'),
  reading('📖', 'Reading'),
  grammar('📐', 'Grammar'),
  special('🎮', 'Special');

  final String emoji;
  final String displayName;

  const AchievementCategory(this.emoji, this.displayName);
}

/// ความหายากของ Achievement
enum AchievementRarity {
  common(0xFF9CA3AF, 'Common', 1.0), // Gray
  rare(0xFF3B82F6, 'Rare', 1.2), // Blue
  epic(0xFF8B5CF6, 'Epic', 1.5), // Purple
  legendary(0xFFF59E0B, 'Legendary', 2.0); // Gold

  final int colorValue;
  final String displayName;
  final double xpMultiplier;

  const AchievementRarity(this.colorValue, this.displayName, this.xpMultiplier);
}

class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon; // emoji หรือ asset path
  final AchievementCategory category;
  final AchievementRarity rarity;
  final int xpReward;
  final bool isSecret;
  final int? targetValue; // ค่าเป้าหมาย (ถ้ามี)

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.rarity,
    required this.xpReward,
    this.isSecret = false,
    this.targetValue,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        icon,
        category,
        rarity,
        xpReward,
        isSecret,
        targetValue
      ];
}

/// ข้อมูล Achievement ที่ปลดล็อคแล้ว
class UnlockedAchievement extends Equatable {
  final String achievementId;
  final DateTime unlockedAt;

  const UnlockedAchievement({
    required this.achievementId,
    required this.unlockedAt,
  });

  factory UnlockedAchievement.fromJson(Map<String, dynamic> json) {
    return UnlockedAchievement(
      achievementId: json['achievementId'] as String,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'unlockedAt': unlockedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [achievementId, unlockedAt];
}
