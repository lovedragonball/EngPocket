/// Exam Local Datasource
library;

import '../../../../core/models/exam_pack.dart';
import '../../../../core/models/question.dart';
import '../../../../core/utils/asset_loader.dart';
import '../../../../config/app_config.dart';

abstract class ExamLocalDatasource {
  Future<List<ExamPack>> getAllExamPacks();
  Future<ExamPack?> getExamPackById(String id);
  Future<List<Question>> getQuestionsByPackId(String packId);
}

class ExamLocalDatasourceImpl implements ExamLocalDatasource {
  Map<String, ExamPack>? _cachedPacks;
  Map<String, List<Question>>? _cachedQuestions;

  @override
  Future<List<ExamPack>> getAllExamPacks() async {
    if (_cachedPacks != null) return _cachedPacks!.values.toList();
    
    try {
      final json = await AssetLoader.loadJsonMap(AppConfig.defaultExamPack);
      final packsJson = json['packs'] as List? ?? [];
      
      _cachedPacks = {};
      for (final packJson in packsJson) {
        final pack = ExamPack.fromJson(packJson as Map<String, dynamic>);
        _cachedPacks![pack.id] = pack;
      }
      
      // Cache questions
      _cachedQuestions = {};
      final questionsJson = json['questions'] as List? ?? [];
      for (final qJson in questionsJson) {
        final question = Question.fromJson(qJson as Map<String, dynamic>);
        _cachedQuestions!.putIfAbsent(question.packId, () => []);
        _cachedQuestions![question.packId]!.add(question);
      }
      
      return _cachedPacks!.values.toList();
    } catch (e) {
      // Return empty list if file not found (for MVP)
      return [];
    }
  }

  @override
  Future<ExamPack?> getExamPackById(String id) async {
    await getAllExamPacks(); // Ensure cache is loaded
    return _cachedPacks?[id];
  }

  @override
  Future<List<Question>> getQuestionsByPackId(String packId) async {
    await getAllExamPacks(); // Ensure cache is loaded
    return _cachedQuestions?[packId] ?? [];
  }
  
  void clearCache() {
    _cachedPacks = null;
    _cachedQuestions = null;
  }
}
