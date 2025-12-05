/// Progress Repository Implementation
library;

import '../../../../core/models/progress_record.dart';
import '../../../../core/models/exam_result.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_datasource.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressLocalDatasource _localDatasource;

  ProgressRepositoryImpl({required ProgressLocalDatasource localDatasource})
      : _localDatasource = localDatasource;

  @override
  Future<ProgressRecord> getProgress() async {
    final progress = await _localDatasource.loadProgress();
    return progress ?? ProgressRecord.empty();
  }

  @override
  Future<void> updateProgress(ProgressRecord progress) {
    return _localDatasource.saveProgress(progress);
  }

  @override
  Future<List<ExamResult>> getRecentExams(int count) async {
    final progress = await getProgress();
    final sorted = List<ExamResult>.from(progress.examHistory)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(count).toList();
  }

  @override
  Future<Map<String, dynamic>> getStatistics() async {
    final progress = await getProgress();
    
    return {
      'totalVocab': progress.vocabMastery.length,
      'masteredVocab': progress.masteredCount,
      'learningVocab': progress.learningCount,
      'newVocab': progress.newWordsCount,
      'totalExams': progress.examHistory.length,
      'averageScore': progress.averageExamScore,
      'studyDays': progress.totalStudyDays,
      'streak': progress.currentStreak,
    };
  }
}
