/// Daily Vocab Service - จัดการคำศัพท์ประจำวันและ Progress
library;

import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vocab_item.dart';

/// ระดับความยากสำหรับคำศัพท์ประจำวัน
enum VocabDifficulty {
  easy, // basic - สำหรับมือใหม่
  medium, // intermediate - ใช้บ่อย (default)
  hard, // advanced - ท้าทาย
}

/// สถานะ progress การท่องศัพท์
class DailyVocabProgress {
  final String date;
  final List<String> vocabIds;
  final int currentIndex;
  final bool isCompleted;
  final List<String> learnedIds;

  const DailyVocabProgress({
    required this.date,
    required this.vocabIds,
    this.currentIndex = 0,
    this.isCompleted = false,
    this.learnedIds = const [],
  });

  factory DailyVocabProgress.fromJson(Map<String, dynamic> json) {
    return DailyVocabProgress(
      date: json['date'] ?? '',
      vocabIds: List<String>.from(json['vocabIds'] ?? []),
      currentIndex: json['currentIndex'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      learnedIds: List<String>.from(json['learnedIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'vocabIds': vocabIds,
      'currentIndex': currentIndex,
      'isCompleted': isCompleted,
      'learnedIds': learnedIds,
    };
  }

  DailyVocabProgress copyWith({
    String? date,
    List<String>? vocabIds,
    int? currentIndex,
    bool? isCompleted,
    List<String>? learnedIds,
  }) {
    return DailyVocabProgress(
      date: date ?? this.date,
      vocabIds: vocabIds ?? this.vocabIds,
      currentIndex: currentIndex ?? this.currentIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      learnedIds: learnedIds ?? this.learnedIds,
    );
  }
}

/// Service จัดการคำศัพท์ประจำวัน
class DailyVocabService {
  static const String _progressKey = 'daily_vocab_progress';
  static const String _usedVocabKey = 'used_vocab_ids';
  static const int _maxUsedVocabHistory = 500; // จำกัดประวัติคำที่ใช้ไปแล้ว

  final Random _random = Random();

  /// โหลด progress ปัจจุบัน
  Future<DailyVocabProgress?> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_progressKey);
    if (data == null) return null;

    try {
      final json = jsonDecode(data);
      return DailyVocabProgress.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// บันทึก progress
  Future<void> saveProgress(DailyVocabProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(progress.toJson()));
  }

  /// โหลดรายการ vocab IDs ที่ใช้ไปแล้ว
  Future<Set<String>> loadUsedVocabIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_usedVocabKey) ?? [];
    return list.toSet();
  }

  /// บันทึก vocab ID ที่ใช้ไปแล้ว
  Future<void> markVocabAsUsed(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_usedVocabKey) ?? [];

    // รวมกับ IDs ใหม่
    final allIds = {...existing, ...ids}.toList();

    // จำกัดประวัติ - ถ้าเกินให้ลบอันเก่าออก
    if (allIds.length > _maxUsedVocabHistory) {
      allIds.removeRange(0, allIds.length - _maxUsedVocabHistory);
    }

