/// Progress Service - จัดการ progress ของผู้ใช้
library;

import '../db/local_storage.dart';
import '../models/progress_record.dart';
import '../models/exam_result.dart';

class ProgressService {
  static ProgressService? _instance;
  
  ProgressService._();
  
  static ProgressService get instance {
    _instance ??= ProgressService._();
    return _instance!;
  }
  
  ProgressRecord? _cachedProgress;
  
  /// โหลด progress ของผู้ใช้
  Future<ProgressRecord> loadProgress() async {
    if (_cachedProgress != null) return _cachedProgress!;
    
    final json = LocalStorage.instance.loadProgress();
    if (json == null) {
      _cachedProgress = ProgressRecord.empty();
    } else {
      _cachedProgress = ProgressRecord.fromJson(json);
    }
    
    return _cachedProgress!;
  }
  
  /// บันทึก progress
  Future<void> saveProgress(ProgressRecord progress) async {
    _cachedProgress = progress;
    await LocalStorage.instance.saveProgress(progress.toJson());
  }
  
  /// อัพเดท mastery ของคำศัพท์
  Future<void> updateVocabMastery(String vocabId, MasteryLevel level) async {
    final progress = await loadProgress();
    final updatedMastery = Map<String, MasteryLevel>.from(progress.vocabMastery);
    updatedMastery[vocabId] = level;
    
    final updatedProgress = progress.copyWith(
      vocabMastery: updatedMastery,
      lastUpdated: DateTime.now(),
    );
    
    await saveProgress(updatedProgress);
  }
  
  /// เพิ่มผลสอบ
  Future<void> addExamResult(ExamResult result) async {
    final progress = await loadProgress();
    final updatedHistory = [...progress.examHistory, result];
    
    final updatedProgress = progress.copyWith(
      examHistory: updatedHistory,
      lastUpdated: DateTime.now(),
    );
    
    await saveProgress(updatedProgress);
  }
  
  /// ดึง mastery level ของคำศัพท์
  Future<MasteryLevel> getVocabMastery(String vocabId) async {
    final progress = await loadProgress();
    return progress.vocabMastery[vocabId] ?? MasteryLevel.newWord;
  }
  
  /// Clear cache (เรียกเมื่อต้องการ reload)
  void clearCache() {
    _cachedProgress = null;
  }
}
