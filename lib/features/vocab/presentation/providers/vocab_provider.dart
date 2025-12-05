/// Vocab Provider - State Management for Vocab feature
library;

import 'package:flutter/foundation.dart';
import '../../../../core/models/vocab_item.dart';
import '../../../../core/services/progress_service.dart';
import '../../data/datasources/vocab_local_datasource.dart';
import '../../data/repositories/vocab_repository_impl.dart';
import '../../domain/usecases/get_daily_vocab.dart';
import '../../domain/usecases/update_vocab_mastery.dart';

class VocabProvider extends ChangeNotifier {
  final VocabRepositoryImpl _repository;
  final GetDailyVocab _getDailyVocab;
  final UpdateVocabMastery _updateVocabMastery;

  VocabProvider()
      : _repository = VocabRepositoryImpl(
          localDatasource: VocabLocalDatasourceImpl(),
          progressService: ProgressService.instance,
        ),
        _getDailyVocab = GetDailyVocab(
          repository: VocabRepositoryImpl(
            localDatasource: VocabLocalDatasourceImpl(),
            progressService: ProgressService.instance,
          ),
        ),
        _updateVocabMastery = UpdateVocabMastery(
          repository: VocabRepositoryImpl(
            localDatasource: VocabLocalDatasourceImpl(),
            progressService: ProgressService.instance,
          ),
        );

  // State
  List<VocabItem> _allVocab = [];
  List<VocabItem> _dailyVocab = [];
  VocabItem? _currentVocab;
  int _currentIndex = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<VocabItem> get allVocab => _allVocab;
  List<VocabItem> get dailyVocab => _dailyVocab;
  VocabItem? get currentVocab => _currentVocab;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _currentIndex < _dailyVocab.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  /// โหลดคำศัพท์ทั้งหมด
  Future<void> loadAllVocab() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allVocab = await _repository.getAllVocab();
    } catch (e) {
      _error = 'ไม่สามารถโหลดคำศัพท์ได้: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// โหลดคำศัพท์สำหรับวันนี้
  Future<void> loadDailyVocab() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dailyVocab = await _getDailyVocab.execute();
      if (_dailyVocab.isNotEmpty) {
        _currentVocab = _dailyVocab[0];
        _currentIndex = 0;
      }
    } catch (e) {
      _error = 'ไม่สามารถโหลดคำศัพท์วันนี้ได้: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ไปคำถัดไป
  void nextVocab() {
    if (hasNext) {
      _currentIndex++;
      _currentVocab = _dailyVocab[_currentIndex];
      notifyListeners();
    }
  }

  /// ไปคำก่อนหน้า
  void previousVocab() {
    if (hasPrevious) {
      _currentIndex--;
      _currentVocab = _dailyVocab[_currentIndex];
      notifyListeners();
    }
  }

  /// อัพเดท mastery เมื่อผู้ใช้ตอบ
  Future<void> updateMastery(String vocabId, bool isCorrect) async {
    final currentLevel =
        await ProgressService.instance.getVocabMastery(vocabId);
    await _updateVocabMastery.execute(
      vocabId: vocabId,
      isCorrect: isCorrect,
      currentLevel: currentLevel,
    );
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _currentIndex = 0;
    if (_dailyVocab.isNotEmpty) {
      _currentVocab = _dailyVocab[0];
    }
    notifyListeners();
  }
}
