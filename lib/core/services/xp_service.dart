/// XP Service - จัดการระบบ XP และ Level
library;

import 'dart:async';
import '../db/local_storage.dart';
import '../models/user_gamification.dart';

/// แหล่งที่มาของ XP
enum XpSource {
  vocabLearned('เรียนคำศัพท์', 10),
  vocabSession('ท่องศัพท์จบ 1 รอบ', 25),
  quizComplete('ทำ Quiz เสร็จ', 30),
  examComplete('ทำข้อสอบเสร็จ', 100),
  readingComplete('อ่าน Reading จบ', 40),
  grammarComplete('เรียน Grammar จบ', 35),
  streakBonus('Streak Bonus', 15),
  questComplete('ทำภารกิจเสร็จ', 0), // XP จะถูกกำหนดตาม quest
  achievementUnlock('ปลดล็อค Achievement', 0), // XP จะถูกกำหนดตาม achievement
  dailyLogin('เข้าใช้งานประจำวัน', 5);

  final String description;
  final int baseXp;

  const XpSource(this.description, this.baseXp);
}

/// ผลลัพธ์จากการเพิ่ม XP
class XpGainResult {
  final int xpGained;
  final int totalXp;
  final int previousLevel;
  final int newLevel;
  final bool didLevelUp;
  final XpSource source;

  const XpGainResult({
    required this.xpGained,
    required this.totalXp,
    required this.previousLevel,
    required this.newLevel,
    required this.didLevelUp,
    required this.source,
  });
}

class XpService {
  static XpService? _instance;

  XpService._();

  static XpService get instance {
    _instance ??= XpService._();
    return _instance!;
  }

  UserGamification? _cachedData;

  // Stream controller สำหรับ broadcast XP changes
  final _xpGainController = StreamController<XpGainResult>.broadcast();
  Stream<XpGainResult> get onXpGain => _xpGainController.stream;

  final _levelUpController = StreamController<int>.broadcast();
  Stream<int> get onLevelUp => _levelUpController.stream;

  /// โหลดข้อมูล gamification
  Future<UserGamification> loadData() async {
    if (_cachedData != null) return _cachedData!;

    final json = await LocalStorage.instance.get<Map<String, dynamic>>(
      'gamification_box',
      'user_gamification',
    );

    if (json == null) {
      _cachedData = UserGamification.empty();
    } else {
      _cachedData = UserGamification.fromJson(Map<String, dynamic>.from(json));
    }

    return _cachedData!;
  }

  /// บันทึกข้อมูล gamification
  Future<void> saveData(UserGamification data) async {
    _cachedData = data;
    await LocalStorage.instance.put(
      'gamification_box',
      'user_gamification',
      data.toJson(),
    );
  }

  /// คำนวณ level จาก XP รวม
  /// สูตร: XP required = Level² × 100
  int calculateLevel(int totalXp) {
    if (totalXp <= 0) return 0;

    int level = 0;
    int xpRequired = 0;

    while (true) {
      xpRequired = (level + 1) * (level + 1) * 100;
      if (totalXp < xpRequired) break;
      level++;
    }

    return level;
  }

  /// คำนวณ XP ที่ต้องการสำหรับ level ถัดไป
  int getXpForLevel(int level) {
    return (level + 1) * (level + 1) * 100;
  }

  /// คำนวณ XP ที่ต้องการจาก level 0 ถึง level ที่กำหนด
  int getTotalXpForLevel(int level) {
    if (level <= 0) return 0;
    return level * level * 100;
  }

  /// เพิ่ม XP จากกิจกรรม
  Future<XpGainResult> addXp(XpSource source,
      {int? customAmount, double? bonusMultiplier}) async {
    final data = await loadData();
    final previousLevel = data.currentLevel;

    int xpToAdd = customAmount ?? source.baseXp;

    // Apply bonus multiplier ถ้ามี
    if (bonusMultiplier != null && bonusMultiplier > 1.0) {
      xpToAdd = (xpToAdd * bonusMultiplier).round();
    }

    final newTotalXp = data.totalXp + xpToAdd;
    final newLevel = calculateLevel(newTotalXp);
    final didLevelUp = newLevel > previousLevel;

    final updatedData = data.copyWith(
      totalXp: newTotalXp,
      currentLevel: newLevel,
    );

    await saveData(updatedData);

    final result = XpGainResult(
      xpGained: xpToAdd,
      totalXp: newTotalXp,
      previousLevel: previousLevel,
      newLevel: newLevel,
      didLevelUp: didLevelUp,
      source: source,
    );

    // Broadcast XP gain event
    _xpGainController.add(result);

    // Broadcast level up event ถ้า level up
    if (didLevelUp) {
      _levelUpController.add(newLevel);
    }

    return result;
  }

  /// เพิ่ม XP จากคะแนนสอบ
  Future<XpGainResult> addExamXp(double percentage) async {
    // Base XP + bonus จาก percentage
    final bonusXp = (percentage * 1).round();
    final totalXp = XpSource.examComplete.baseXp + bonusXp;

    return addXp(XpSource.examComplete, customAmount: totalXp);
  }

  /// เพิ่ม XP จาก Quiz
  Future<XpGainResult> addQuizXp(double percentage) async {
    // Base XP + bonus จาก percentage
    final bonusXp = (percentage * 0.5).round();
    final totalXp = XpSource.quizComplete.baseXp + bonusXp;

    return addXp(XpSource.quizComplete, customAmount: totalXp);
  }

  /// ดึงข้อมูล XP และ Level ปัจจุบัน
  Future<({int xp, int level, double progress, LevelTitle title})>
      getCurrentStats() async {
    final data = await loadData();
    return (
      xp: data.totalXp,
      level: data.currentLevel,
      progress: data.levelProgress,
      title: data.levelTitle,
    );
  }

  /// Clear cache
  void clearCache() {
    _cachedData = null;
  }

  /// Dispose streams
  void dispose() {
    _xpGainController.close();
    _levelUpController.close();
  }
}
