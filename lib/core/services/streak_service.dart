/// Streak Service - จัดการระบบ Streak
library;

import 'dart:async';

import 'xp_service.dart';

/// Milestone ของ Streak
class StreakMilestone {
  final int days;
  final String title;
  final String emoji;
  final int xpReward;

  const StreakMilestone({
    required this.days,
    required this.title,
    required this.emoji,
    required this.xpReward,
  });
}

/// ผลลัพธ์จากการตรวจสอบ Streak
class StreakCheckResult {
  final int previousStreak;
  final int currentStreak;
  final bool streakIncreased;
  final bool streakReset;
  final StreakMilestone? reachedMilestone;
  final int streakBonusXp;

  const StreakCheckResult({
    required this.previousStreak,
    required this.currentStreak,
    required this.streakIncreased,
    required this.streakReset,
    this.reachedMilestone,
    required this.streakBonusXp,
  });
}

class StreakService {
  static StreakService? _instance;

  StreakService._();

  static StreakService get instance {
    _instance ??= StreakService._();
    return _instance!;
  }

  /// Streak Milestones
  static const List<StreakMilestone> milestones = [
    StreakMilestone(
        days: 3, title: 'Getting Started', emoji: '🌱', xpReward: 30),
    StreakMilestone(days: 7, title: 'One Week', emoji: '📅', xpReward: 100),
    StreakMilestone(days: 14, title: 'On Fire', emoji: '🔥', xpReward: 250),
    StreakMilestone(days: 30, title: 'Dedicated', emoji: '💪', xpReward: 500),
    StreakMilestone(days: 60, title: 'Committed', emoji: '🏃', xpReward: 1000),
    StreakMilestone(days: 100, title: 'Legend', emoji: '👑', xpReward: 2000),
    StreakMilestone(days: 365, title: 'Ultimate', emoji: '🌟', xpReward: 10000),
  ];

  // Stream controller สำหรับ broadcast streak changes
  final _streakController = StreamController<StreakCheckResult>.broadcast();
  Stream<StreakCheckResult> get onStreakChange => _streakController.stream;

  final _milestoneController = StreamController<StreakMilestone>.broadcast();
  Stream<StreakMilestone> get onMilestoneReached => _milestoneController.stream;

  /// ตรวจสอบและอัปเดต streak ประจำวัน
  Future<StreakCheckResult> checkAndUpdateStreak() async {
    final xpService = XpService.instance;
    final data = await xpService.loadData();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastActive = data.lastActiveDate;
    int newStreak = data.currentStreak;
    bool streakIncreased = false;
    bool streakReset = false;
    StreakMilestone? reachedMilestone;

    if (lastActive == null) {
      // ผู้ใช้ใหม่
      newStreak = 1;
      streakIncreased = true;
    } else {
      final lastActiveDay =
          DateTime(lastActive.year, lastActive.month, lastActive.day);
      final difference = today.difference(lastActiveDay).inDays;

      if (difference == 0) {
        // วันเดียวกัน - ไม่เปลี่ยนแปลง
      } else if (difference == 1) {
        // วันถัดไป - เพิ่ม streak
        newStreak = data.currentStreak + 1;
        streakIncreased = true;
      } else {
        // ขาดไปมากกว่า 1 วัน - reset streak
        newStreak = 1;
        streakReset = data.currentStreak > 0;
      }
    }

    // ตรวจสอบว่าถึง milestone หรือไม่
    if (streakIncreased) {
      for (final milestone in milestones) {
        if (newStreak == milestone.days) {
          reachedMilestone = milestone;
          break;
        }
      }
    }

    // อัปเดต longest streak
    final newLongestStreak =
        newStreak > data.longestStreak ? newStreak : data.longestStreak;

    // คำนวณ streak bonus XP
    int streakBonusXp = 0;
    if (streakIncreased) {
      streakBonusXp = _calculateStreakBonus(newStreak);

      // ให้ XP จาก milestone ด้วย
      if (reachedMilestone != null) {
        streakBonusXp += reachedMilestone.xpReward;
      }
    }

    // บันทึกข้อมูล
    final updatedData = data.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastActiveDate: now,
    );
    await xpService.saveData(updatedData);

    // ให้ XP bonus
    if (streakBonusXp > 0) {
      await xpService.addXp(XpSource.streakBonus, customAmount: streakBonusXp);
    }

    final result = StreakCheckResult(
      previousStreak: data.currentStreak,
      currentStreak: newStreak,
      streakIncreased: streakIncreased,
      streakReset: streakReset,
      reachedMilestone: reachedMilestone,
      streakBonusXp: streakBonusXp,
    );

    // Broadcast events
    _streakController.add(result);
    if (reachedMilestone != null) {
      _milestoneController.add(reachedMilestone);
    }

    return result;
  }

  /// คำนวณ streak bonus XP
  int _calculateStreakBonus(int streak) {
    // Base 15 XP + เพิ่มทุก 7 วัน (cap ที่ 50 XP)
    final bonus = 15 + ((streak ~/ 7) * 5);
    return bonus.clamp(15, 50);
  }

  /// ดึง milestone ถัดไป
  StreakMilestone? getNextMilestone(int currentStreak) {
    for (final milestone in milestones) {
      if (milestone.days > currentStreak) {
        return milestone;
      }
    }
    return null;
  }

  /// ดึง milestone ที่ผ่านมาแล้ว
  List<StreakMilestone> getReachedMilestones(int currentStreak) {
    return milestones.where((m) => m.days <= currentStreak).toList();
  }

  /// ดึงข้อมูล streak ปัจจุบัน
  Future<({int current, int longest, StreakMilestone? next})>
      getStreakInfo() async {
    final data = await XpService.instance.loadData();
    return (
      current: data.currentStreak,
      longest: data.longestStreak,
      next: getNextMilestone(data.currentStreak),
    );
  }

  /// Dispose streams
  void dispose() {
    _streakController.close();
    _milestoneController.close();
  }
}
