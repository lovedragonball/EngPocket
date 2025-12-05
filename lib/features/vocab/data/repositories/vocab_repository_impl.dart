/// Vocab Repository Implementation
library;

import '../../../../core/models/vocab_item.dart';
import '../../../../core/models/progress_record.dart';
import '../../../../core/services/progress_service.dart';
import '../../domain/repositories/vocab_repository.dart';
import '../datasources/vocab_local_datasource.dart';

class VocabRepositoryImpl implements VocabRepository {
  final VocabLocalDatasource _localDatasource;
  final ProgressService _progressService;

  VocabRepositoryImpl({
    required VocabLocalDatasource localDatasource,
    required ProgressService progressService,
  })  : _localDatasource = localDatasource,
        _progressService = progressService;

  @override
  Future<List<VocabItem>> getAllVocab() {
    return _localDatasource.getAllVocab();
  }

  @override
  Future<List<VocabItem>> getVocabByPack(String packId) {
    return _localDatasource.getVocabByPack(packId);
  }

  @override
  Future<VocabItem?> getVocabById(String id) {
    return _localDatasource.getVocabById(id);
  }

  @override
  Future<List<VocabItem>> getDailyVocab(int count) async {
    final allVocab = await getAllVocab();
    final progress = await _progressService.loadProgress();
    
    // แยกคำศัพท์ตาม mastery
    final newWords = <VocabItem>[];
    final learningWords = <VocabItem>[];
    final masteredWords = <VocabItem>[];
    
    for (final vocab in allVocab) {
      final mastery = progress.vocabMastery[vocab.id] ?? MasteryLevel.newWord;
      switch (mastery) {
        case MasteryLevel.newWord:
          newWords.add(vocab);
          break;
        case MasteryLevel.learning:
          learningWords.add(vocab);
          break;
        case MasteryLevel.mastered:
          masteredWords.add(vocab);
          break;
      }
    }
    
    // ลำดับความสำคัญ: learning > new > mastered (ทบทวน)
    final result = <VocabItem>[];
    
    // เพิ่มคำที่กำลังเรียนก่อน
    result.addAll(learningWords.take(count ~/ 2));
    
    // เพิ่มคำใหม่
    final remaining = count - result.length;
    result.addAll(newWords.take(remaining));
    
    // ถ้ายังไม่ครบ เพิ่มคำที่ mastered แล้วมาทบทวน
    if (result.length < count) {
      final reviewCount = count - result.length;
      masteredWords.shuffle();
      result.addAll(masteredWords.take(reviewCount));
    }
    
    return result;
  }

  @override
  Future<List<VocabItem>> getVocabByMastery(MasteryLevel level) async {
    final allVocab = await getAllVocab();
    final progress = await _progressService.loadProgress();
    
    return allVocab.where((vocab) {
      final mastery = progress.vocabMastery[vocab.id] ?? MasteryLevel.newWord;
      return mastery == level;
    }).toList();
  }

  @override
  Future<void> updateMastery(String vocabId, MasteryLevel level) {
    return _progressService.updateVocabMastery(vocabId, level);
  }
}
