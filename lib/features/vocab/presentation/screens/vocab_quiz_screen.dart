/// Vocab Quiz Screen - หน้าทำ Quiz คำศัพท์
library;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/models/vocab_item.dart';
import '../../../../core/services/study_time_service.dart';
import '../../../../core/services/vocab_quiz_service.dart';
import '../providers/vocab_quiz_provider.dart';

class VocabQuizScreen extends StatefulWidget {
  const VocabQuizScreen({super.key});

  @override
  State<VocabQuizScreen> createState() => _VocabQuizScreenState();
}

class _VocabQuizScreenState extends State<VocabQuizScreen> {
  VocabQuizProvider? _provider;
  late FlutterTts _flutterTts;
  final VocabQuizService _quizService = VocabQuizService();
  final StudyTimeService _studyTimeService = StudyTimeService();
  bool _isSpeaking = false;
  bool _isLoadingData = true;
  bool _statsSaved = false; // เพื่อไม่ให้บันทึกซ้ำ

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadVocabData();
    _studyTimeService.startSession('vocab');
  }

  /// โหลดข้อมูลคำศัพท์จาก VocabQuizService
  Future<void> _loadVocabData() async {
    try {
      // ใช้ VocabQuizService เพื่อโหลดข้อมูลอย่างประหยัดและหลีกเลี่ยงคำซ้ำ
      final quizData = await _quizService.loadQuizData(
        questionCount: 10,
        distractorMultiplier: 4, // โหลดคำเพิ่มสำหรับ distractor
      );

      if (mounted) {
        setState(() {
          _provider = VocabQuizProvider(
            vocab: quizData.quizVocab,
            distractorPool: quizData.distractorPool,
            questionCount: 10,
          );
          _provider!.addListener(_onProviderChange);
          _isLoadingData = false;
          _statsSaved = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading vocab data: $e');
      // Fallback to sample vocab
      if (mounted) {
        setState(() {
          _provider = VocabQuizProvider(
            vocab: _getSampleVocab(),
            questionCount: 10,
          );
          _provider!.addListener(_onProviderChange);
          _isLoadingData = false;
          _statsSaved = false;
        });
      }
    }
  }

  /// บันทึกสถิติเมื่อเล่นจบ
  Future<void> _saveStats() async {
    if (_statsSaved || _provider == null) return;

    await _quizService.updateStatsAfterGame(
      correctCount: _provider!.correctCount,
      wrongCount: _provider!.wrongCount,
    );
    _statsSaved = true;
  }

  /// เริ่มเกมใหม่
  Future<void> _restartGame() async {
    setState(() {
      _isLoadingData = true;
    });

    // ลบ listener เก่า
    _provider?.removeListener(_onProviderChange);
    _provider?.dispose();
    _provider = null;

    // โหลดข้อมูลใหม่
    await _loadVocabData();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      setState(() => _isSpeaking = true);
    });

    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() => _isSpeaking = false);
    });
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } else {
      await _flutterTts.speak(text);
    }
  }

  void _onProviderChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _studyTimeService.endSession();
    _provider?.removeListener(_onProviderChange);
    _provider?.dispose();
    super.dispose();
  }

  List<VocabItem> _getSampleVocab() {
    return const [
      VocabItem(
          id: 'v001',
          word: 'achieve',
          translation: 'บรรลุ, ประสบความสำเร็จ',
          partOfSpeech: 'verb',
          exampleEn: 'She worked hard to achieve her goals.',
          exampleTh: 'เธอทำงานหนักเพื่อบรรลุเป้าหมาย',
          level: 'intermediate',
          packId: 'TGAT_V1',
          tags: ['academic']),
      VocabItem(
          id: 'v002',
          word: 'benefit',
          translation: 'ประโยชน์, ผลดี',
          partOfSpeech: 'noun',
          exampleEn: 'Exercise has many health benefits.',
          exampleTh: 'การออกกำลังกายมีประโยชน์ต่อสุขภาพมากมาย',
          level: 'basic',
          packId: 'TGAT_V1',
          tags: ['health']),
      VocabItem(
          id: 'v003',
          word: 'challenge',
          translation: 'ความท้าทาย',
          partOfSpeech: 'noun',
          exampleEn: 'Learning a new language is a challenge.',
          exampleTh: 'การเรียนภาษาใหม่เป็นความท้าทาย',
          level: 'basic',
          packId: 'TGAT_V1',
          tags: ['academic']),
      VocabItem(
          id: 'v004',
          word: 'determine',
          translation: 'กำหนด, ตัดสินใจ',
          partOfSpeech: 'verb',
          exampleEn: 'We need to determine the best solution.',
          exampleTh: 'เราต้องกำหนดทางออกที่ดีที่สุด',
          level: 'intermediate',
          packId: 'TGAT_V1',
          tags: ['academic']),
      VocabItem(
          id: 'v005',
          word: 'environment',
          translation: 'สิ่งแวดล้อม',
          partOfSpeech: 'noun',
          exampleEn: 'We must protect the environment.',
          exampleTh: 'เราต้องปกป้องสิ่งแวดล้อม',
          level: 'basic',
          packId: 'TGAT_V1',
          tags: ['nature']),
      VocabItem(
          id: 'v006',
          word: 'essential',
          translation: 'จำเป็น, สำคัญ',
          partOfSpeech: 'adjective',
          exampleEn: 'Water is essential for life.',
          exampleTh: 'น้ำเป็นสิ่งจำเป็นสำหรับชีวิต',
          level: 'intermediate',
          packId: 'TGAT_V1',
          tags: ['importance']),
      VocabItem(
          id: 'v007',
          word: 'establish',
          translation: 'ก่อตั้ง, สถาปนา',
          partOfSpeech: 'verb',
          exampleEn: 'The company was established in 1990.',
          exampleTh: 'บริษัทก่อตั้งขึ้นในปี 1990',
          level: 'intermediate',
          packId: 'TGAT_V1',
          tags: ['business']),
      VocabItem(
          id: 'v008',
          word: 'evidence',
          translation: 'หลักฐาน',
          partOfSpeech: 'noun',
          exampleEn: 'There is no evidence to support this claim.',
          exampleTh: 'ไม่มีหลักฐานสนับสนุนข้อกล่าวอ้างนี้',
          level: 'intermediate',
          packId: 'TGAT_V1',
          tags: ['academic']),
      VocabItem(
          id: 'v009',
          word: 'factor',
          translation: 'ปัจจัย',
          partOfSpeech: 'noun',
          exampleEn: 'Cost is an important factor in the decision.',
          exampleTh: 'ต้นทุนเป็นปัจจัยสำคัญในการตัดสินใจ',
          level: 'intermediate',
          packId: 'TGAT_V1',
          tags: ['academic']),
      VocabItem(
          id: 'v010',
          word: 'fundamental',
          translation: 'พื้นฐาน, หลักการ',
          partOfSpeech: 'adjective',
          exampleEn: 'Reading is a fundamental skill.',
          exampleTh: 'การอ่านเป็นทักษะพื้นฐาน',
          level: 'intermediate',
          packId: 'TGAT_V1',
          tags: ['education']),
      VocabItem(
          id: 'v011',
          word: 'generate',
          translation: 'สร้าง, ผลิต',
          partOfSpeech: 'verb',
          exampleEn: 'Solar panels generate electricity.',
          exampleTh: 'แผงโซลาร์เซลล์ผลิตไฟฟ้า',
          level: 'intermediate',
          packId: 'TGAT_V1',
          tags: ['technology']),
      VocabItem(
          id: 'v012',
          word: 'identify',
          translation: 'ระบุ, บ่งชี้',
          partOfSpeech: 'verb',
          exampleEn: 'Can you identify the problem?',
          exampleTh: 'คุณสามารถระบุปัญหาได้ไหม?',
          level: 'intermediate',
          packId: 'TGAT_V1',
          tags: ['analysis']),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // แสดง loading ขณะโหลดข้อมูล
    if (_isLoadingData || _provider == null || _provider!.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vocab Quiz')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.vocabColor),
              SizedBox(height: 16),
              Text('กำลังโหลดคำศัพท์...'),
            ],
          ),
        ),
      );
    }

    if (_provider!.isFinished) {
      return _buildResultScreen();
    }

    // ใช้ local variable เพื่อหลีกเลี่ยง null check ซ้ำๆ
    final provider = _provider!;

    return Scaffold(
      appBar: AppBar(
        title:
            Text('ข้อ ${provider.currentIndex + 1}/${provider.totalQuestions}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirmation(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: provider.progress,
              backgroundColor: AppTheme.vocabColor.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(AppTheme.vocabColor),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Score indicator
                    _buildScoreIndicator(),
                    const SizedBox(height: 24),

                    // Question
                    _buildQuestionCard(),
                    const SizedBox(height: 24),

                    // Choices
                    ..._buildChoices(),

                    // Next button (shown after answering)
                    if (provider.showResult) ...[
                      const SizedBox(height: 24),
                      _buildNextButton(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildScoreBadge(
          icon: Icons.check_circle,
          color: AppTheme.successColor,
          count: _provider!.correctCount,
          label: 'ถูก',
        ),
        const SizedBox(width: 24),
        _buildScoreBadge(
          icon: Icons.cancel,
          color: AppTheme.errorColor,
          count: _provider!.wrongCount,
          label: 'ผิด',
        ),
      ],
    );
  }

  Widget _buildScoreBadge({
    required IconData icon,
    required Color color,
    required int count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '$count $label',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final question = _provider!.currentQuestion!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.vocabColor.withValues(alpha: isDark ? 0.2 : 0.1),
            AppTheme.vocabColor.withValues(alpha: isDark ? 0.1 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.vocabColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.vocabColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              question.vocab.partOfSpeech,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white : AppTheme.vocabColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  question.word,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppTheme.darkTextPrimaryColor
                        : AppTheme.textPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),
              // ปุ่มฟังเสียงคำศัพท์
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _speak(question.word),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isSpeaking
                          ? AppTheme.vocabColor
                          : AppTheme.vocabColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isSpeaking
                          ? Icons.stop_rounded
                          : Icons.volume_up_rounded,
                      color: _isSpeaking ? Colors.white : AppTheme.vocabColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'เลือกความหมายที่ถูกต้อง',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppTheme.darkTextSecondaryColor
                  : AppTheme.textSecondaryColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChoices() {
    final question = _provider!.currentQuestion!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final choicesCount = question.choices.length;

    return question.choices.asMap().entries.map((entry) {
      final index = entry.key;
      final choice = entry.value;
      final isSelected = _provider!.selectedAnswer == index;
      final isCorrect = index == question.correctIndex;
      final showResult = _provider!.showResult;
      final isLastItem = index == choicesCount - 1;

      Color backgroundColor;
      Color borderColor;
      Color textColor;
      IconData? icon;

      if (showResult) {
        if (isCorrect) {
          backgroundColor = AppTheme.successColor.withValues(alpha: 0.15);
          borderColor = AppTheme.successColor;
          textColor = isDark ? Colors.greenAccent : AppTheme.successColor;
          icon = Icons.check_circle;
        } else if (isSelected && !isCorrect) {
          backgroundColor = AppTheme.errorColor.withValues(alpha: 0.15);
          borderColor = AppTheme.errorColor;
          textColor = isDark ? Colors.redAccent : AppTheme.errorColor;
          icon = Icons.cancel;
        } else {
          backgroundColor =
              isDark ? Colors.grey.shade800 : Colors.grey.shade100;
          borderColor = isDark ? Colors.grey.shade600 : Colors.grey.shade300;
          textColor = isDark
              ? AppTheme.darkTextSecondaryColor
              : AppTheme.textSecondaryColor;
        }
      } else {
        backgroundColor = isDark ? AppTheme.darkCardColor : Colors.white;
        borderColor = AppTheme.vocabColor.withValues(alpha: 0.4);
        textColor =
            isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor;
      }

      return Padding(
        padding: EdgeInsets.only(bottom: isLastItem ? 0 : 12),
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: showResult ? null : () => _provider!.selectAnswer(index),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: borderColor.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      choice,
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        fontWeight: isSelected || (showResult && isCorrect)
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (icon != null) Icon(icon, color: textColor),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildNextButton() {
    final isCorrect =
        _provider!.selectedAnswer == _provider!.currentQuestion?.correctIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Feedback message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCorrect
                ? AppTheme.successColor.withValues(alpha: isDark ? 0.2 : 0.1)
                : AppTheme.warningColor.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCorrect
                  ? AppTheme.successColor.withValues(alpha: 0.3)
                  : AppTheme.warningColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isCorrect ? Icons.celebration : Icons.lightbulb_outline,
                color:
                    isCorrect ? AppTheme.successColor : AppTheme.warningColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isCorrect
                      ? 'ยอดเยี่ยม! 🎉'
                      : 'คำตอบที่ถูกต้องคือ: ${_provider!.currentQuestion?.correctAnswer}',
                  style: TextStyle(
                    color: isCorrect
                        ? (isDark ? Colors.greenAccent : AppTheme.successColor)
                        : (isDark
                            ? Colors.amber.shade300
                            : AppTheme.warningColor),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Next button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _provider!.nextQuestion(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.vocabColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _provider!.currentIndex < _provider!.totalQuestions - 1
                  ? 'ข้อถัดไป'
                  : 'ดูผลลัพธ์',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultScreen() {
    // บันทึกสถิติเมื่อเข้าหน้าผลลัพธ์
    _saveStats();

    final score = _provider!.score;
    final isPassed = score >= 60;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Result icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isPassed
                      ? AppTheme.successColor.withValues(alpha: 0.1)
                      : AppTheme.warningColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPassed ? Icons.emoji_events : Icons.school,
                  size: 60,
                  color:
                      isPassed ? AppTheme.successColor : AppTheme.warningColor,
                ),
              ),
              const SizedBox(height: 24),

              // Score
              Text(
                '$score%',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color:
                      isPassed ? AppTheme.successColor : AppTheme.warningColor,
                ),
              ),
              Text(
                '${_provider!.correctCount}/${_provider!.totalQuestions} ข้อ',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                      AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                isPassed
                    ? score >= 80
                        ? 'ยอดเยี่ยมมาก! 🎉'
                        : 'ผ่านแล้ว! 👏'
                    : 'ต้องฝึกเพิ่มอีกนิด 💪',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isPassed
                    ? 'คุณเก่งมาก ทำต่อไปนะ!'
                    : 'ลองทบทวนคำศัพท์แล้วกลับมาทำใหม่',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                      AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Buttons
              // ปุ่มทำใหม่อีกครั้ง - โหลดคำศัพท์ชุดใหม่จาก 10,000+ คำ
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _restartGame(),
                  icon: const Icon(Icons.replay),
                  label: const Text('ทำใหม่อีกครั้ง'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.vocabColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.home),
                  label: const Text('กลับหน้าหลัก'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ออกจาก Quiz?'),
        content: const Text('ความก้าวหน้าของคุณจะไม่ถูกบันทึก'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.pop();
            },
            child:
                const Text('ออก', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}
