/// User Preferences Service - จัดการการตั้งค่าผู้ใช้
library;

import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String _keyDailyGoal = 'daily_goal';
  static const String _keyExamType = 'exam_type';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyNotificationHour = 'notification_hour';
  static const String _keyNotificationMinute = 'notification_minute';
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyCurrentStreak = 'current_streak';
  static const String _keyLastStudyDate = 'last_study_date';
  static const String _keyTotalVocabLearned = 'total_vocab_learned';
  static const String _keyTotalStudyMinutes = 'total_study_minutes';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Onboarding
  bool get hasSeenOnboarding => _prefs.getBool(_keyHasSeenOnboarding) ?? false;
  Future<void> setHasSeenOnboarding(bool value) async {
    await _prefs.setBool(_keyHasSeenOnboarding, value);
  }

  // Daily Goal
  int get dailyGoal => _prefs.getInt(_keyDailyGoal) ?? 10;
  Future<void> setDailyGoal(int value) async {
    await _prefs.setInt(_keyDailyGoal, value);
  }

  // Exam Type (tgat, alevel, both)
  String get examType => _prefs.getString(_keyExamType) ?? 'both';
  Future<void> setExamType(String value) async {
    await _prefs.setString(_keyExamType, value);
  }

  // Dark Mode
  bool get isDarkMode => _prefs.getBool(_keyDarkMode) ?? false;
  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_keyDarkMode, value);
  }

  // Notifications
  bool get notificationsEnabled =>
      _prefs.getBool(_keyNotificationsEnabled) ?? true;
  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(_keyNotificationsEnabled, value);
  }

  int get notificationHour => _prefs.getInt(_keyNotificationHour) ?? 18;
  int get notificationMinute => _prefs.getInt(_keyNotificationMinute) ?? 0;
  Future<void> setNotificationTime(int hour, int minute) async {
    await _prefs.setInt(_keyNotificationHour, hour);
    await _prefs.setInt(_keyNotificationMinute, minute);
  }

  // Sound
  bool get soundEnabled => _prefs.getBool(_keySoundEnabled) ?? true;
  Future<void> setSoundEnabled(bool value) async {
    await _prefs.setBool(_keySoundEnabled, value);
  }

  // Streak
  int get currentStreak => _prefs.getInt(_keyCurrentStreak) ?? 0;
  Future<void> setCurrentStreak(int value) async {
    await _prefs.setInt(_keyCurrentStreak, value);
  }

  String? get lastStudyDate => _prefs.getString(_keyLastStudyDate);
  Future<void> setLastStudyDate(String date) async {
    await _prefs.setString(_keyLastStudyDate, date);
  }

  // Stats
  int get totalVocabLearned => _prefs.getInt(_keyTotalVocabLearned) ?? 0;
  Future<void> incrementVocabLearned([int count = 1]) async {
    await _prefs.setInt(_keyTotalVocabLearned, totalVocabLearned + count);
  }

  int get totalStudyMinutes => _prefs.getInt(_keyTotalStudyMinutes) ?? 0;
  Future<void> addStudyMinutes(int minutes) async {
    await _prefs.setInt(_keyTotalStudyMinutes, totalStudyMinutes + minutes);
  }

  // Update streak logic
  Future<void> recordStudySession() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = lastStudyDate;

    if (lastDate == null) {
      // First study session
      await setCurrentStreak(1);
    } else if (lastDate == today) {
      // Already studied today, do nothing
      return;
    } else {
      final lastDateTime = DateTime.parse(lastDate);
      final todayDateTime = DateTime.parse(today);
      final difference = todayDateTime.difference(lastDateTime).inDays;

      if (difference == 1) {
        // Consecutive day
        await setCurrentStreak(currentStreak + 1);
      } else {
        // Streak broken
        await setCurrentStreak(1);
      }
    }

    await setLastStudyDate(today);
  }

  // Reset all data
  Future<void> resetAllData() async {
    await _prefs.clear();
  }
}
