/// Exam Taking Screen with Timer and JSON Loading
library;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/services/study_time_service.dart';
import '../widgets/question_card.dart';

class ExamTakingScreen extends StatefulWidget {
  final String packId;

  const ExamTakingScreen({super.key, required this.packId});

  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen> {
  final StudyTimeService _studyTimeService = StudyTimeService();
  int _currentIndex = 0;
  final Map<int, int> _answers = {};
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;

  // Timer variables
  Timer? _timer;
  int _totalSeconds = 60 * 60; // Default 60 minutes
  int _remainingSeconds = 60 * 60;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _studyTimeService.startSession('exam');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _studyTimeService.endSession();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      // Determine which JSON file to load based on packId
      String jsonPath;
      switch (widget.packId) {
        case 'beginner_basic':
          jsonPath = 'assets/data/exam_pack_beginner_basic.json';
          break;
        case 'beginner_everyday':
          jsonPath = 'assets/data/exam_pack_beginner_everyday.json';
          break;
        case 'tgat_mock_1':
          jsonPath = 'assets/data/exam_pack_tgat_mock1.json';
          break;
        case 'tgat_mock_2':
          jsonPath = 'assets/data/exam_pack_tgat_mock2.json';
          break;
        case 'alevel_mock_1':
          jsonPath = 'assets/data/exam_pack_alevel_mock1.json';
          break;
        default:
          jsonPath = 'assets/data/exam_pack_tgat_mock1.json';
      }

      final String jsonString = await rootBundle.loadString(jsonPath);
      final data = json.decode(jsonString);

      // Get pack info
      final packs = data['packs'] as List;
      if (packs.isNotEmpty) {
        final timeLimit = packs[0]['timeLimit'] as int? ?? 60;
        _totalSeconds = timeLimit * 60;
        _remainingSeconds = _totalSeconds;
      }

      // Get questions
      final questions = data['questions'] as List;
      setState(() {
        _questions = questions.map((q) => q as Map<String, dynamic>).toList();
        _isLoading = false;
      });

      // Start timer
      _startTimer();
    } catch (e) {
      debugPrint('Error loading questions: $e');
      // Fallback to sample questions
      setState(() {
        _questions = _getSampleQuestions();
        _isLoading = false;
      });
      _startTimer();
    }
  }

  List<Map<String, dynamic>> _getSampleQuestions() {
    return [
      {
        'stem': 'The company _____ a new marketing strategy last month.',
        'choices': [
          'implement',
          'implemented',
          'implementing',
          'has implemented'
        ],
        'correctIndex': 1,
      },
      {
        'stem': 'If I _____ you, I would accept the job offer.',
        'choices': ['am', 'was', 'were', 'had been'],
        'correctIndex': 2,
      },
      {
        'stem': 'She suggested _____ the meeting to next week.',
        'choices': ['postpone', 'to postpone', 'postponing', 'postponed'],
        'correctIndex': 2,
      },
    ];
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        _showTimeUpDialog();
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    final percentage = _remainingSeconds / _totalSeconds;
    if (percentage > 0.5) return AppTheme.successColor;
    if (percentage > 0.25) return Colors.orange;
    return AppTheme.errorColor;
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.timer_off_rounded, color: AppTheme.errorColor),
              SizedBox(width: 8),
              Text('หมดเวลา!'),
            ],
          ),
          content: const Text(
              'เวลาในการทำข้อสอบหมดแล้ว คำตอบของคุณจะถูกส่งโดยอัตโนมัติ'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _submitExam();
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppTheme.examColor),
              child: const Text('ดูผลสอบ'),
            ),
          ],
        );
      },
    );
  }

  bool get _hasNext => _currentIndex < _questions.length - 1;
  bool get _hasPrevious => _currentIndex > 0;
  int get _answeredCount => _answers.length;
  bool get _isComplete => _answeredCount == _questions.length;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('กำลังโหลด...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('ข้อสอบ')),
        body: const Center(child: Text('ไม่พบข้อสอบ')),
      );
    }

    final currentQ = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('ข้อ ${_currentIndex + 1}/${_questions.length}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _showExitConfirmation,
        ),
        actions: [
          // Timer Display
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getTimerColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getTimerColor(), width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_rounded,
                  color: _getTimerColor(),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(
                    color: _getTimerColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _showQuestionNav,
            icon: const Icon(Icons.grid_view_rounded),
            label: Text('$_answeredCount/${_questions.length}'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: AppTheme.examColor.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(AppTheme.examColor),
            ),

            // Question
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: QuestionCard(
                  stem: currentQ['stem'] as String,
                  choices: (currentQ['choices'] as List).cast<String>(),
                  selectedIndex: _answers[_currentIndex],
                  onSelect: (index) {
                    setState(() => _answers[_currentIndex] = index);
                  },
                ),
              ),
            ),

            // Navigation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
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
                  if (_hasPrevious)
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _currentIndex--),
                      icon: const Icon(Icons.chevron_left_rounded),
                      label: const Text('ก่อนหน้า'),
                    ),
                  const Spacer(),
                  if (_hasNext)
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _currentIndex++),
                      icon: const Icon(Icons.chevron_right_rounded),
                      label: const Text('ถัดไป'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.examColor,
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _isComplete ? _confirmSubmit : null,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('ส่งคำตอบ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('ออกจากข้อสอบ?'),
          content:
              const Text('คุณแน่ใจหรือไม่ว่าต้องการออก? คำตอบจะไม่ถูกบันทึก'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ทำต่อ'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.go('/exam');
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor),
              child: const Text('ออก'),
            ),
          ],
        );
      },
    );
  }

  void _showQuestionNav() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'เลือกข้อ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getTimerColor().withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer_rounded,
                            size: 16, color: _getTimerColor()),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(_remainingSeconds),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getTimerColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'ตอบแล้ว $_answeredCount/${_questions.length} ข้อ',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_questions.length, (index) {
                  final isAnswered = _answers.containsKey(index);
                  final isCurrent = index == _currentIndex;

                  return InkWell(
                    onTap: () {
                      setState(() => _currentIndex = index);
                      Navigator.pop(sheetContext);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppTheme.examColor
                            : isAnswered
                                ? AppTheme.successColor.withValues(alpha: 0.2)
                                : Theme.of(context)
                                    .dividerColor
                                    .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: isAnswered && !isCurrent
                            ? Border.all(color: AppTheme.successColor, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCurrent
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(AppTheme.examColor, 'กำลังทำ'),
                  const SizedBox(width: 16),
                  _buildLegendItem(AppTheme.successColor, 'ตอบแล้ว'),
                  const SizedBox(width: 16),
                  _buildLegendItem(
                      Theme.of(context).dividerColor.withValues(alpha: 0.3),
                      'ยังไม่ตอบ'),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  void _confirmSubmit() {
    if (_answeredCount < _questions.length) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('ยืนยันส่งคำตอบ?'),
            content: Text(
                'คุณยังตอบไม่ครบ ตอบแล้ว $_answeredCount/${_questions.length} ข้อ'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('ทำต่อ'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _submitExam();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor),
                child: const Text('ส่งเลย'),
              ),
            ],
          );
        },
      );
    } else {
      _submitExam();
    }
  }

  Future<void> _submitExam() async {
    _timer?.cancel();
    final timeUsed = _totalSeconds - _remainingSeconds;

    // Calculate score
    int correct = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i]['correctIndex']) {
        correct++;
      }
    }
    final percentage = (correct / _questions.length * 100).toInt();

    // Save exam result to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final examCount = (prefs.getInt('examCount') ?? 0) + 1;
      await prefs.setInt('examCount', examCount);

      // Save last 5 exams
      final examIndex = (examCount - 1) % 5;
      await prefs.setString('exam_${examIndex}_name', widget.packId);
      await prefs.setInt('exam_${examIndex}_score', correct);
      await prefs.setInt('exam_${examIndex}_total', _questions.length);
      await prefs.setString(
          'exam_${examIndex}_date', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error saving exam result: $e');
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                percentage >= 60
                    ? Icons.celebration_rounded
                    : Icons.school_rounded,
                color: percentage >= 60
                    ? AppTheme.successColor
                    : AppTheme.warningColor,
              ),
              const SizedBox(width: 8),
              const Text('ผลสอบ'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Score Circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: percentage >= 60
                        ? [
                            AppTheme.successColor,
                            AppTheme.successColor.withValues(alpha: 0.7)
                          ]
                        : [
                            AppTheme.errorColor,
                            AppTheme.errorColor.withValues(alpha: 0.7)
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (percentage >= 60
                              ? AppTheme.successColor
                              : AppTheme.errorColor)
                          .withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$correct',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '/${_questions.length}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 18, color: AppTheme.textSecondaryColor),
                    const SizedBox(width: 4),
                    Text(
                      'เวลาที่ใช้: ${_formatTime(timeUsed)}',
                      style:
                          const TextStyle(color: AppTheme.textSecondaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                percentage >= 80
                    ? 'ยอดเยี่ยม! 🎉'
                    : percentage >= 60
                        ? 'ผ่าน! 👍'
                        : 'ต้องฝึกเพิ่ม 💪',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showReviewAnswers();
              },
              child: const Text('ดูเฉลย'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go('/exam');
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppTheme.examColor),
              child: const Text('กลับหน้าหลัก'),
            ),
          ],
        );
      },
    );
  }

  void _showReviewAnswers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ReviewScreen(
          questions: _questions,
          answers: _answers,
          onClose: () {
            Navigator.pop(context);
            context.go('/exam');
          },
        ),
      ),
    );
  }
}

