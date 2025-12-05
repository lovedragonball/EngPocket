/// Grammar Repository Implementation
library;

import '../../../../core/models/grammar_topic.dart';
import '../../domain/repositories/grammar_repository.dart';
import '../datasources/grammar_local_datasource.dart';

class GrammarRepositoryImpl implements GrammarRepository {
  final GrammarLocalDatasource _localDatasource;

  GrammarRepositoryImpl({required GrammarLocalDatasource localDatasource})
      : _localDatasource = localDatasource;

  @override
  Future<List<GrammarTopic>> getAllTopics() {
    return _localDatasource.getAllTopics();
  }

  @override
  Future<GrammarTopic?> getTopicById(String id) {
    return _localDatasource.getTopicById(id);
  }

  @override
  Future<List<GrammarTopic>> searchTopics(String query) async {
    final allTopics = await getAllTopics();
    final lowerQuery = query.toLowerCase();
    return allTopics.where((topic) {
      return topic.title.toLowerCase().contains(lowerQuery) ||
          topic.explanation.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
