/// Quest - Entity สำหรับภารกิจรายวัน/รายสัปดาห์
library;

import 'package:equatable/equatable.dart';

/// ประเภทของ Quest
enum QuestType {
  daily('รายวัน', '📅'),
  weekly('รายสัปดาห์', '📆');

  final String displayName;
  final String emoji;

  const QuestType(this.displayName, this.emoji);
}

/// ประเภทกิจกรรมที่ต้องทำ
enum QuestAction {
  learnVocab('เรียนคำศัพท์', 'vocab'),
  completeQuiz('ทำ Quiz', 'quiz'),
  completeExam('ทำข้อสอบ', 'exam'),
  maintainStreak('รักษา Streak', 'streak'),
  readPassage('อ่าน Reading', 'reading'),
  learnGrammar('เรียน Grammar', 'grammar'),
  earnXp('รับ XP', 'xp');

  final String displayName;
  final String actionKey;

  const QuestAction(this.displayName, this.actionKey);
}

class Quest extends Equatable {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final QuestAction action;
  final int targetValue;
  final int xpReward;
  final String icon;

  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.action,
    required this.targetValue,
    required this.xpReward,
    required this.icon,
  });

  @override
  List<Object?> get props =>
      [id, title, description, type, action, targetValue, xpReward, icon];
}

/// Progress ของ Quest
class QuestProgress extends Equatable {
  final String questId;
  final int currentValue;
  final bool isCompleted;
  final bool isClaimed;
  final DateTime? completedAt;

  const QuestProgress({
    required this.questId,
    this.currentValue = 0,
    this.isCompleted = false,
    this.isClaimed = false,
    this.completedAt,
  });

  double getProgress(int targetValue) {
    if (targetValue <= 0) return 1.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  QuestProgress copyWith({
    String? questId,
    int? currentValue,
    bool? isCompleted,
    bool? isClaimed,
    DateTime? completedAt,
  }) {
    return QuestProgress(
      questId: questId ?? this.questId,
      currentValue: currentValue ?? this.currentValue,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory QuestProgress.fromJson(Map<String, dynamic> json) {
    return QuestProgress(
      questId: json['questId'] as String,
      currentValue: json['currentValue'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isClaimed: json['isClaimed'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questId': questId,
      'currentValue': currentValue,
      'isCompleted': isCompleted,
      'isClaimed': isClaimed,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props =>
      [questId, currentValue, isCompleted, isClaimed, completedAt];
}
