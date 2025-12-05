/// Home Provider
library;

import 'package:flutter/foundation.dart';
import '../../../../core/models/vocab_item.dart';
import '../../../../core/utils/constants.dart';

class HomeProvider extends ChangeNotifier {
  // Today's tasks
  List<VocabItem> _todayVocab = [];
  bool _grammarQuizDone = false;
  bool _examDone = false;
  bool _isLoading = false;

  List<VocabItem> get todayVocab => _todayVocab;
  bool get grammarQuizDone => _grammarQuizDone;
  bool get examDone => _examDone;
  bool get isLoading => _isLoading;

  int get vocabGoal => AppConstants.dailyVocabGoal;
  int get vocabProgress => _todayVocab.length;

  Future<void> loadTodayTasks() async {
    _isLoading = true;
    notifyListeners();

    // Load sample vocab data for today's tasks
    await Future.delayed(const Duration(milliseconds: 300));
    _todayVocab = [
      const VocabItem(
        id: '1',
        word: 'achieve',
        translation: 'บรรลุ',
        partOfSpeech: 'verb',
        exampleEn: 'She worked hard to achieve her goals.',
        exampleTh: 'เธอทำงานหนักเพื่อบรรลุเป้าหมาย',
        level: 'intermediate',
        packId: 'TGAT_V1',
        tags: ['TGAT'],
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void markGrammarQuizDone() {
    _grammarQuizDone = true;
    notifyListeners();
  }

  void markExamDone() {
    _examDone = true;
    notifyListeners();
  }
}
