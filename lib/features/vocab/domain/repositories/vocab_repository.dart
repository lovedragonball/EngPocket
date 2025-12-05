/// Vocab Repository Interface
library;

import '../../../../core/models/vocab_item.dart';
import '../../../../core/models/progress_record.dart';

abstract class VocabRepository {
  /// ดึงคำศัพท์ทั้งหมด
  Future<List<VocabItem>> getAllVocab();
  
  /// ดึงคำศัพท์ตาม pack
  Future<List<VocabItem>> getVocabByPack(String packId);
  
  /// ดึงคำศัพท์ตาม id
  Future<VocabItem?> getVocabById(String id);
  
  /// ดึงคำศัพท์ที่ควรฝึกวันนี้
  Future<List<VocabItem>> getDailyVocab(int count);
  
  /// ดึงคำศัพท์ตาม mastery level
  Future<List<VocabItem>> getVocabByMastery(MasteryLevel level);
  
  /// อัพเดท mastery ของคำศัพท์
  Future<void> updateMastery(String vocabId, MasteryLevel level);
}
