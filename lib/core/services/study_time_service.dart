/// Study Time Service - Track study time across different features
library;

import 'package:shared_preferences/shared_preferences.dart';

class StudyTimeService {
  static final StudyTimeService _instance = StudyTimeService._internal();
  factory StudyTimeService() => _instance;
  StudyTimeService._internal();

  SharedPreferences? _prefs;
  DateTime? _sessionStartTime;
  String? _currentCategory;

  // Keys
  static const String _keyTotalStudyMinutes = 'totalStudyMinutes';
  static const String _keyVocabStudyMinutes = 'vocabStudyMinutes';
  static const String _keyGrammarStudyMinutes = 'grammarStudyMinutes';
  static const String _keyExamStudyMinutes = 'examStudyMinutes';
  static const String _keyReadingStudyMinutes = 'readingStudyMinutes';

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Start a study session for a category
  void startSession(String category) {
    _sessionStartTime = DateTime.now();
    _currentCategory = category;
  }

  /// End the current study session and save time
  Future<int> endSession() async {
    if (_sessionStartTime == null || _currentCategory == null) return 0;

    await init();

    final duration = DateTime.now().difference(_sessionStartTime!);
    final minutes = duration.inMinutes;

    if (minutes > 0) {
      // Add to total
      final totalMinutes = _prefs!.getInt(_keyTotalStudyMinutes) ?? 0;
      await _prefs!.setInt(_keyTotalStudyMinutes, totalMinutes + minutes);

      // Add to category
      final categoryKey = _getCategoryKey(_currentCategory!);
      final categoryMinutes = _prefs!.getInt(categoryKey) ?? 0;
      await _prefs!.setInt(categoryKey, categoryMinutes + minutes);

      // Track daily activity
      await _trackDailyActivity(_currentCategory!, minutes);
    }

    _sessionStartTime = null;
    _currentCategory = null;

    return minutes;
  }

  String _getCategoryKey(String category) {
    switch (category) {
      case 'vocab':
        return _keyVocabStudyMinutes;
      case 'grammar':
        return _keyGrammarStudyMinutes;
      case 'exam':
        return _keyExamStudyMinutes;
      case 'reading':
        return _keyReadingStudyMinutes;
      default:
        return _keyTotalStudyMinutes;
    }
  }

  Future<void> _trackDailyActivity(String category, int minutes) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final key = 'activity_${today}_$category';
    final current = _prefs!.getInt(key) ?? 0;
    await _prefs!.setInt(key, current + minutes);
  }

  /// Get total study time in minutes
  Future<int> getTotalStudyMinutes() async {
    await init();
    return _prefs!.getInt(_keyTotalStudyMinutes) ?? 0;
  }

  /// Get study time by category in minutes
  Future<int> getCategoryStudyMinutes(String category) async {
    await init();
    return _prefs!.getInt(_getCategoryKey(category)) ?? 0;
  }

  /// Get weekly activity data
  Future<List<Map<String, dynamic>>> getWeeklyActivity() async {
    await init();

    final List<Map<String, dynamic>> weekData = [];
    final now = DateTime.now();
    final dayNames = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().substring(0, 10);

      final vocab = _prefs!.getInt('activity_${dateStr}_vocab') ?? 0;
      final grammar = _prefs!.getInt('activity_${dateStr}_grammar') ?? 0;
      final exam = _prefs!.getInt('activity_${dateStr}_exam') ?? 0;

      // Get day of week (1=Monday, 7=Sunday)
      final dayIndex = date.weekday - 1;

      weekData.add({
        'day': dayNames[dayIndex],
        'date': dateStr,
        'vocab': vocab,
        'grammar': grammar,
        'exam': exam,
        'total': vocab + grammar + exam,
      });
    }

    return weekData;
  }

  /// Get study statistics for pie chart
  Future<Map<String, double>> getStudyDistribution() async {
    await init();

    final vocabMinutes = _prefs!.getInt(_keyVocabStudyMinutes) ?? 0;
    final grammarMinutes = _prefs!.getInt(_keyGrammarStudyMinutes) ?? 0;
    final examMinutes = _prefs!.getInt(_keyExamStudyMinutes) ?? 0;
    final total = vocabMinutes + grammarMinutes + examMinutes;

    if (total == 0) {
      return {'vocab': 33.3, 'grammar': 33.3, 'exam': 33.3};
    }

    return {
      'vocab': (vocabMinutes / total) * 100,
      'grammar': (grammarMinutes / total) * 100,
      'exam': (examMinutes / total) * 100,
    };
  }
}
