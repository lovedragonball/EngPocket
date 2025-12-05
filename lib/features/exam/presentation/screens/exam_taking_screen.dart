/// Exam Taking Screen
library;

import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../widgets/question_card.dart';

class ExamTakingScreen extends StatefulWidget {
  final String packId;

  const ExamTakingScreen({super.key, required this.packId});

  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen> {
  int _currentIndex = 0;
  final Map<int, int> _answers = {};

  // Sample questions
  final List<Map<String, dynamic>> _sampleQuestions = [
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

  bool get _hasNext => _currentIndex < _sampleQuestions.length - 1;
  bool get _hasPrevious => _currentIndex > 0;
  int get _answeredCount => _answers.length;
  bool get _isComplete => _answeredCount == _sampleQuestions.length;

  @override
  Widget build(BuildContext context) {
    final currentQ = _sampleQuestions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('ข้อ ${_currentIndex + 1}/${_sampleQuestions.length}'),
        actions: [
          TextButton.icon(
            onPressed: _showQuestionNav,
            icon: const Icon(Icons.grid_view_rounded),
            label: Text('$_answeredCount/${_sampleQuestions.length}'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _sampleQuestions.length,
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
                      onPressed: _isComplete ? _submitExam : null,
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

  void _showQuestionNav() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'เลือกข้อ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_sampleQuestions.length, (index) {
                  final isAnswered = _answers.containsKey(index);
                  final isCurrent = index == _currentIndex;

                  return InkWell(
                    onTap: () {
                      setState(() => _currentIndex = index);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppTheme.examColor
                            : isAnswered
                                ? AppTheme.successColor.withValues(alpha: 0.2)
                                : Colors.grey.shade200,
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
                                : AppTheme.textPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _submitExam() {
    // Calculate score and show result dialog
    showDialog(
      context: context,
      builder: (context) {
        int correct = 0;
        for (int i = 0; i < _sampleQuestions.length; i++) {
          if (_answers[i] == _sampleQuestions[i]['correctIndex']) {
            correct++;
          }
        }
        final percentage = (correct / _sampleQuestions.length * 100).toInt();

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('ผลสอบ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$correct/${_sampleQuestions.length}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: percentage >= 60
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 24,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                percentage >= 80
                    ? 'ยอดเยี่ยม! 🎉'
                    : percentage >= 60
                        ? 'ผ่าน! 👍'
                        : 'ต้องฝึกเพิ่ม 💪',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('กลับหน้าหลัก'),
            ),
          ],
        );
      },
    );
  }
}
