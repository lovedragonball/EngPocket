/// Quest Data - รายการภารกิจรายวัน/รายสัปดาห์
library;

import '../../../../core/models/quest.dart';

/// รายการ Quests ทั้งหมดในแอป
class QuestData {
  QuestData._();

  /// ภารกิจรายวัน
  static const List<Quest> dailyQuests = [
    Quest(
      id: 'daily_vocab_10',
      title: 'ท่องศัพท์ประจำวัน',
      description: 'เรียนคำศัพท์ครบ 10 คำ',
      type: QuestType.daily,
      action: QuestAction.learnVocab,
      targetValue: 10,
      xpReward: 50,
      icon: '📖',
    ),
    Quest(
      id: 'daily_quiz_1',
      title: 'ทดสอบความรู้',
      description: 'ทำ Quiz 1 ครั้ง',
      type: QuestType.daily,
      action: QuestAction.completeQuiz,
      targetValue: 1,
      xpReward: 30,
      icon: '✅',
    ),
    Quest(
      id: 'daily_streak',
      title: 'รักษา Streak',
      description: 'เข้าใช้งานแอปวันนี้',
      type: QuestType.daily,
      action: QuestAction.maintainStreak,
      targetValue: 1,
      xpReward: 20,
      icon: '🔥',
    ),
  ];

  /// ภารกิจรายสัปดาห์
  static const List<Quest> weeklyQuests = [
    Quest(
      id: 'weekly_vocab_50',
      title: 'นักอ่านประจำ',
      description: 'เรียนคำศัพท์ครบ 50 คำ',
      type: QuestType.weekly,
      action: QuestAction.learnVocab,
      targetValue: 50,
      xpReward: 300,
      icon: '📚',
    ),
    Quest(
      id: 'weekly_exam_2',
      title: 'ท้าทายข้อสอบ',
      description: 'ทำข้อสอบครบ 2 ชุด',
      type: QuestType.weekly,
      action: QuestAction.completeExam,
      targetValue: 2,
      xpReward: 250,
      icon: '📝',
    ),
    Quest(
      id: 'weekly_reading_3',
      title: 'นักอ่านตัวยง',
      description: 'อ่าน Reading ครบ 3 บท',
      type: QuestType.weekly,
      action: QuestAction.readPassage,
      targetValue: 3,
      xpReward: 200,
      icon: '📖',
    ),
    Quest(
      id: 'weekly_grammar_3',
      title: 'เชี่ยวชาญไวยากรณ์',
      description: 'เรียน Grammar ครบ 3 บท',
      type: QuestType.weekly,
      action: QuestAction.learnGrammar,
      targetValue: 3,
      xpReward: 200,
      icon: '📗',
    ),
  ];

  /// ดึง quest ตาม id
  static Quest? getById(String id) {
    try {
      return [...dailyQuests, ...weeklyQuests].firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  /// ดึง quest ทั้งหมด
  static List<Quest> get all => [...dailyQuests, ...weeklyQuests];

  /// จำนวน quest ทั้งหมด
  static int get totalCount => dailyQuests.length + weeklyQuests.length;
}
