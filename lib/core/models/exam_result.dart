/// ExamResult - Entity สำหรับเก็บผลสอบของผู้ใช้
library;

import 'package:equatable/equatable.dart';

/// รายละเอียดคะแนนแยกตามประเภท
class ExamBreakdown extends Equatable {
  final int vocabCorrect;
  final int vocabTotal;
  final int grammarCorrect;
  final int grammarTotal;
  final int readingCorrect;
  final int readingTotal;

  const ExamBreakdown({
    required this.vocabCorrect,
    required this.vocabTotal,
    required this.grammarCorrect,
    required this.grammarTotal,
    required this.readingCorrect,
    required this.readingTotal,
  });

  /// เปอร์เซ็นต์คะแนน vocab
  double get vocabPercentage => 
      vocabTotal > 0 ? (vocabCorrect / vocabTotal) * 100 : 0;

  /// เปอร์เซ็นต์คะแนน grammar
  double get grammarPercentage => 
      grammarTotal > 0 ? (grammarCorrect / grammarTotal) * 100 : 0;

  /// เปอร์เซ็นต์คะแนน reading
  double get readingPercentage => 
      readingTotal > 0 ? (readingCorrect / readingTotal) * 100 : 0;

  factory ExamBreakdown.fromJson(Map<String, dynamic> json) {
    return ExamBreakdown(
      vocabCorrect: json['vocabCorrect'] as int,
      vocabTotal: json['vocabTotal'] as int,
      grammarCorrect: json['grammarCorrect'] as int,
      grammarTotal: json['grammarTotal'] as int,
      readingCorrect: json['readingCorrect'] as int,
      readingTotal: json['readingTotal'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vocabCorrect': vocabCorrect,
      'vocabTotal': vocabTotal,
      'grammarCorrect': grammarCorrect,
      'grammarTotal': grammarTotal,
      'readingCorrect': readingCorrect,
      'readingTotal': readingTotal,
    };
  }

  @override
  List<Object?> get props => [vocabCorrect, vocabTotal, grammarCorrect, 
                               grammarTotal, readingCorrect, readingTotal];
}

class ExamResult extends Equatable {
  final String id;
  final String examPackId;
  final int score;
  final int totalQuestions;
  final DateTime date;
  final ExamBreakdown breakdown;

  const ExamResult({
    required this.id,
    required this.examPackId,
    required this.score,
    required this.totalQuestions,
    required this.date,
    required this.breakdown,
  });

  /// เปอร์เซ็นต์คะแนนรวม
  double get percentage => 
      totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

  /// ระดับผลสอบ
  String get grade {
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['id'] as String,
      examPackId: json['examPackId'] as String,
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
      date: DateTime.parse(json['date'] as String),
      breakdown: ExamBreakdown.fromJson(json['breakdown'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'examPackId': examPackId,
      'score': score,
      'totalQuestions': totalQuestions,
      'date': date.toIso8601String(),
      'breakdown': breakdown.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, examPackId, score, totalQuestions, date, breakdown];
}
