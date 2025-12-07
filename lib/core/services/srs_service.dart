/// SRS Service - จัดการ Spaced Repetition System
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/srs_card.dart';
import '../models/wrong_vocab.dart';

class SrsService {
  static const String _srsCardsKey = 'srs_cards';
  static const String _wrongVocabKey = 'wrong_vocab';
  static const String _learnedWordsKey = 'learned_words_ids';

  SharedPreferences? _prefs;
  Map<String, SrsCard> _srsCards = {};
  Map<String, WrongVocab> _wrongVocab = {};
  Set<String> _learnedWordIds = {};

  /// Initialize the service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadData();
  }

  /// Load data from storage
  Future<void> _loadData() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();

    // Load SRS cards
    final srsJson = prefs.getString(_srsCardsKey);
    if (srsJson != null) {
      final Map<String, dynamic> data = json.decode(srsJson);
      _srsCards = data.map((key, value) =>
          MapEntry(key, SrsCard.fromJson(value as Map<String, dynamic>)));
    }

    // Load wrong vocab
    final wrongJson = prefs.getString(_wrongVocabKey);
    if (wrongJson != null) {
      final Map<String, dynamic> data = json.decode(wrongJson);
      _wrongVocab = data.map((key, value) =>
          MapEntry(key, WrongVocab.fromJson(value as Map<String, dynamic>)));
    }

    // Load learned word IDs
    final learnedIds = prefs.getStringList(_learnedWordsKey);
    if (learnedIds != null) {
      _learnedWordIds = learnedIds.toSet();
    }
  }

  /// Save data to storage
  Future<void> _saveData() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();

    // Save SRS cards
    final srsData =
        _srsCards.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_srsCardsKey, json.encode(srsData));

    // Save wrong vocab
    final wrongData =
        _wrongVocab.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_wrongVocabKey, json.encode(wrongData));

    // Save learned word IDs
    await prefs.setStringList(_learnedWordsKey, _learnedWordIds.toList());
  }

  /// Get or create SRS card for a vocab
  SrsCard getOrCreateCard(String vocabId) {
    if (!_srsCards.containsKey(vocabId)) {
      _srsCards[vocabId] = SrsCard(vocabId: vocabId);
    }
    return _srsCards[vocabId]!;
  }

  /// Record review result
  /// quality: 0 = Again (wrong), 1 = Hard, 2 = Good, 3 = Easy
  Future<void> recordReview(String vocabId, int quality) async {
    final card = getOrCreateCard(vocabId);
    card.updateAfterReview(quality);

    // Mark as learned
    _learnedWordIds.add(vocabId);

    // Track wrong answers
    if (quality == 0) {
      recordWrongAnswer(vocabId);
    } else if (quality >= 2) {
      // Correct answer - reduce wrong count
      if (_wrongVocab.containsKey(vocabId)) {
        _wrongVocab[vocabId]!.recordCorrect();
        if (_wrongVocab[vocabId]!.wrongCount <= 0) {
          _wrongVocab.remove(vocabId);
        }
      }
    }

    await _saveData();
  }

  /// Record wrong answer
  void recordWrongAnswer(String vocabId) {
    if (_wrongVocab.containsKey(vocabId)) {
      _wrongVocab[vocabId]!.recordWrong();
    } else {
      _wrongVocab[vocabId] = WrongVocab(vocabId: vocabId);
    }
  }

  /// Get cards that are due for review today
  List<String> getDueCardIds(List<String> allVocabIds) {
    final dueIds = <String>[];

    for (final id in allVocabIds) {
      if (_srsCards.containsKey(id)) {
        final card = _srsCards[id]!;
        if (card.isDue()) {
          dueIds.add(id);
        }
      }
    }

    return dueIds;
  }

  /// Get due card IDs directly from stored cards
  List<String> getActualDueCardIds() {
    return _srsCards.entries
        .where((e) => e.value.isDue())
        .map((e) => e.key)
        .toList();
  }

  /// Get new cards (never learned)
  List<String> getNewCardIds(List<String> allVocabIds, {int limit = 10}) {
    final newIds = <String>[];

    for (final id in allVocabIds) {
      if (!_learnedWordIds.contains(id)) {
        newIds.add(id);
        if (newIds.length >= limit) break;
      }
    }

    return newIds;
  }

  /// Get cards for today's study session
  /// Returns: [newCards, reviewCards]
  List<String> getTodayCards(List<String> allVocabIds,
      {int newLimit = 10, int reviewLimit = 50}) {
    final result = <String>[];

    // Add new cards first
    final newCards = getNewCardIds(allVocabIds, limit: newLimit);
    result.addAll(newCards);

    // Add due review cards
    final dueCards = getDueCardIds(allVocabIds);
    for (final id in dueCards) {
      if (result.length >= reviewLimit) break;
      if (!result.contains(id)) {
        result.add(id);
      }
    }

    return result;
  }

  /// Get frequently wrong vocab IDs
  List<String> getFrequentlyWrongIds({int limit = 20}) {
    final wrongList = _wrongVocab.values
        .where((w) => w.isFrequentlyWrong())
        .toList()
      ..sort((a, b) => b.wrongCount.compareTo(a.wrongCount));

    return wrongList.take(limit).map((w) => w.vocabId).toList();
  }

  /// Get all wrong vocab
  List<WrongVocab> getAllWrongVocab() {
    return _wrongVocab.values.toList()
      ..sort((a, b) => b.wrongCount.compareTo(a.wrongCount));
  }

  /// Get statistics
  Map<String, int> getStats() {
    int dueToday = 0;
    int learned = _learnedWordIds.length;
    int mastered = 0;

    for (final card in _srsCards.values) {
      if (card.isDue()) dueToday++;
      if (card.interval >= 21) mastered++; // Mastered = interval >= 21 days
    }

    return {
      'dueToday': dueToday,
      'learned': learned,
      'mastered': mastered,
      'wrongCount': _wrongVocab.length,
    };
  }

  /// Get SRS card info for a vocab
  SrsCard? getCard(String vocabId) {
    return _srsCards[vocabId];
  }

  /// Check if a word is learned
  bool isLearned(String vocabId) {
    return _learnedWordIds.contains(vocabId);
  }

  /// Get total learned count
  int get learnedCount => _learnedWordIds.length;

  /// Reset all progress
  Future<void> resetAll() async {
    _srsCards.clear();
    _wrongVocab.clear();
    _learnedWordIds.clear();
    await _saveData();
  }

  /// Get all SRS cards
  Map<String, dynamic> getAllCards() {
    return _srsCards.map((key, value) => MapEntry(key, value.toJson()));
  }
}
