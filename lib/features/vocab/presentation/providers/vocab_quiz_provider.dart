/// Vocab Quiz Provider - จัดการ state ของ quiz
library;

import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../../core/models/vocab_item.dart';

class VocabQuizProvider extends ChangeNotifier {
  final List<VocabItem> _allVocab;
  final List<VocabItem> _distractorPool; // Pool ของคำสำหรับทำตัวเลือก
  final int _questionCount;
  final Random _random = Random();

  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  bool _isFinished = false;
  bool _isLoading = true;
  int? _selectedAnswer;
  bool _showResult = false;

  VocabQuizProvider({
    required List<VocabItem> vocab,
    List<VocabItem>? distractorPool, // Optional separate distractor pool
    int questionCount = 10,
  })  : _allVocab = vocab,
        _distractorPool = distractorPool ??
            vocab, // ใช้ distractor pool ถ้ามี ไม่งั้นใช้ vocab เดิม
        _questionCount = questionCount {
    _generateQuestions();
  }

  // Getters
  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get correctCount => _correctCount;
  int get wrongCount => _wrongCount;
  bool get isFinished => _isFinished;
  bool get isLoading => _isLoading;
  int? get selectedAnswer => _selectedAnswer;
  bool get showResult => _showResult;

  QuizQuestion? get currentQuestion =>
      _questions.isNotEmpty ? _questions[_currentIndex] : null;

  int get totalQuestions => _questions.length;
  double get progress =>
      totalQuestions > 0 ? (_currentIndex + 1) / totalQuestions : 0;
  int get score =>
      totalQuestions > 0 ? (correctCount * 100 / totalQuestions).round() : 0;

  void _generateQuestions() {
    _isLoading = true;
    notifyListeners();

    // Shuffle and take required number
    final shuffled = List<VocabItem>.from(_allVocab)..shuffle(_random);
    final selected = shuffled.take(_questionCount).toList();

    _questions = selected.map((vocab) {
      // Generate distractor choices - better algorithm
      final distractors = _generateSmartDistractors(vocab, 3);

      final choices = [
        vocab.translation,
        ...distractors,
      ]..shuffle(_random);

      final correctIndex = choices.indexOf(vocab.translation);

      return QuizQuestion(
        vocab: vocab,
        choices: choices,
        correctIndex: correctIndex,
      );
    }).toList();

    _isLoading = false;
    notifyListeners();
  }

  /// สร้าง distractor ที่ฉลาดขึ้น - หลากหลายและไม่ซ้ำกัน
  List<String> _generateSmartDistractors(VocabItem correctVocab, int count) {
    final usedTranslations = <String>{correctVocab.translation};
    final distractors = <String>[];

    // กรองคำที่ไม่ใช่คำตอบถูก - ใช้ distractor pool ที่มีข้อมูลมากกว่า
    final candidates =
        _distractorPool.where((v) => v.id != correctVocab.id).toList();

    // 1. ให้ความสำคัญกับคำที่มี partOfSpeech เดียวกัน
    final samePosCandidates = candidates
        .where((v) => v.partOfSpeech == correctVocab.partOfSpeech)
        .toList();

    // 2. จัดลำดับตามความยาวของ translation ที่ใกล้เคียงกัน
    final correctLength = correctVocab.translation.length;
    samePosCandidates.sort((a, b) {
      final diffA = (a.translation.length - correctLength).abs();
      final diffB = (b.translation.length - correctLength).abs();
      return diffA.compareTo(diffB);
    });

    // 3. เลือก distractor จากกลุ่มที่มี partOfSpeech เดียวกัน
    for (final candidate in samePosCandidates) {
      if (distractors.length >= count) break;
      // หลีกเลี่ยง translation ที่ซ้ำกัน
      if (!usedTranslations.contains(candidate.translation) &&
          !_isTooSimilar(correctVocab.translation, candidate.translation)) {
        distractors.add(candidate.translation);
        usedTranslations.add(candidate.translation);
      }
    }

    // 4. ถ้ายังไม่ครบ ดึงจากกลุ่มอื่นที่มี partOfSpeech ต่างกัน
    if (distractors.length < count) {
      final otherCandidates = candidates
          .where((v) => v.partOfSpeech != correctVocab.partOfSpeech)
          .toList()
        ..shuffle(_random);

      for (final candidate in otherCandidates) {
        if (distractors.length >= count) break;
        if (!usedTranslations.contains(candidate.translation) &&
            !_isTooSimilar(correctVocab.translation, candidate.translation)) {
          distractors.add(candidate.translation);
          usedTranslations.add(candidate.translation);
        }
      }
    }

    // 5. Shuffle เพื่อความหลากหลาย
    distractors.shuffle(_random);

    return distractors;
  }

  /// ตรวจสอบว่า translation คล้ายกันเกินไปหรือไม่
  bool _isTooSimilar(String correct, String distractor) {
    // Normalize strings - ตัดช่องว่างและเปลี่ยนเป็นตัวเล็ก
    final correctNorm = correct.toLowerCase().trim();
    final distractorNorm = distractor.toLowerCase().trim();

    // ถ้าเหมือนกันเลย
    if (correctNorm == distractorNorm) return true;

    // แยกคำหลัก (ถ้ามี comma หรือ or)
    final correctWords = correctNorm.split(RegExp(r'[,\s]+'));
    final distractorWords = distractorNorm.split(RegExp(r'[,\s]+'));

    // ถ้ามีคำหลักที่เหมือนกัน
    for (final cWord in correctWords) {
      if (cWord.isEmpty) continue;
      for (final dWord in distractorWords) {
        if (dWord.isEmpty) continue;
        if (cWord == dWord && cWord.length > 2) return true;
      }
    }

    // ถ้าขึ้นต้นด้วยคำเดียวกัน 4 ตัวอักษรขึ้นไป ถือว่าคล้ายกันเกินไป
    if (correctNorm.length >= 4 && distractorNorm.length >= 4) {
      final prefix = correctNorm.substring(0, 4);
      if (distractorNorm.startsWith(prefix)) return true;
    }

    // ถ้าเป็น substring ของกันและกัน (ยาวเกิน 3 ตัวอักษร)
    if (correctNorm.length > 3 && distractorNorm.contains(correctNorm)) {
      return true;
    }
    if (distractorNorm.length > 3 && correctNorm.contains(distractorNorm)) {
      return true;
    }

    return false;
  }

  void selectAnswer(int index) {
    if (_showResult) return; // Already answered

    _selectedAnswer = index;
    _showResult = true;

    if (index == currentQuestion?.correctIndex) {
      _correctCount++;
    } else {
      _wrongCount++;
    }

    notifyListeners();
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _selectedAnswer = null;
      _showResult = false;
    } else {
      _isFinished = true;
    }
    notifyListeners();
  }

  void restart() {
    _currentIndex = 0;
    _correctCount = 0;
    _wrongCount = 0;
    _isFinished = false;
    _selectedAnswer = null;
    _showResult = false;
    _generateQuestions();
  }
}

class QuizQuestion {
  final VocabItem vocab;
  final List<String> choices;
  final int correctIndex;

  const QuizQuestion({
    required this.vocab,
    required this.choices,
    required this.correctIndex,
  });

  String get word => vocab.word;
  String get correctAnswer => choices[correctIndex];
}
