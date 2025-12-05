/// Grammar Provider
library;

import 'package:flutter/foundation.dart';
import '../../../../core/models/grammar_topic.dart';
import '../../data/datasources/grammar_local_datasource.dart';
import '../../data/repositories/grammar_repository_impl.dart';
import '../../domain/usecases/get_grammar_topics.dart';

class GrammarProvider extends ChangeNotifier {
  final GetGrammarTopics _getGrammarTopics;

  GrammarProvider()
      : _getGrammarTopics = GetGrammarTopics(
          repository: GrammarRepositoryImpl(
            localDatasource: GrammarLocalDatasourceImpl(),
          ),
        );

  List<GrammarTopic> _topics = [];
  GrammarTopic? _selectedTopic;
  bool _isLoading = false;
  String? _error;

  List<GrammarTopic> get topics => _topics;
  GrammarTopic? get selectedTopic => _selectedTopic;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTopics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _topics = await _getGrammarTopics.execute();
    } catch (e) {
      _error = 'ไม่สามารถโหลดหัวข้อไวยากรณ์ได้: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectTopic(String topicId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedTopic = await _getGrammarTopics.getById(topicId);
    } catch (e) {
      _error = 'ไม่พบหัวข้อที่เลือก';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelection() {
    _selectedTopic = null;
    notifyListeners();
  }
}
