/// Daily Vocab Screen - หน้าท่องศัพท์ประจำวัน
library;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/models/vocab_item.dart';
import '../../../../core/services/daily_vocab_service.dart';
import '../../../../core/services/study_time_service.dart';

class DailyVocabScreen extends StatefulWidget {
  const DailyVocabScreen({super.key});

  @override
  State<DailyVocabScreen> createState() => _DailyVocabScreenState();
}

class _DailyVocabScreenState extends State<DailyVocabScreen> {
  final DailyVocabService _vocabService = DailyVocabService();
  final StudyTimeService _studyTimeService = StudyTimeService();
  late FlutterTts _flutterTts;

  List<VocabItem> _vocab = [];
  DailyVocabProgress? _progress;
  bool _isLoading = true;
  bool _isSpeaking = false;
  bool _showTranslation = false;
  int _dailyGoal = 10;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadData();
    _studyTimeService.startSession('vocab');
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);

    _flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _loadData() async {
    try {
      // โหลด daily goal
      final prefs = await SharedPreferences.getInstance();
      _dailyGoal = prefs.getInt('daily_goal') ?? 10;

      // โหลดคำศัพท์ประจำวัน
      _vocab = await _vocabService.getDailyVocab(
        count: _dailyGoal,
        difficulty: VocabDifficulty.medium, // ใช้ระดับกลาง - คำที่ใช้บ่อย
      );

      // โหลด progress
      _progress = await _vocabService.loadProgress();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading daily vocab: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } else {
      await _flutterTts.speak(text);
    }
  }

  Future<void> _markLearned() async {
    if (_progress == null || _vocab.isEmpty) return;

    final currentVocab = _vocab[_progress!.currentIndex];
    _progress = await _vocabService.markWordLearned(currentVocab.id);

    setState(() {
      _showTranslation = false;
    });

    // ตรวจสอบว่าเสร็จแล้วหรือยัง
    if (_progress?.isCompleted == true) {
      await _markTaskCompleted();
      if (mounted) {
        _showCompletionDialog();
      }
    }
  }

  Future<void> _markTaskCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    bool alreadyDone = prefs.getBool('vocabDone') ?? false;
    if (!alreadyDone) {
      await prefs.setBool('vocabDone', true);
      final completed = (prefs.getInt('todayCompletedTasks') ?? 0) + 1;
      await prefs.setInt('todayCompletedTasks', completed);

      // เพิ่มจำนวนคำที่ท่อง
      final words = (prefs.getInt('totalLearnedWords') ?? 0) + _dailyGoal;
      await prefs.setInt('totalLearnedWords', words);
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration_rounded,
                size: 48,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ยอดเยี่ยม! 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ท่องศัพท์ครบ $_dailyGoal คำแล้ววันนี้!',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pop(true); // ส่ง true กลับว่าเสร็จแล้ว
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.vocabColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('กลับหน้าหลัก'),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    // ถ้ายังท่องไม่ครบ ถาม confirm
    if (_progress != null && !_progress!.isCompleted) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('ออกจากหน้านี้?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppTheme.warningColor,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'คุณท่องไปแล้ว ${_progress!.learnedIds.length}/${_vocab.length} คำ\n\n',
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const Text(
                'Progress จะถูกบันทึกไว้ สามารถกลับมาทำต่อได้ แต่จะยังไม่นับว่าทำเสร็จ',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ทำต่อ'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'ออก',
                style: TextStyle(color: AppTheme.errorColor),
              ),
            ),
          ],
        ),
      );
      return shouldExit ?? false;
    }
    return true;
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _studyTimeService.endSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ท่องศัพท์วันนี้ ${_progress?.learnedIds.length ?? 0}/$_dailyGoal',
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                context.pop();
              }
            },
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.vocabColor),
            SizedBox(height: 16),
            Text('กำลังโหลดคำศัพท์ประจำวัน...'),
          ],
        ),
      );
    }

    if (_vocab.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            const Text('ไม่มีคำศัพท์ให้ท่อง'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('กลับ'),
            ),
          ],
        ),
      );
    }

    if (_progress == null) {
      return const Center(child: Text('Error loading progress'));
    }

    final currentIndex = _progress!.currentIndex;
    final currentVocab = _vocab[currentIndex];

    return SafeArea(
      child: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: _progress!.learnedIds.length / _vocab.length,
            backgroundColor: AppTheme.vocabColor.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation(AppTheme.vocabColor),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // Flashcard
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showTranslation = !_showTranslation),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 280),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: _showTranslation
                            ? AppTheme.vocabColor.withValues(alpha: 0.1)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppTheme.vocabColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Part of speech badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.vocabColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              currentVocab.partOfSpeech,
                              style: const TextStyle(
                                color: AppTheme.vocabColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Word
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  currentVocab.word,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: () => _speak(currentVocab.word),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _isSpeaking
                                        ? AppTheme.vocabColor
                                        : AppTheme.vocabColor
                                            .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isSpeaking
                                        ? Icons.stop_rounded
                                        : Icons.volume_up_rounded,
                                    color: _isSpeaking
                                        ? Colors.white
                                        : AppTheme.vocabColor,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Translation (show/hide)
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _showTranslation ? 1 : 0,
                            child: Column(
                              children: [
                                const Divider(),
                                const SizedBox(height: 16),
                                Text(
                                  currentVocab.translation,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: AppTheme.vocabColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (currentVocab.exampleEn.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    '"${currentVocab.exampleEn}"',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          if (!_showTranslation) ...[
                            const SizedBox(height: 32),
                            const Text(
                              'แตะเพื่อดูคำแปล',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showTranslation ? _markLearned : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.vocabColor,
                        disabledBackgroundColor: Theme.of(context)
                            .disabledColor
                            .withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        currentIndex < _vocab.length - 1
                            ? 'คำถัดไป'
                            : 'เสร็จสิ้น ✓',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _showTranslation ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
