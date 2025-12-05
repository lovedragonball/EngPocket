/// GetGrammarTopics UseCase
library;

import '../../../../core/models/grammar_topic.dart';
import '../repositories/grammar_repository.dart';

class GetGrammarTopics {
  final GrammarRepository _repository;

  GetGrammarTopics({required GrammarRepository repository})
      : _repository = repository;

  Future<List<GrammarTopic>> execute() {
    return _repository.getAllTopics();
  }

  Future<GrammarTopic?> getById(String id) {
    return _repository.getTopicById(id);
  }

  Future<List<GrammarTopic>> search(String query) {
    return _repository.searchTopics(query);
  }
}
