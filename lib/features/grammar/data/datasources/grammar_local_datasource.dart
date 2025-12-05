/// Grammar Local Datasource
library;

import '../../../../core/models/grammar_topic.dart';
import '../../../../core/utils/asset_loader.dart';
import '../../../../config/app_config.dart';

abstract class GrammarLocalDatasource {
  Future<List<GrammarTopic>> getAllTopics();
  Future<GrammarTopic?> getTopicById(String id);
}

class GrammarLocalDatasourceImpl implements GrammarLocalDatasource {
  List<GrammarTopic>? _cachedTopics;

  @override
  Future<List<GrammarTopic>> getAllTopics() async {
    if (_cachedTopics != null) return _cachedTopics!;
    
    _cachedTopics = await AssetLoader.loadAndTransform(
      AppConfig.defaultGrammarPack,
      GrammarTopic.fromJson,
    );
    
    return _cachedTopics!;
  }

  @override
  Future<GrammarTopic?> getTopicById(String id) async {
    final allTopics = await getAllTopics();
    try {
      return allTopics.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
  
  void clearCache() {
    _cachedTopics = null;
  }
}
