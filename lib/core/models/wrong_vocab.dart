/// Wrong Vocab Model - เก็บข้อมูลคำศัพท์ที่ตอบผิดบ่อย
library;

class WrongVocab {
  final String vocabId;
  int wrongCount;
  DateTime lastWrongDate;
  List<DateTime> wrongHistory;

  WrongVocab({
    required this.vocabId,
    this.wrongCount = 1,
    DateTime? lastWrongDate,
    List<DateTime>? wrongHistory,
  })  : lastWrongDate = lastWrongDate ?? DateTime.now(),
        wrongHistory = wrongHistory ?? [DateTime.now()];

  /// Record a new wrong answer
  void recordWrong() {
    wrongCount++;
    lastWrongDate = DateTime.now();
    wrongHistory.add(DateTime.now());

    // Keep only last 10 entries
    if (wrongHistory.length > 10) {
      wrongHistory = wrongHistory.sublist(wrongHistory.length - 10);
    }
  }

  /// Record a correct answer (reduces wrong count)
  void recordCorrect() {
    if (wrongCount > 0) {
      wrongCount--;
    }
  }

  /// Check if this is a frequently wrong word
  bool isFrequentlyWrong() {
    return wrongCount >= 3;
  }

  /// Get wrong rate in the last 7 days
  int getRecentWrongCount() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return wrongHistory.where((date) => date.isAfter(weekAgo)).length;
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'vocabId': vocabId,
      'wrongCount': wrongCount,
      'lastWrongDate': lastWrongDate.toIso8601String(),
      'wrongHistory': wrongHistory.map((d) => d.toIso8601String()).toList(),
    };
  }

  /// Create from JSON
  factory WrongVocab.fromJson(Map<String, dynamic> json) {
    return WrongVocab(
      vocabId: json['vocabId'] as String,
      wrongCount: json['wrongCount'] as int? ?? 1,
      lastWrongDate: json['lastWrongDate'] != null
          ? DateTime.parse(json['lastWrongDate'] as String)
          : DateTime.now(),
      wrongHistory: (json['wrongHistory'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'WrongVocab(id: $vocabId, count: $wrongCount)';
  }
}
