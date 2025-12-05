/// GetDailyVocab UseCase
/// 
/// ดึงรายการคำศัพท์ที่ควรทบทวนวันนี้
library;

import '../../../../core/models/vocab_item.dart';
import '../../../../core/utils/constants.dart';
import '../repositories/vocab_repository.dart';

class GetDailyVocab {
  final VocabRepository _repository;

  GetDailyVocab({required VocabRepository repository})
      : _repository = repository;

  /// ดึงคำศัพท์ที่ควรทบทวนวันนี้
  /// 
  /// [count] จำนวนคำศัพท์ที่ต้องการ (default: 10)
  /// 
  /// Returns: รายการคำศัพท์ที่ควรฝึก โดยจัดลำดับตาม:
  /// 1. คำที่กำลังเรียน (learning)
  /// 2. คำใหม่ (new)
  /// 3. คำที่จำได้แล้ว (mastered) - สำหรับทบทวน
  Future<List<VocabItem>> execute({int? count}) async {
    final targetCount = count ?? AppConstants.dailyVocabGoal;
    return _repository.getDailyVocab(targetCount);
  }
}
