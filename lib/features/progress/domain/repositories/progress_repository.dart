/// Progress Repository Interface
library;

import '../../../../core/models/progress_record.dart';
import '../../../../core/models/exam_result.dart';

abstract class ProgressRepository {
  Future<ProgressRecord> getProgress();
  Future<void> updateProgress(ProgressRecord progress);
  Future<List<ExamResult>> getRecentExams(int count);
  Future<Map<String, dynamic>> getStatistics();
}
