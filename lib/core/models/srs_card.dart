/// SRS Card Model - เก็บข้อมูล Spaced Repetition สำหรับแต่ละคำศัพท์
library;

class SrsCard {
  final String vocabId;
  double easeFactor;
  int interval; // days
  int repetitions;
  DateTime nextReviewDate;
  DateTime? lastReviewDate;
  bool isNew;

  SrsCard({
    required this.vocabId,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.repetitions = 0,
    DateTime? nextReviewDate,
    this.lastReviewDate,
    this.isNew = true,
  }) : nextReviewDate = nextReviewDate ?? DateTime.now();

  /// Calculate next review based on SM-2 algorithm
  /// quality: 0 = Again, 1 = Hard, 2 = Good, 3 = Easy
  void updateAfterReview(int quality) {
    lastReviewDate = DateTime.now();

    if (quality < 2) {
      // Failed - reset repetitions
      repetitions = 0;
      interval = 1;
      isNew = false;
    } else {
      // Passed
      if (isNew || repetitions == 0) {
        interval = 1;
        isNew = false;
      } else if (repetitions == 1) {
        interval = 6;
      } else {
        interval = (interval * easeFactor).round();
      }

      repetitions++;

      // Update ease factor
      easeFactor =
          easeFactor + (0.1 - (3 - quality) * (0.08 + (3 - quality) * 0.02));
      if (easeFactor < 1.3) easeFactor = 1.3;
    }

    // Apply quality bonus
    if (quality == 3) {
      interval = (interval * 1.3).round();
    } else if (quality == 1) {
      interval = (interval * 0.5).round();
      if (interval < 1) interval = 1;
    }

    nextReviewDate = DateTime.now().add(Duration(days: interval));
  }

  /// Check if this card is due for review
  bool isDue() {
    return DateTime.now().isAfter(nextReviewDate) ||
        DateTime.now().isAtSameMomentAs(nextReviewDate);
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'vocabId': vocabId,
      'easeFactor': easeFactor,
      'interval': interval,
      'repetitions': repetitions,
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'lastReviewDate': lastReviewDate?.toIso8601String(),
      'isNew': isNew,
    };
  }

  /// Create from JSON
  factory SrsCard.fromJson(Map<String, dynamic> json) {
    return SrsCard(
      vocabId: json['vocabId'] as String,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      interval: json['interval'] as int? ?? 0,
      repetitions: json['repetitions'] as int? ?? 0,
      nextReviewDate: json['nextReviewDate'] != null
          ? DateTime.parse(json['nextReviewDate'] as String)
          : DateTime.now(),
      lastReviewDate: json['lastReviewDate'] != null
          ? DateTime.parse(json['lastReviewDate'] as String)
          : null,
      isNew: json['isNew'] as bool? ?? true,
    );
  }

  @override
  String toString() {
    return 'SrsCard(id: $vocabId, interval: $interval days, ef: ${easeFactor.toStringAsFixed(2)}, reps: $repetitions)';
  }
}
