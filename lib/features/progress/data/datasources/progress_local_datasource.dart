/// Progress Local Datasource
library;

import '../../../../core/models/progress_record.dart';
import '../../../../core/db/local_storage.dart';

abstract class ProgressLocalDatasource {
  Future<ProgressRecord?> loadProgress();
  Future<void> saveProgress(ProgressRecord progress);
}

class ProgressLocalDatasourceImpl implements ProgressLocalDatasource {
  @override
  Future<ProgressRecord?> loadProgress() async {
    final json = LocalStorage.instance.loadProgress();
    if (json == null) return null;
    return ProgressRecord.fromJson(json);
  }

  @override
  Future<void> saveProgress(ProgressRecord progress) async {
    await LocalStorage.instance.saveProgress(progress.toJson());
  }
}
