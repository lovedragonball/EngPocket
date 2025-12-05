/// Exam Provider
library;

import 'package:flutter/foundation.dart';
import '../../../../core/models/exam_pack.dart';
import '../../../../core/models/question.dart';
import '../../../../core/models/exam_result.dart';
import '../../../../core/services/progress_service.dart';
import '../../data/datasources/exam_local_datasource.dart';
import '../../data/repositories/exam_repository_impl.dart';
import '../../domain/usecases/get_exam_packs.dart';
import '../../domain/usecases/calculate_exam_result.dart';

class ExamProvider extends ChangeNotifier {
  final GetExamPacks _getExamPacks;
  final CalculateExamResult _calculateExamResult;

  ExamProvider()
      : _getExamPacks = GetExamPacks(
          repository: ExamRepositoryImpl(
            localDatasource: ExamLocalDatasourceImpl(),
            progressService: ProgressService.instance,
          ),
        ),
        _calculateExamResult = CalculateExamResult(
          repository: ExamRepositoryImpl(
            localDatasource: ExamLocalDatasourceImpl(),
            progressService: ProgressService.instance,
          ),
        );

  // State
  List<ExamPack> _examPacks = [];
  ExamPack? _currentPack;
  List<Question> _questions = [];
  Map<String, int> _userAnswers = {};
  int _currentQuestionIndex = 0;
  ExamResult? _result;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ExamPack> get examPacks => _examPacks;
  ExamPack? get currentPack => _currentPack;
  List<Question> get questions => _questions;
  Question? get currentQuestion => 
      _questions.isNotEmpty ? _questions[_currentQuestionIndex] : null;
  int get currentQuestionIndex => _currentQuestionIndex;
  ExamResult? get result => _result;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _currentQuestionIndex < _questions.length - 1;
  bool get hasPrevious => _currentQuestionIndex > 0;
  bool get isComplete => _userAnswers.length == _questions.length;

  Future<void> loadExamPacks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _examPacks = await _getExamPacks.execute();
    } catch (e) {
      _error = 'ไม่สามารถโหลดชุดข้อสอบได้: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startExam(String packId) async {
    _isLoading = true;
    _error = null;
    _userAnswers = {};
    _currentQuestionIndex = 0;
    _result = null;
    notifyListeners();

    try {
      _currentPack = await _getExamPacks.getById(packId);
      _questions = await _getExamPacks.getQuestions(packId);
    } catch (e) {
      _error = 'ไม่สามารถเริ่มข้อสอบได้: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAnswer(int answerIndex) {
    if (currentQuestion != null) {
      _userAnswers[currentQuestion!.id] = answerIndex;
      notifyListeners();
    }
  }

  int? getSelectedAnswer(String questionId) {
    return _userAnswers[questionId];
  }

  void nextQuestion() {
    if (hasNext) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (hasPrevious) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  Future<void> submitExam() async {
    if (_currentPack == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _result = await _calculateExamResult.execute(
        packId: _currentPack!.id,
        userAnswers: _userAnswers,
      );
    } catch (e) {
      _error = 'ไม่สามารถส่งข้อสอบได้: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetExam() {
    _currentPack = null;
    _questions = [];
    _userAnswers = {};
    _currentQuestionIndex = 0;
    _result = null;
    notifyListeners();
  }
}
