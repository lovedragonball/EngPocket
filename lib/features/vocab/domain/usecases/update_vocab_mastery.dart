/// UpdateVocabMastery UseCase
/// 
/// อัพเดท mastery level ของคำศัพท์เมื่อผู้ใช้ตอบ
library;

import '../../../../core/models/progress_record.dart';
import '../repositories/vocab_repository.dart';

class UpdateVocabMastery {
  final VocabRepository _repository;

  UpdateVocabMastery({required VocabRepository repository})
      : _repository = repository;

  /// อัพเดท mastery ของคำศัพท์
  /// 
  /// [vocabId] id ของคำศัพท์
  /// [isCorrect] ตอบถูกหรือไม่
  /// [currentLevel] ระดับปัจจุบัน
  Future<MasteryLevel> execute({
    required String vocabId,
    required bool isCorrect,
    required MasteryLevel currentLevel,
  }) async {
    MasteryLevel newLevel;
    
    if (isCorrect) {
      // ตอบถูก -> เลื่อนระดับขึ้น
      switch (currentLevel) {
        case MasteryLevel.newWord:
          newLevel = MasteryLevel.learning;
          break;
        case MasteryLevel.learning:
          newLevel = MasteryLevel.mastered;
          break;
        case MasteryLevel.mastered:
          newLevel = MasteryLevel.mastered; // คงเดิม
          break;
      }
    } else {
      // ตอบผิด -> ลดระดับลง
      switch (currentLevel) {
        case MasteryLevel.newWord:
          newLevel = MasteryLevel.newWord; // คงเดิม
          break;
        case MasteryLevel.learning:
          newLevel = MasteryLevel.newWord;
          break;
        case MasteryLevel.mastered:
          newLevel = MasteryLevel.learning;
          break;
      }
    }
    
    await _repository.updateMastery(vocabId, newLevel);
    return newLevel;
  }
}
