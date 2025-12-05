/// App Configuration
library;

class AppConfig {
  AppConfig._();
  
  // Environment
  static const bool isDebug = true;
  static const String environment = 'development'; // development, staging, production
  
  // API (เตรียมไว้สำหรับอนาคต)
  static const String baseUrl = 'https://api.engpocket.com';
  static const int apiTimeout = 30000; // milliseconds
  
  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = false;
  static const bool enableRemoteContent = false; // เปิดเมื่อมี server
  
  // Content Settings
  static const String defaultVocabPack = 'assets/data/vocab_pack_tgat_v1.json';
  static const String defaultGrammarPack = 'assets/data/grammar_topics.json';
  static const String defaultExamPack = 'assets/data/exam_pack_tgat_mock1.json';
  
  // App Settings
  static const int maxRecentExams = 10;
  static const int flashcardBatchSize = 20;
}
