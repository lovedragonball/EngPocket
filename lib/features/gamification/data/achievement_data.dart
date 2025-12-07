/// Achievement Data - รายการ Achievement ทั้งหมด
library;

import '../../../../core/models/achievement.dart';

/// รายการ Achievements ทั้งหมดในแอป
class AchievementData {
  AchievementData._();

  static const List<Achievement> all = [
    // ==================== Vocabulary Achievements ====================
    Achievement(
      id: 'vocab_first_10',
      title: 'First Steps',
      description: 'เรียนคำศัพท์ครบ 10 คำ',
      icon: '📚',
      category: AchievementCategory.vocabulary,
      rarity: AchievementRarity.common,
      xpReward: 50,
      targetValue: 10,
    ),
    Achievement(
      id: 'vocab_50',
      title: 'Bookworm',
      description: 'เรียนคำศัพท์ครบ 50 คำ',
      icon: '📖',
      category: AchievementCategory.vocabulary,
      rarity: AchievementRarity.common,
      xpReward: 100,
      targetValue: 50,
    ),
    Achievement(
      id: 'vocab_100',
      title: 'Century',
      description: 'เรียนคำศัพท์ครบ 100 คำ',
      icon: '💯',
      category: AchievementCategory.vocabulary,
      rarity: AchievementRarity.rare,
      xpReward: 250,
      targetValue: 100,
    ),
    Achievement(
      id: 'vocab_250',
      title: 'Vocabulary Builder',
      description: 'เรียนคำศัพท์ครบ 250 คำ',
      icon: '🏗️',
      category: AchievementCategory.vocabulary,
      rarity: AchievementRarity.rare,
      xpReward: 500,
      targetValue: 250,
    ),
    Achievement(
      id: 'vocab_500',
      title: 'Scholar',
      description: 'เรียนคำศัพท์ครบ 500 คำ',
      icon: '📕',
      category: AchievementCategory.vocabulary,
      rarity: AchievementRarity.epic,
      xpReward: 1000,
      targetValue: 500,
    ),
    Achievement(
      id: 'vocab_1000',
      title: 'Linguist',
      description: 'เรียนคำศัพท์ครบ 1,000 คำ',
      icon: '🎓',
      category: AchievementCategory.vocabulary,
      rarity: AchievementRarity.legendary,
      xpReward: 5000,
      targetValue: 1000,
    ),

    // ==================== Exam Achievements ====================
    Achievement(
      id: 'exam_first',
      title: 'Test Taker',
      description: 'ทำข้อสอบครั้งแรก',
      icon: '✏️',
      category: AchievementCategory.exam,
      rarity: AchievementRarity.common,
      xpReward: 30,
      targetValue: 1,
    ),
    Achievement(
      id: 'exam_5',
      title: 'Exam Regular',
      description: 'ทำข้อสอบครบ 5 ชุด',
      icon: '📋',
      category: AchievementCategory.exam,
      rarity: AchievementRarity.common,
      xpReward: 100,
      targetValue: 5,
    ),
    Achievement(
      id: 'exam_10',
      title: 'Exam Enthusiast',
      description: 'ทำข้อสอบครบ 10 ชุด',
      icon: '📝',
      category: AchievementCategory.exam,
      rarity: AchievementRarity.rare,
      xpReward: 250,
      targetValue: 10,
    ),
    Achievement(
      id: 'exam_25',
      title: 'Exam Expert',
      description: 'ทำข้อสอบครบ 25 ชุด',
      icon: '🎯',
      category: AchievementCategory.exam,
      rarity: AchievementRarity.epic,
      xpReward: 750,
      targetValue: 25,
    ),
    Achievement(
      id: 'exam_perfect',
      title: 'Perfect Score',
      description: 'ทำข้อสอบได้ 100%',
      icon: '💎',
      category: AchievementCategory.exam,
      rarity: AchievementRarity.rare,
      xpReward: 500,
      targetValue: 1,
    ),
    Achievement(
      id: 'exam_perfect_5',
      title: 'Perfectionist',
      description: 'ทำข้อสอบได้ 100% จำนวน 5 ครั้ง',
      icon: '🌟',
      category: AchievementCategory.exam,
      rarity: AchievementRarity.epic,
      xpReward: 1000,
      targetValue: 5,
    ),
    Achievement(
      id: 'exam_90_streak_3',
      title: 'Hot Streak',
      description: 'ทำข้อสอบได้ 90%+ ติดต่อกัน 3 ครั้ง',
      icon: '🔥',
      category: AchievementCategory.exam,
      rarity: AchievementRarity.epic,
      xpReward: 750,
      targetValue: 3,
    ),

    // ==================== Streak Achievements ====================
    Achievement(
      id: 'streak_3',
      title: 'Getting Started',
      description: 'Streak 3 วัน',
      icon: '🌱',
      category: AchievementCategory.streak,
      rarity: AchievementRarity.common,
      xpReward: 30,
      targetValue: 3,
    ),
    Achievement(
      id: 'streak_7',
      title: 'One Week',
      description: 'Streak 7 วัน',
      icon: '📅',
      category: AchievementCategory.streak,
      rarity: AchievementRarity.common,
      xpReward: 100,
      targetValue: 7,
    ),
    Achievement(
      id: 'streak_14',
      title: 'On Fire',
      description: 'Streak 14 วัน',
      icon: '🔥',
      category: AchievementCategory.streak,
      rarity: AchievementRarity.rare,
      xpReward: 250,
      targetValue: 14,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Dedicated',
      description: 'Streak 30 วัน',
      icon: '💪',
      category: AchievementCategory.streak,
      rarity: AchievementRarity.epic,
      xpReward: 500,
      targetValue: 30,
    ),
    Achievement(
      id: 'streak_60',
      title: 'Committed',
      description: 'Streak 60 วัน',
      icon: '🏃',
      category: AchievementCategory.streak,
      rarity: AchievementRarity.epic,
      xpReward: 1000,
      targetValue: 60,
    ),
    Achievement(
      id: 'streak_100',
      title: 'Legend',
      description: 'Streak 100 วัน',
      icon: '👑',
      category: AchievementCategory.streak,
      rarity: AchievementRarity.legendary,
      xpReward: 2000,
      targetValue: 100,
    ),
    Achievement(
      id: 'streak_365',
      title: 'Ultimate',
      description: 'Streak 365 วัน',
      icon: '🌟',
      category: AchievementCategory.streak,
      rarity: AchievementRarity.legendary,
      xpReward: 10000,
      targetValue: 365,
    ),

    // ==================== Level Achievements ====================
    Achievement(
      id: 'level_5',
      title: 'Rising Star',
      description: 'ถึง Level 5',
      icon: '⬆️',
      category: AchievementCategory.level,
      rarity: AchievementRarity.common,
      xpReward: 100,
      targetValue: 5,
    ),
    Achievement(
      id: 'level_10',
      title: 'Apprentice',
      description: 'ถึง Level 10',
      icon: '🌟',
      category: AchievementCategory.level,
      rarity: AchievementRarity.rare,
      xpReward: 300,
      targetValue: 10,
    ),
    Achievement(
      id: 'level_25',
      title: 'Expert',
      description: 'ถึง Level 25',
      icon: '💎',
      category: AchievementCategory.level,
      rarity: AchievementRarity.epic,
      xpReward: 750,
      targetValue: 25,
    ),
    Achievement(
      id: 'level_50',
      title: 'Master',
      description: 'ถึง Level 50',
      icon: '🏆',
      category: AchievementCategory.level,
      rarity: AchievementRarity.legendary,
      xpReward: 2500,
      targetValue: 50,
    ),

    // ==================== Reading Achievements ====================
    Achievement(
      id: 'reading_first',
      title: 'First Read',
      description: 'อ่านบทความแรก',
      icon: '📰',
      category: AchievementCategory.reading,
      rarity: AchievementRarity.common,
      xpReward: 30,
      targetValue: 1,
    ),
    Achievement(
      id: 'reading_5',
      title: 'Reader',
      description: 'อ่านบทความครบ 5 บท',
      icon: '📑',
      category: AchievementCategory.reading,
      rarity: AchievementRarity.common,
      xpReward: 100,
      targetValue: 5,
    ),
    Achievement(
      id: 'reading_10',
      title: 'Avid Reader',
      description: 'อ่านบทความครบ 10 บท',
      icon: '📚',
      category: AchievementCategory.reading,
      rarity: AchievementRarity.rare,
      xpReward: 200,
      targetValue: 10,
    ),
    Achievement(
      id: 'reading_25',
      title: 'Bookworm',
      description: 'อ่านบทความครบ 25 บท',
      icon: '🐛',
      category: AchievementCategory.reading,
      rarity: AchievementRarity.epic,
      xpReward: 500,
      targetValue: 25,
    ),

    // ==================== Grammar Achievements ====================
    Achievement(
      id: 'grammar_first',
      title: 'Grammar Starter',
      description: 'เรียน Grammar บทแรก',
      icon: '📐',
      category: AchievementCategory.grammar,
      rarity: AchievementRarity.common,
      xpReward: 30,
      targetValue: 1,
    ),
    Achievement(
      id: 'grammar_5',
      title: 'Grammar Learner',
      description: 'เรียน Grammar ครบ 5 บท',
      icon: '📏',
      category: AchievementCategory.grammar,
      rarity: AchievementRarity.common,
      xpReward: 100,
      targetValue: 5,
    ),
    Achievement(
      id: 'grammar_10',
      title: 'Grammar Expert',
      description: 'เรียน Grammar ครบ 10 บท',
      icon: '✏️',
      category: AchievementCategory.grammar,
      rarity: AchievementRarity.rare,
      xpReward: 250,
      targetValue: 10,
    ),
    Achievement(
      id: 'grammar_all',
      title: 'Grammar Guru',
      description: 'เรียน Grammar ครบทุกบท',
      icon: '📘',
      category: AchievementCategory.grammar,
      rarity: AchievementRarity.epic,
      xpReward: 1000,
    ),

    // ==================== Special Achievements ====================
    Achievement(
      id: 'xp_1000',
      title: 'XP Collector',
      description: 'รวบรวม 1,000 XP',
      icon: '💰',
      category: AchievementCategory.special,
      rarity: AchievementRarity.common,
      xpReward: 100,
      targetValue: 1000,
    ),
    Achievement(
      id: 'xp_5000',
      title: 'XP Hunter',
      description: 'รวบรวม 5,000 XP',
      icon: '💵',
      category: AchievementCategory.special,
      rarity: AchievementRarity.rare,
      xpReward: 300,
      targetValue: 5000,
    ),
    Achievement(
      id: 'xp_10000',
      title: 'XP Hoarder',
      description: 'รวบรวม 10,000 XP',
      icon: '💎',
      category: AchievementCategory.special,
      rarity: AchievementRarity.epic,
      xpReward: 500,
      targetValue: 10000,
    ),
    Achievement(
      id: 'quest_daily_7',
      title: 'Quest Master',
      description: 'ทำภารกิจรายวันครบ 7 วันติดต่อกัน',
      icon: '📋',
      category: AchievementCategory.special,
      rarity: AchievementRarity.rare,
      xpReward: 400,
      targetValue: 7,
    ),
    Achievement(
      id: 'night_owl',
      title: 'Night Owl',
      description: 'เรียนหลังเที่ยงคืน (00:00 - 05:00)',
      icon: '🦉',
      category: AchievementCategory.special,
      rarity: AchievementRarity.common,
      xpReward: 50,
      isSecret: true,
    ),
    Achievement(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'เรียนก่อน 6 โมงเช้า (05:00 - 06:00)',
      icon: '🐦',
      category: AchievementCategory.special,
      rarity: AchievementRarity.common,
      xpReward: 50,
      isSecret: true,
    ),
    Achievement(
      id: 'weekend_warrior',
      title: 'Weekend Warrior',
      description: 'เรียนทุกวันเสาร์-อาทิตย์ใน 1 เดือน',
      icon: '⚔️',
      category: AchievementCategory.special,
      rarity: AchievementRarity.rare,
      xpReward: 300,
      isSecret: true,
    ),
    Achievement(
      id: 'comeback_kid',
      title: 'Comeback Kid',
      description: 'กลับมาเรียนหลังหายไป 7 วัน',
      icon: '🔄',
      category: AchievementCategory.special,
      rarity: AchievementRarity.common,
      xpReward: 50,
      isSecret: true,
    ),
  ];

  /// ดึง achievement ตาม id
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// ดึง achievements ตาม category
  static List<Achievement> getByCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }

  /// ดึง achievements ตาม rarity
  static List<Achievement> getByRarity(AchievementRarity rarity) {
    return all.where((a) => a.rarity == rarity).toList();
  }

  /// ดึงเฉพาะ achievements ที่ไม่ใช่ secret
  static List<Achievement> getPublic() {
    return all.where((a) => !a.isSecret).toList();
  }

  /// จำนวน achievements ทั้งหมด
  static int get count => all.length;
}
