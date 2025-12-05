/// Grammar Repository Interface
library;

import '../../../../core/models/grammar_topic.dart';

abstract class GrammarRepository {
  Future<List<GrammarTopic>> getAllTopics();
  Future<GrammarTopic?> getTopicById(String id);
  Future<List<GrammarTopic>> searchTopics(String query);
}
