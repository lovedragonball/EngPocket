/// CalculateExamResult UseCase
library;

import '../../../../core/models/exam_result.dart';
import '../repositories/exam_repository.dart';

class CalculateExamResult {
  final ExamRepository _repository;

  CalculateExamResult({required ExamRepository repository})
      : _repository = repository;

  /// คำนวณผลสอบจากคำตอบของผู้ใช้
  /// 
  /// [packId] ID ของชุดข้อสอบ
  /// [userAnswers] Map ของ questionId -> selectedIndex
  /// 
  /// Returns: ExamResult พร้อม breakdown คะแนนแยกตามประเภท
  Future<ExamResult> execute({
    required String packId,
    required Map<String, int> userAnswers,
  }) async {
    final result = await _repository.calculateResult(packId, userAnswers);
    await _repository.saveResult(result);
    return result;
  }
}
