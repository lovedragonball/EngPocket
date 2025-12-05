/// Progress Provider
library;

import 'package:flutter/foundation.dart';
import '../../../../core/models/progress_record.dart';
import '../../data/datasources/progress_local_datasource.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/usecases/get_user_progress.dart';

class ProgressProvider extends ChangeNotifier {
  final GetUserProgress _getUserProgress;

  ProgressProvider()
      : _getUserProgress = GetUserProgress(
          repository: ProgressRepositoryImpl(
            localDatasource: ProgressLocalDatasourceImpl(),
          ),
        );

  ProgressRecord? _progress;
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;
  String? _error;

  ProgressRecord? get progress => _progress;
  Map<String, dynamic> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProgress() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _progress = await _getUserProgress.execute();
      _statistics = await _getUserProgress.getStatistics();
    } catch (e) {
      _error = 'ไม่สามารถโหลดข้อมูลได้: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
