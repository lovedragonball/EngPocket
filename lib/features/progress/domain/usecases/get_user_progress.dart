/// GetUserProgress UseCase
library;

import '../../../../core/models/progress_record.dart';
import '../repositories/progress_repository.dart';

class GetUserProgress {
  final ProgressRepository _repository;

  GetUserProgress({required ProgressRepository repository})
      : _repository = repository;

  Future<ProgressRecord> execute() {
    return _repository.getProgress();
  }

  Future<Map<String, dynamic>> getStatistics() {
    return _repository.getStatistics();
  }
}
