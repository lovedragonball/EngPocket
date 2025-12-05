/// Database Helper - จัดการ initialization ของ database
library;

import 'local_storage.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  
  DatabaseHelper._();
  
  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }
  
  bool _isInitialized = false;
  
  /// Initialize database (call once at app start)
  Future<void> init() async {
    if (_isInitialized) return;
    
    await LocalStorage.instance.init();
    _isInitialized = true;
  }
  
  /// ตรวจสอบว่า database พร้อมใช้งานหรือยัง
  bool get isInitialized => _isInitialized;
  
  /// Reset database (สำหรับ testing หรือ clear data)
  Future<void> reset() async {
    await LocalStorage.instance.clearProgress();
  }
}
