/// Quest Service - จัดการระบบภารกิจรายวัน/รายสัปดาห์
library;

import 'dart:async';
import '../models/quest.dart';
import '../../features/gamification/data/quest_data.dart';
import 'xp_service.dart';

/// ผลลัพธ์จากการทำภารกิจ
class QuestUpdateResult {
  final Quest quest;
  final int previousValue;
  final int currentValue;
  final bool justCompleted;
  final bool wasClaimed;

  const QuestUpdateResult({
    required this.quest,
    required this.previousValue,
    required this.currentValue,
    required this.justCompleted,
    required this.wasClaimed,
  });
}

class QuestService {
  static QuestService? _instance;

  QuestService._();

  static QuestService get instance {
    _instance ??= QuestService._();
    return _instance!;
  }

  // Stream controllers
  final _questUpdateController =
      StreamController<QuestUpdateResult>.broadcast();
  Stream<QuestUpdateResult> get onQuestUpdate => _questUpdateController.stream;

  final _questCompleteController = StreamController<Quest>.broadcast();
  Stream<Quest> get onQuestComplete => _questCompleteController.stream;

  /// ตรวจสอบและรีเซ็ตภารกิจถ้าจำเป็น
  Future<void> checkAndResetQuests() async {
    final xpService = XpService.instance;
    final data = await xpService.loadData();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool needsSave = false;
    var updatedProgress = Map<String, int>.from(data.questProgress);
    DateTime? newDailyReset = data.lastDailyReset;
    DateTime? newWeeklyReset = data.lastWeeklyReset;

    // ตรวจสอบ Daily Reset
    if (data.lastDailyReset == null ||
        DateTime(data.lastDailyReset!.year, data.lastDailyReset!.month,
                data.lastDailyReset!.day)
            .isBefore(today)) {
      // Reset daily quests
      for (final quest in QuestData.dailyQuests) {
        updatedProgress.remove(quest.id);
        updatedProgress.remove('${quest.id}_claimed');
      }
      newDailyReset = now;
      needsSave = true;
    }

    // ตรวจสอบ Weekly Reset (ทุกวันจันทร์)
    final lastMonday = today.subtract(Duration(days: today.weekday - 1));
    if (data.lastWeeklyReset == null ||
        DateTime(data.lastWeeklyReset!.year, data.lastWeeklyReset!.month,
                data.lastWeeklyReset!.day)
            .isBefore(lastMonday)) {
      // Reset weekly quests
      for (final quest in QuestData.weeklyQuests) {
        updatedProgress.remove(quest.id);
        updatedProgress.remove('${quest.id}_claimed');
      }
      newWeeklyReset = now;
      needsSave = true;
    }

    if (needsSave) {
      final updatedData = data.copyWith(
        questProgress: updatedProgress,
        lastDailyReset: newDailyReset,
        lastWeeklyReset: newWeeklyReset,
      );
      await xpService.saveData(updatedData);
    }
  }

  /// อัปเดต progress ของภารกิจตาม action
  Future<List<QuestUpdateResult>> updateQuestProgress(QuestAction action,
      {int amount = 1}) async {
    await checkAndResetQuests();

    final xpService = XpService.instance;
    final data = await xpService.loadData();

    final results = <QuestUpdateResult>[];
    var updatedProgress = Map<String, int>.from(data.questProgress);

    // หา quests ที่ตรงกับ action
    final matchingQuests =
        QuestData.all.where((q) => q.action == action).toList();

    for (final quest in matchingQuests) {
      final previousValue = updatedProgress[quest.id] ?? 0;
      final claimedKey = '${quest.id}_claimed';
      final alreadyClaimed = updatedProgress[claimedKey] == 1;

      if (alreadyClaimed) continue; // ข้ามถ้า claim แล้ว

      final newValue = (previousValue + amount).clamp(0, quest.targetValue);
      updatedProgress[quest.id] = newValue;

      final justCompleted =
          previousValue < quest.targetValue && newValue >= quest.targetValue;

      final result = QuestUpdateResult(
        quest: quest,
        previousValue: previousValue,
        currentValue: newValue,
        justCompleted: justCompleted,
        wasClaimed: false,
      );

      results.add(result);
      _questUpdateController.add(result);

      if (justCompleted) {
        _questCompleteController.add(quest);
      }
    }

    // บันทึกข้อมูล
    final updatedData = data.copyWith(questProgress: updatedProgress);
    await xpService.saveData(updatedData);

    return results;
  }

  /// Claim รางวัลจากภารกิจที่เสร็จแล้ว
  Future<int> claimQuestReward(String questId) async {
    final quest = QuestData.getById(questId);
    if (quest == null) return 0;

    final xpService = XpService.instance;
    final data = await xpService.loadData();

    final currentValue = data.questProgress[questId] ?? 0;
    final claimedKey = '${questId}_claimed';
    final alreadyClaimed = data.questProgress[claimedKey] == 1;

    // ตรวจสอบว่าทำเสร็จแล้วและยังไม่ claim
    if (currentValue >= quest.targetValue && !alreadyClaimed) {
      // Mark as claimed
      var updatedProgress = Map<String, int>.from(data.questProgress);
      updatedProgress[claimedKey] = 1;

      final updatedData = data.copyWith(questProgress: updatedProgress);
      await xpService.saveData(updatedData);

      // ให้ XP
      await xpService.addXp(XpSource.questComplete,
          customAmount: quest.xpReward);

      return quest.xpReward;
    }

    return 0;
  }

  /// ดึงข้อมูล progress ของ quest ทั้งหมด
  Future<List<({Quest quest, int current, bool completed, bool claimed})>>
      getAllQuestProgress() async {
    await checkAndResetQuests();

    final data = await XpService.instance.loadData();
    final results =
        <({Quest quest, int current, bool completed, bool claimed})>[];

    for (final quest in QuestData.all) {
      final current = data.questProgress[quest.id] ?? 0;
      final claimed = data.questProgress['${quest.id}_claimed'] == 1;

      results.add((
        quest: quest,
        current: current,
        completed: current >= quest.targetValue,
        claimed: claimed,
      ));
    }

    return results;
  }

  /// ดึงเฉพาะ daily quests
  Future<List<({Quest quest, int current, bool completed, bool claimed})>>
      getDailyQuestProgress() async {
    final all = await getAllQuestProgress();
    return all.where((q) => q.quest.type == QuestType.daily).toList();
  }

  /// ดึงเฉพาะ weekly quests
  Future<List<({Quest quest, int current, bool completed, bool claimed})>>
      getWeeklyQuestProgress() async {
    final all = await getAllQuestProgress();
    return all.where((q) => q.quest.type == QuestType.weekly).toList();
  }

  /// ดึงจำนวน quest ที่ทำเสร็จแล้ว
  Future<({int dailyDone, int dailyTotal, int weeklyDone, int weeklyTotal})>
      getQuestSummary() async {
    final all = await getAllQuestProgress();

    final daily = all.where((q) => q.quest.type == QuestType.daily).toList();
    final weekly = all.where((q) => q.quest.type == QuestType.weekly).toList();

    return (
      dailyDone: daily.where((q) => q.completed).length,
      dailyTotal: daily.length,
      weeklyDone: weekly.where((q) => q.completed).length,
      weeklyTotal: weekly.length,
    );
  }

  /// Dispose streams
  void dispose() {
    _questUpdateController.close();
    _questCompleteController.close();
  }
}
