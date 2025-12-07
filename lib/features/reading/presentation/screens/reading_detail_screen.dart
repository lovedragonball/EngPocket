/// Reading Detail Screen - หน้าอ่านบทความและตอบคำถาม
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/services/study_time_service.dart';
import '../../data/reading_repository.dart';

class ReadingDetailScreen extends StatefulWidget {
  final String passageId;

  const ReadingDetailScreen({super.key, required this.passageId});

  @override
  State<ReadingDetailScreen> createState() => _ReadingDetailScreenState();
}

class _ReadingDetailScreenState extends State<ReadingDetailScreen> {
  final ReadingRepository _repository = ReadingRepository();
  final StudyTimeService _studyTimeService = StudyTimeService();

  bool _isLoading = true;
  bool _showQuestions = false;
  int _currentQuestion = 0;
  final Map<int, int> _answers = {};
  bool _showResults = false;

  Map<String, dynamic>? _passage;

  @override
  void initState() {
    super.initState();
    _loadPassage();
    _studyTimeService.startSession('reading');
  }

  @override
  void dispose() {
    _studyTimeService.endSession();
    super.dispose();
  }

  Future<void> _loadPassage() async {
    await _repository.init();
    if (mounted) {
      setState(() {
        _passage = _repository.getPassageById(widget.passageId);
        _isLoading = false;
      });
    }
  }

  int get _correctCount {
    if (_passage == null) return 0;
    int count = 0;
    final questions = _passage!['questions'] as List? ?? [];
    for (int i = 0; i < questions.length; i++) {
      if (_answers[i] == questions[i]['correctIndex']) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('อ่านบทความ')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_passage == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('อ่านบทความ')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text('ไม่พบบทความ'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('กลับ'),
              ),
            ],
          ),
        ),
      );
    }

    if (_showResults) {
      return _buildResultsScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_showQuestions ? 'คำถาม' : 'อ่านบทความ'),
        actions: [
          if (!_showQuestions)
            TextButton(
              onPressed: () => setState(() => _showQuestions = true),
              child: const Text('ตอบคำถาม →'),
            ),
        ],
      ),
      body: _showQuestions ? _buildQuestionView() : _buildReadingView(),
    );
  }

  Widget _buildReadingView() {
    final difficulty = _passage!['difficulty'] as String? ?? 'medium';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            _passage!['title'] as String,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Meta info
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer,
                        size: 16, color: AppTheme.accentColor),
                    const SizedBox(width: 4),
                    Text(
                      '~${((_passage!['wordCount'] as int? ?? 200) / 100).ceil()} นาที',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(difficulty).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getDifficultyLabel(difficulty),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getDifficultyColor(difficulty),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Content
          Text(
            _passage!['content'] as String,
            style: const TextStyle(
              fontSize: 16,
              height: 1.8,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 32),

          // Start Quiz Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _showQuestions = true),
              icon: const Icon(Icons.quiz_rounded),
              label: const Text('เริ่มตอบคำถาม'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionView() {
    final questions = _passage!['questions'] as List? ?? [];
    if (questions.isEmpty) {
      return const Center(child: Text('ไม่มีคำถามสำหรับบทความนี้'));
    }

    final question = questions[_currentQuestion] as Map<String, dynamic>;

    return Column(
      children: [
        // Progress
        LinearProgressIndicator(
          value: (_currentQuestion + 1) / questions.length,
          backgroundColor: AppTheme.accentColor.withValues(alpha: 0.2),
          valueColor: const AlwaysStoppedAnimation(AppTheme.accentColor),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question number
                Text(
                  'ข้อ ${_currentQuestion + 1} จาก ${questions.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                // Question
                Text(
                  question['stem'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Choices
                ...(question['choices'] as List).asMap().entries.map((entry) {
                  final index = entry.key;
                  final choice = entry.value as String;
                  final isSelected = _answers[_currentQuestion] == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: isSelected
                          ? AppTheme.accentColor.withValues(alpha: 0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _answers[_currentQuestion] = index;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.accentColor
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.accentColor
                                      : Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  choice,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isSelected
                                        ? AppTheme.accentColor
                                        : AppTheme.textPrimaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Navigation
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              if (_currentQuestion > 0)
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _currentQuestion--);
                  },
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('ก่อนหน้า'),
                ),
              const Spacer(),
              if (_currentQuestion < questions.length - 1)
                ElevatedButton.icon(
                  onPressed: _answers.containsKey(_currentQuestion)
                      ? () => setState(() => _currentQuestion++)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('ถัดไป'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _answers.length == questions.length
                      ? () => setState(() => _showResults = true)
                      : null,
                  icon: const Icon(Icons.check),
                  label: const Text('ส่งคำตอบ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsScreen() {
    final questions = _passage!['questions'] as List? ?? [];
    final score = questions.isNotEmpty
        ? (_correctCount / questions.length * 100).round()
        : 0;
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
                '$_correctCount/${questions.length} ข้อถูก',
                style: const TextStyle(
                  fontSize: 20,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                isPassed
                    ? score >= 80
                        ? 'ยอดเยี่ยมมาก! 🎉'
                        : 'ทำได้ดี! 👏'
                    : 'ลองอ่านอีกครั้ง 💪',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 48),

              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showQuestions = false;
                      _showResults = false;
                      _currentQuestion = 0;
                      _answers.clear();
                    });
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('อ่านอีกครั้ง'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
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
                  icon: const Icon(Icons.list),
                  label: const Text('กลับหน้ารวมบทความ'),
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return AppTheme.successColor;
      case 'medium':
        return AppTheme.warningColor;
      case 'hard':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return 'ง่าย';
      case 'medium':
        return 'ปานกลาง';
      case 'hard':
        return 'ยาก';
      default:
        return difficulty;
    }
  }
}
