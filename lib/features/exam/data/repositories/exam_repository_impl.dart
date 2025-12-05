/// Exam Repository Implementation
library;

import 'package:uuid/uuid.dart';
import '../../../../core/models/exam_pack.dart';
import '../../../../core/models/question.dart';
import '../../../../core/models/exam_result.dart';
import '../../../../core/services/progress_service.dart';
import '../../domain/repositories/exam_repository.dart';
import '../datasources/exam_local_datasource.dart';

class ExamRepositoryImpl implements ExamRepository {
  final ExamLocalDatasource _localDatasource;
  final ProgressService _progressService;
  final Uuid _uuid = const Uuid();

  ExamRepositoryImpl({
    required ExamLocalDatasource localDatasource,
    required ProgressService progressService,
  })  : _localDatasource = localDatasource,
        _progressService = progressService;

  @override
  Future<List<ExamPack>> getAllExamPacks() {
    return _localDatasource.getAllExamPacks();
  }

  @override
  Future<ExamPack?> getExamPackById(String id) {
    return _localDatasource.getExamPackById(id);
  }

  @override
  Future<List<Question>> getQuestionsByPackId(String packId) {
    return _localDatasource.getQuestionsByPackId(packId);
  }

  @override
  Future<ExamResult> calculateResult(
    String packId,
    Map<String, int> userAnswers,
  ) async {
    final questions = await getQuestionsByPackId(packId);
    
    int vocabCorrect = 0, vocabTotal = 0;
    int grammarCorrect = 0, grammarTotal = 0;
    int readingCorrect = 0, readingTotal = 0;
    
    for (final question in questions) {
      final userAnswer = userAnswers[question.id];
      final isCorrect = userAnswer == question.correctIndex;
      
      switch (question.skillType) {
        case SkillType.vocab:
          vocabTotal++;
          if (isCorrect) vocabCorrect++;
          break;
        case SkillType.grammar:
          grammarTotal++;
          if (isCorrect) grammarCorrect++;
          break;
        case SkillType.reading:
        case SkillType.cloze:
          readingTotal++;
          if (isCorrect) readingCorrect++;
          break;
      }
    }
    
    final totalCorrect = vocabCorrect + grammarCorrect + readingCorrect;
    
    return ExamResult(
      id: _uuid.v4(),
      examPackId: packId,
      score: totalCorrect,
      totalQuestions: questions.length,
      date: DateTime.now(),
      breakdown: ExamBreakdown(
        vocabCorrect: vocabCorrect,
        vocabTotal: vocabTotal,
        grammarCorrect: grammarCorrect,
        grammarTotal: grammarTotal,
        readingCorrect: readingCorrect,
        readingTotal: readingTotal,
      ),
    );
  }

  @override
  Future<void> saveResult(ExamResult result) {
    return _progressService.addExamResult(result);
  }
}
