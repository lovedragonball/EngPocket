/// Exam Repository Interface
library;

import '../../../../core/models/exam_pack.dart';
import '../../../../core/models/question.dart';
import '../../../../core/models/exam_result.dart';

abstract class ExamRepository {
  Future<List<ExamPack>> getAllExamPacks();
  Future<ExamPack?> getExamPackById(String id);
  Future<List<Question>> getQuestionsByPackId(String packId);
  Future<ExamResult> calculateResult(String packId, Map<String, int> userAnswers);
  Future<void> saveResult(ExamResult result);
}