/// Review screen for showing answers after exam
class _ReviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final Map<int, int> answers;
  final VoidCallback onClose;

  const _ReviewScreen({
    required this.questions,
    required this.answers,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เฉลย'),
        backgroundColor: AppTheme.examColor,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];
          final userAnswer = answers[index];
          final correctAnswer = q['correctIndex'] as int;
          final isCorrect = userAnswer == correctAnswer;
          final choices = (q['choices'] as List).cast<String>();

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            isCorrect ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'ข้อ ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    q['stem'] as String,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(choices.length, (choiceIndex) {
                    final isUserChoice = userAnswer == choiceIndex;
                    final isCorrectChoice = correctAnswer == choiceIndex;

                    Color bgColor = Theme.of(context).cardColor;
                    Color borderColor = Colors.transparent;
                    IconData? icon;

                    if (isCorrectChoice) {
                      bgColor = AppTheme.successColor.withValues(alpha: 0.15);
                      borderColor = AppTheme.successColor;
                      icon = Icons.check_circle;
                    } else if (isUserChoice && !isCorrect) {
                      bgColor = AppTheme.errorColor.withValues(alpha: 0.15);
                      borderColor = AppTheme.errorColor;
                      icon = Icons.cancel;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: borderColor == Colors.transparent
                              ? Theme.of(context).dividerColor
                              : borderColor,
                          width: borderColor == Colors.transparent ? 1 : 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${String.fromCharCode(65 + choiceIndex)}. ${choices[choiceIndex]}',
                            ),
                          ),
                          if (icon != null)
                            Icon(
                              icon,
                              color: isCorrectChoice
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                              size: 20,
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
