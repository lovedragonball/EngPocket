/// ExamPack - Entity สำหรับข้อมูลชุดข้อสอบหนึ่งชุด
library;

import 'package:equatable/equatable.dart';

/// ประเภทข้อสอบ
enum ExamType {
  tgat,
  aLevel,
  general;

  static ExamType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'TGAT':
        return ExamType.tgat;
      case 'A-LEVEL':
      case 'ALEVEL':
        return ExamType.aLevel;
      default:
        return ExamType.general;
    }
  }

  String toDisplayString() {
    switch (this) {
      case ExamType.tgat:
        return 'TGAT';
      case ExamType.aLevel:
        return 'A-Level';
      case ExamType.general:
        return 'General';
    }
  }
}

/// ระดับความยาก
enum Difficulty {
  easy,
  medium,
  hard;

  static Difficulty fromString(String value) {
    return Difficulty.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => Difficulty.medium,
    );
  }

  String toDisplayString() {
    switch (this) {
      case Difficulty.easy:
        return 'ง่าย';
      case Difficulty.medium:
        return 'ปานกลาง';
      case Difficulty.hard:
        return 'ยาก';
    }
  }
}

class ExamPack extends Equatable {
  final String id;
  final String name;              // เช่น "TGAT Mock 1"
  final String description;
  final ExamType examType;
  final int numQuestions;
  final Difficulty difficulty;
  final int version;
  final String? remoteUrl;        // เผื่ออนาคตโหลดจาก server

  const ExamPack({
    required this.id,
    required this.name,
    required this.description,
    required this.examType,
    required this.numQuestions,
    required this.difficulty,
    required this.version,
    this.remoteUrl,
  });

  factory ExamPack.fromJson(Map<String, dynamic> json) {
    return ExamPack(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      examType: ExamType.fromString(json['examType'] as String),
      numQuestions: json['numQuestions'] as int,
      difficulty: Difficulty.fromString(json['difficulty'] as String),
      version: json['version'] as int,
      remoteUrl: json['remoteUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'examType': examType.name,
      'numQuestions': numQuestions,
      'difficulty': difficulty.name,
      'version': version,
      'remoteUrl': remoteUrl,
    };
  }

  @override
  List<Object?> get props => [id, name, description, examType, 
                               numQuestions, difficulty, version, remoteUrl];
}
