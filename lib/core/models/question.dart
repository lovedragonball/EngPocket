/// Question - Entity สำหรับข้อสอบ/quiz
///
/// ใช้ได้ทั้งใน Grammar Quiz และ Exam
library;

import 'package:equatable/equatable.dart';

/// ระดับความยากของแบบทดสอบ
enum QuizDifficulty {
  easy,
  medium,
  hard;

  String get label => switch (this) {
        easy => 'ง่าย',
        medium => 'ปานกลาง',
        hard => 'ยาก',
      };

  String get emoji => switch (this) {
        easy => '😊',
        medium => '🤔',
        hard => '😤',
      };

  static QuizDifficulty fromString(String value) {
    return QuizDifficulty.values.firstWhere(
      (e) => e.name == value,
      orElse: () => QuizDifficulty.medium,
    );
  }
}

/// ประเภททักษะของคำถาม
enum SkillType {
  vocab,
  grammar,
  reading,
  cloze;

  static SkillType fromString(String value) {
    return SkillType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SkillType.vocab,
    );
  }
}

class Question extends Equatable {
  final String id;
  final String stem; // ข้อคำถาม / โจทย์
  final List<String> choices; // ตัวเลือก
  final int correctIndex; // index ของคำตอบที่ถูก (0-based)
  final String explanation; // เฉลยแบบอธิบาย
  final SkillType skillType; // vocab, grammar, reading, cloze
  final String packId; // ข้อสอบแพ็กไหน

  const Question({
    required this.id,
    required this.stem,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
    required this.skillType,
    required this.packId,
  });

  /// ตรวจว่าคำตอบถูกหรือไม่
  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;

  /// ดึงตัวเลือกที่ถูกต้อง
  String get correctAnswer => choices[correctIndex];

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      stem: json['stem'] as String,
      choices: List<String>.from(json['choices'] as List),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String,
      skillType: SkillType.fromString(json['skillType'] as String),
      packId: json['packId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stem': stem,
      'choices': choices,
      'correctIndex': correctIndex,
      'explanation': explanation,
      'skillType': skillType.name,
      'packId': packId,
    };
  }

  @override
  List<Object?> get props =>
      [id, stem, choices, correctIndex, explanation, skillType, packId];
}