    await prefs.setStringList(_usedVocabKey, allIds);
  }

  /// ตรวจสอบว่าวันนี้ต้องสร้างคำศัพท์ใหม่หรือไม่
  Future<bool> needsNewDailyVocab() async {
    final progress = await loadProgress();
    if (progress == null) return true;

    final today = _getTodayString();
    return progress.date != today;
  }

  /// สร้างคำศัพท์ประจำวันใหม่
  Future<DailyVocabProgress> generateDailyVocab({
    required int count,
    VocabDifficulty difficulty = VocabDifficulty.medium,
  }) async {
    final today = _getTodayString();
    final usedIds = await loadUsedVocabIds();

    // โหลดคำศัพท์ที่ไม่ซ้ำกับที่ใช้ไปแล้ว
    final vocab = await _loadFilteredVocab(
      usedIds: usedIds,
      difficulty: difficulty,
      count: count,
    );

    final progress = DailyVocabProgress(
      date: today,
      vocabIds: vocab.map((v) => v.id).toList(),
      currentIndex: 0,
      isCompleted: false,
      learnedIds: [],
    );

    await saveProgress(progress);
    return progress;
  }

  /// โหลดคำศัพท์ประจำวัน (สร้างใหม่ถ้าจำเป็น)
  Future<List<VocabItem>> getDailyVocab({
    required int count,
    VocabDifficulty difficulty = VocabDifficulty.medium,
  }) async {
    // ตรวจสอบว่าต้องสร้างใหม่หรือไม่
    if (await needsNewDailyVocab()) {
      await generateDailyVocab(count: count, difficulty: difficulty);
    }

    final progress = await loadProgress();
    if (progress == null || progress.vocabIds.isEmpty) {
      return [];
    }

    // โหลดคำศัพท์ตาม IDs
    return _loadVocabByIds(progress.vocabIds);
  }

  /// อัพเดท progress เมื่อท่องเสร็จแต่ละคำ
  Future<DailyVocabProgress> markWordLearned(String vocabId) async {
    final progress = await loadProgress();
    if (progress == null) {
      throw Exception('No progress found');
    }

    final learnedIds = [...progress.learnedIds];
    if (!learnedIds.contains(vocabId)) {
      learnedIds.add(vocabId);
    }

    final newIndex =
        (progress.currentIndex + 1).clamp(0, progress.vocabIds.length - 1);
    final isCompleted = learnedIds.length >= progress.vocabIds.length;

    final updated = progress.copyWith(
      currentIndex: newIndex,
      learnedIds: learnedIds,
      isCompleted: isCompleted,
    );

    await saveProgress(updated);

    // ถ้าเสร็จแล้ว บันทึกว่าใช้คำเหล่านี้ไปแล้ว
    if (isCompleted) {
      await markVocabAsUsed(progress.vocabIds);
    }

    return updated;
  }

  /// โหลดคำศัพท์ที่กรองแล้ว
  Future<List<VocabItem>> _loadFilteredVocab({
    required Set<String> usedIds,
    required VocabDifficulty difficulty,
    required int count,
  }) async {
    final List<VocabItem> allVocab = [];

    // กำหนด level ตาม difficulty
    final targetLevels = _getLevelsForDifficulty(difficulty);

    // สุ่มเลือก 5 ไฟล์
    final fileNumbers = List.generate(101, (i) => i + 1);
    fileNumbers.shuffle(_random);
    final selectedFiles = fileNumbers.take(5).toList();

    for (final num in selectedFiles) {
      try {
        final file = 'assets/data/vocab_part$num.json';
        final String jsonString = await rootBundle.loadString(file);
        final List<dynamic> jsonList = jsonDecode(jsonString);

        for (final item in jsonList) {
          final id = item['id']?.toString() ?? '';
          final level = item['level']?.toString() ?? 'basic';

          // ข้าม IDs ที่ใช้ไปแล้ว
          if (usedIds.contains(id)) continue;

          // กรอง level
          if (!targetLevels.contains(level)) continue;

          allVocab.add(VocabItem(
            id: id,
            word: item['word']?.toString() ?? '',
            translation: item['translation']?.toString() ?? '',
            partOfSpeech: item['pos']?.toString() ??
                item['partOfSpeech']?.toString() ??
                'noun',
            exampleEn: item['example']?.toString() ??
                item['exampleEn']?.toString() ??
                '',
            exampleTh: item['exampleTh']?.toString() ?? '',
            level: level,
            packId: 'DAILY',
            tags: const [],
          ));
        }
      } catch (e) {
        continue;
      }
    }

    // Shuffle และเลือกตามจำนวนที่ต้องการ
    allVocab.shuffle(_random);
    return allVocab.take(count).toList();
  }

  /// โหลดคำศัพท์ตาม IDs
  Future<List<VocabItem>> _loadVocabByIds(List<String> ids) async {
    final Map<String, VocabItem> vocabMap = {};

    // โหลดจากไฟล์ต่างๆ
    for (int num = 1; num <= 101; num++) {
      if (vocabMap.length >= ids.length) break;

      try {
        final file = 'assets/data/vocab_part$num.json';
        final String jsonString = await rootBundle.loadString(file);
        final List<dynamic> jsonList = jsonDecode(jsonString);

        for (final item in jsonList) {
          final id = item['id']?.toString() ?? '';

          if (ids.contains(id) && !vocabMap.containsKey(id)) {
            vocabMap[id] = VocabItem(
              id: id,
              word: item['word']?.toString() ?? '',
              translation: item['translation']?.toString() ?? '',
              partOfSpeech: item['pos']?.toString() ??
                  item['partOfSpeech']?.toString() ??
                  'noun',
              exampleEn: item['example']?.toString() ??
                  item['exampleEn']?.toString() ??
                  '',
              exampleTh: item['exampleTh']?.toString() ?? '',
              level: item['level']?.toString() ?? 'basic',
              packId: 'DAILY',
              tags: const [],
            );
          }
        }
      } catch (e) {
        continue;
      }
    }

    // เรียงลำดับตาม ids
    return ids
        .where((id) => vocabMap.containsKey(id))
        .map((id) => vocabMap[id]!)
        .toList();
  }

  /// ได้ levels ตาม difficulty
  List<String> _getLevelsForDifficulty(VocabDifficulty difficulty) {
    switch (difficulty) {
      case VocabDifficulty.easy:
        return ['basic'];
      case VocabDifficulty.medium:
        return ['basic', 'intermediate']; // ผสมกัน - ใช้บ่อย
      case VocabDifficulty.hard:
        return ['intermediate', 'advanced'];
    }
  }

  String _getTodayString() {
    return DateTime.now().toIso8601String().substring(0, 10);
  }
}
