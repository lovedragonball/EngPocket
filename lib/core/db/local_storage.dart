/// Local Storage wrapper using Hive
library;

import 'package:hive_flutter/hive_flutter.dart';
import '../utils/constants.dart';

class LocalStorage {
  static LocalStorage? _instance;
  
  LocalStorage._();
  
  static LocalStorage get instance {
    _instance ??= LocalStorage._();
    return _instance!;
  }
  
  late Box<dynamic> _progressBox;
  late Box<dynamic> _settingsBox;
  
  /// Initialize Hive และเปิด boxes ที่จำเป็น
  Future<void> init() async {
    await Hive.initFlutter();
    
    _progressBox = await Hive.openBox(AppConstants.progressBoxKey);
    _settingsBox = await Hive.openBox(AppConstants.settingsBoxKey);
  }
  
  // ==================== Progress Box ====================
  
  /// บันทึก progress ของผู้ใช้
  Future<void> saveProgress(Map<String, dynamic> progressJson) async {
    await _progressBox.put(AppConstants.userProgressKey, progressJson);
  }
  
  /// โหลด progress ของผู้ใช้
  Map<String, dynamic>? loadProgress() {
    final data = _progressBox.get(AppConstants.userProgressKey);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }
  
  /// ลบ progress ทั้งหมด
  Future<void> clearProgress() async {
    await _progressBox.delete(AppConstants.userProgressKey);
  }
  
  // ==================== Settings Box ====================
  
  /// บันทึก setting
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }
  
  /// โหลด setting
  T? loadSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }
  
  // ==================== Generic Methods ====================
  
  /// บันทึก data ลง box ที่ระบุ
  Future<void> put(String boxName, String key, dynamic value) async {
    final box = await Hive.openBox(boxName);
    await box.put(key, value);
  }
  
  /// โหลด data จาก box ที่ระบุ
  Future<T?> get<T>(String boxName, String key) async {
    final box = await Hive.openBox(boxName);
    return box.get(key) as T?;
  }
  
  /// ปิด boxes ทั้งหมด
  Future<void> close() async {
    await Hive.close();
  }
}
