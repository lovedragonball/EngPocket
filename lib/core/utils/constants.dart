/// App-wide constants
library;

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'EngPocket';
  static const String appVersion = '1.0.0';
  
  // Daily Learning Goals
  static const int dailyVocabGoal = 10;
  static const int dailyGrammarQuizGoal = 1;
  static const int dailyReadingGoal = 1;
  
  // Mastery Settings
  static const int reviewIntervalNewWord = 1;      // วัน
  static const int reviewIntervalLearning = 3;     // วัน
  static const int reviewIntervalMastered = 7;     // วัน
  static const int masteryThreshold = 3;           // ตอบถูกกี่ครั้งถึงจะ master
  
  // Quiz Settings
  static const int defaultQuizQuestions = 10;
  static const int examTimeMinutes = 60;
  
  // Storage Keys
  static const String progressBoxKey = 'progress_box';
  static const String settingsBoxKey = 'settings_box';
  static const String userProgressKey = 'user_progress';
}
