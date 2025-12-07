/// ProgressRecord - Entity สำหรับเก็บสถิติการเรียนรู้ของผู้ใช้
library;

import 'package:equatable/equatable.dart';
import 'exam_result.dart';

/// ระดับความชำนาญของคำศัพท์
enum MasteryLevel {
  newWord, // ยังไม่เคยเรียน
  learning, // กำลังเรียนรู้
  mastered; // จำได้แล้ว

  static MasteryLevel fromString(String value) {
    switch (value) {
      case 'new':
      case 'newWord':
        return MasteryLevel.newWord;
      case 'learning':
        return MasteryLevel.learning;
      case 'mastered':
        return MasteryLevel.mastered;
      default:
        return MasteryLevel.newWord;
    }
  }

  String toDisplayString() {
    switch (this) {
      case MasteryLevel.newWord:
        return 'ใหม่';
      case MasteryLevel.learning:
        return 'กำลังเรียน';
      case MasteryLevel.mastered:
        return 'จำได้แล้ว';
    }
  }
}

class ProgressRecord extends Equatable {
  final DateTime lastUpdated;
  final Map<String, MasteryLevel> vocabMastery; // vocabId -> mastery level
  final List<ExamResult> examHistory;
  final int totalStudyDays;
  final int currentStreak;

  const ProgressRecord({
    required this.lastUpdated,
    required this.vocabMastery,
    required this.examHistory,
    this.totalStudyDays = 0,
    this.currentStreak = 0,
  });

  /// สร้าง ProgressRecord ว่างสำหรับผู้ใช้ใหม่
  factory ProgressRecord.empty() {
    return ProgressRecord(
      lastUpdated: DateTime.now(),
      vocabMastery: const {},
      examHistory: const [],
      totalStudyDays: 0,
      currentStreak: 0,
    );
  }

  /// นับจำนวนคำศัพท์ตาม mastery level
  int countByMastery(MasteryLevel level) {
    return vocabMastery.values.where((m) => m == level).length;
  }

  /// จำนวนคำศัพท์ใหม่
  int get newWordsCount => countByMastery(MasteryLevel.newWord);

  /// จำนวนคำศัพท์กำลังเรียน
  int get learningCount => countByMastery(MasteryLevel.learning);

  /// จำนวนคำศัพท์ที่จำได้แล้ว
  int get masteredCount => countByMastery(MasteryLevel.mastered);

  /// คะแนนเฉลี่ยจากการสอบทั้งหมด
  double get averageExamScore {
    if (examHistory.isEmpty) return 0;
    final total = examHistory.fold<double>(
      0,
      (sum, result) => sum + result.percentage,
    );
    return total / examHistory.length;
  }

  /// Copy with updated values
  ProgressRecord copyWith({
    DateTime? lastUpdated,
    Map<String, MasteryLevel>? vocabMastery,
    List<ExamResult>? examHistory,
    int? totalStudyDays,
    int? currentStreak,
  }) {
    return ProgressRecord(
      lastUpdated: lastUpdated ?? this.lastUpdated,
      vocabMastery: vocabMastery ?? this.vocabMastery,
      examHistory: examHistory ?? this.examHistory,
      totalStudyDays: totalStudyDays ?? this.totalStudyDays,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }

  factory ProgressRecord.fromJson(Map<String, dynamic> json) {
    final masteryMap = <String, MasteryLevel>{};
    final masteryJson = json['vocabMastery'] as Map<String, dynamic>? ?? {};
    for (final entry in masteryJson.entries) {
      masteryMap[entry.key] = MasteryLevel.fromString(entry.value as String);
    }

    return ProgressRecord(
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      vocabMastery: masteryMap,
      examHistory: (json['examHistory'] as List? ?? [])
          .map((e) => ExamResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalStudyDays: json['totalStudyDays'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final masteryJson = <String, String>{};
    for (final entry in vocabMastery.entries) {
      masteryJson[entry.key] = entry.value.name;
    }

    return {
      'lastUpdated': lastUpdated.toIso8601String(),
      'vocabMastery': masteryJson,
      'examHistory': examHistory.map((e) => e.toJson()).toList(),
      'totalStudyDays': totalStudyDays,
      'currentStreak': currentStreak,
    };
  }

  @override
  List<Object?> get props =>
      [lastUpdated, vocabMastery, examHistory, totalStudyDays, currentStreak];
}
