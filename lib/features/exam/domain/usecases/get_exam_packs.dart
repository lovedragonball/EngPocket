/// GetExamPacks UseCase
library;

import '../../../../core/models/exam_pack.dart';
import '../../../../core/models/question.dart';
import '../repositories/exam_repository.dart';

class GetExamPacks {
  final ExamRepository _repository;

  GetExamPacks({required ExamRepository repository})
      : _repository = repository;

  Future<List<ExamPack>> execute() {
    return _repository.getAllExamPacks();
  }

  Future<ExamPack?> getById(String id) {
    return _repository.getExamPackById(id);
  }

  Future<List<Question>> getQuestions(String packId) {
    return _repository.getQuestionsByPackId(packId);
  }
}
