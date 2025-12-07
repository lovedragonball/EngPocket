/// Vocab Quiz Service - โหลดคำศัพท์และเก็บสถิติ
library;

import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../db/local_storage.dart';
import '../models/vocab_item.dart';

/// สถิติการเล่น Vocab Quiz
class VocabQuizStats {
  final int totalPlayed;
  final int totalCorrect;
  final int totalWrong;
  final DateTime? lastPlayedAt;

  const VocabQuizStats({
    this.totalPlayed = 0,
    this.totalCorrect = 0,
    this.totalWrong = 0,
    this.lastPlayedAt,
  });

  /// คำนวณอัตราความถูกต้อง
  double get accuracy {
    final total = totalCorrect + totalWrong;
    if (total == 0) return 0;
    return (totalCorrect / total) * 100;
  }

  /// สร้างจาก JSON
  factory VocabQuizStats.fromJson(Map<String, dynamic> json) {
    return VocabQuizStats(
      totalPlayed: json['totalPlayed'] ?? 0,
      totalCorrect: json['totalCorrect'] ?? 0,
      totalWrong: json['totalWrong'] ?? 0,
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.parse(json['lastPlayedAt'])
          : null,
    );
  }

  /// แปลงเป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'totalPlayed': totalPlayed,
      'totalCorrect': totalCorrect,
      'totalWrong': totalWrong,
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
    };
  }

  /// สร้าง copy พร้อมอัพเดทค่า
  VocabQuizStats copyWith({
    int? totalPlayed,
    int? totalCorrect,
    int? totalWrong,
    DateTime? lastPlayedAt,
  }) {
    return VocabQuizStats(
      totalPlayed: totalPlayed ?? this.totalPlayed,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalWrong: totalWrong ?? this.totalWrong,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }
}

/// Service สำหรับ Vocab Quiz
class VocabQuizService {
  static const String _statsKey = 'vocab_quiz_stats';
  static const String _statsBoxName = 'vocab_quiz_box';

  // จำนวน vocab files ที่มีอยู่ (vocab_part1.json - vocab_part101.json)
  static const int _totalVocabFiles = 101;
  // จำนวนคำต่อไฟล์โดยประมาณ
  static const int _wordsPerFile = 100;

  final Random _random = Random();

  /// สุ่มเลือกไฟล์ vocab
  List<int> _getRandomFileNumbers(int count) {
    final allNumbers = List.generate(_totalVocabFiles, (i) => i + 1);
    allNumbers.shuffle(_random);
    return allNumbers.take(count).toList();
  }

  /// โหลดคำศัพท์สำหรับ Quiz
  /// [questionCount] - จำนวนคำถาม
  /// [distractorMultiplier] - จำนวนไฟล์ที่โหลดเพิ่มสำหรับ distractor (default: 3)
  Future<VocabQuizData> loadQuizData({
    int questionCount = 10,
    int distractorMultiplier = 3,
  }) async {
    // คำนวณจำนวนไฟล์ที่ต้องโหลด
    // เช่น 10 คำถาม ต้องการ distractor 3 เท่า = 30 คำขั้นต่ำ
    final minWords = questionCount * (1 + distractorMultiplier);
    final filesToLoad = (minWords / _wordsPerFile).ceil().clamp(2, 5);

    final fileNumbers = _getRandomFileNumbers(filesToLoad);

    final List<VocabItem> allVocab = [];
    final Set<String> usedTranslations = {}; // เก็บ translation ที่ใช้ไปแล้ว

    for (final num in fileNumbers) {
      try {
        final file = 'assets/data/vocab_part$num.json';
        final String jsonString = await rootBundle.loadString(file);
        final List<dynamic> jsonList = json.decode(jsonString);

        for (final item in jsonList) {
          final translation = item['translation']?.toString() ?? '';

          // ข้าม translation ที่ซ้ำกัน
          if (translation.isEmpty || usedTranslations.contains(translation)) {
            continue;
          }

          usedTranslations.add(translation);

          allVocab.add(VocabItem(
            id: item['id']?.toString() ?? 'v${allVocab.length}',
            word: item['word']?.toString() ?? '',
            translation: translation,
            partOfSpeech: item['pos']?.toString() ??
                item['partOfSpeech']?.toString() ??
                'noun',
            exampleEn: item['example']?.toString() ??
                item['exampleEn']?.toString() ??
                '',
            exampleTh: item['exampleTh']?.toString() ?? '',
            level: item['level']?.toString() ?? 'basic',
            packId: 'VOCAB_POOL',
            tags: const [],
          ));
        }
      } catch (e) {
        // ข้ามไฟล์ที่โหลดไม่ได้
        continue;
      }
    }

    // Shuffle และแยกข้อมูล
    allVocab.shuffle(_random);

    // เลือกคำสำหรับคำถาม
    final quizVocab = allVocab.take(questionCount).toList();

    return VocabQuizData(
      quizVocab: quizVocab,
      distractorPool: allVocab, // ใช้ทั้งหมดเป็น distractor pool
    );
  }

  /// โหลดสถิติ
  Future<VocabQuizStats> loadStats() async {
    try {
      final data = await LocalStorage.instance.get<Map>(
        _statsBoxName,
        _statsKey,
      );
      if (data != null) {
        return VocabQuizStats.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      // ไม่มีข้อมูล
    }
    return const VocabQuizStats();
  }

  /// บันทึกสถิติ
  Future<void> saveStats(VocabQuizStats stats) async {
    await LocalStorage.instance.put(
      _statsBoxName,
      _statsKey,
      stats.toJson(),
    );
  }

  /// อัพเดทสถิติหลังเล่นจบ
  Future<VocabQuizStats> updateStatsAfterGame({
    required int correctCount,
    required int wrongCount,
  }) async {
    final currentStats = await loadStats();

    final newStats = currentStats.copyWith(
      totalPlayed: currentStats.totalPlayed + 1,
      totalCorrect: currentStats.totalCorrect + correctCount,
      totalWrong: currentStats.totalWrong + wrongCount,
      lastPlayedAt: DateTime.now(),
    );

    await saveStats(newStats);
    return newStats;
  }
}

/// ข้อมูลสำหรับ Quiz
class VocabQuizData {
  final List<VocabItem> quizVocab;
  final List<VocabItem> distractorPool;

  const VocabQuizData({
    required this.quizVocab,
    required this.distractorPool,
  });
}
