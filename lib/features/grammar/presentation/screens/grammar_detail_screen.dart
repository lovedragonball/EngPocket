/// Grammar Detail Screen - Load grammar topic from JSON
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/services/study_time_service.dart';

class GrammarDetailScreen extends StatefulWidget {
  final String topicId;

  const GrammarDetailScreen({super.key, required this.topicId});

  @override
  State<GrammarDetailScreen> createState() => _GrammarDetailScreenState();
}

class _GrammarDetailScreenState extends State<GrammarDetailScreen> {
  final StudyTimeService _studyTimeService = StudyTimeService();
  Map<String, dynamic>? _topic;
  bool _isLoading = true;

  // Quiz state
  bool _showQuiz = false;
  int _currentQuestion = 0;
  final Map<int, int> _answers = {};
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _loadTopic();
    _studyTimeService.startSession('grammar');
  }

  @override
  void dispose() {
    _studyTimeService.endSession();
    super.dispose();
  }

  Future<void> _loadTopic() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/grammar_topics.json',
      );
      final List<dynamic> topics = json.decode(jsonString);

      final topic = topics.firstWhere(
        (t) => t['id'] == widget.topicId,
        orElse: () => null,
      );

      if (mounted) {
        setState(() {
          _topic = topic as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading grammar topic: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int get _correctCount {
    if (_topic == null) return 0;
    int count = 0;
    final questions = _topic!['quizQuestions'] as List? ?? [];
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
        appBar: AppBar(title: const Text('กำลังโหลด...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_topic == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ไวยากรณ์')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text('ไม่พบหัวข้อนี้'),
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

    if (_showQuiz) {
      return _buildQuizScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_topic!['title'] as String),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explanation Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.grammarColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.grammarColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: AppTheme.grammarColor),
                      SizedBox(width: 8),
                      Text(
                        'หลักการ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _topic!['explanation'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quiz Button
            if ((_topic!['quizQuestions'] as List?)?.isNotEmpty ?? false) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showQuiz = true;
                      _currentQuestion = 0;
                      _answers.clear();
                      _showResults = false;
                    });
                  },
                  icon: const Icon(Icons.quiz_rounded),
                  label: const Text('ทำแบบฝึกหัด'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.grammarColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Examples Section
            const Text(
              'ตัวอย่างประโยค',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Dynamic examples from JSON
            ...(_topic!['examples'] as List? ?? []).map((example) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildExampleCard(
                  example['sentenceEn'] as String,
                  example['sentenceTh'] as String,
                  example['highlight'] as String,
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizScreen() {
    final questions = _topic!['quizQuestions'] as List? ?? [];
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('แบบฝึกหัด')),
        body: const Center(child: Text('ไม่มีแบบฝึกหัดสำหรับหัวข้อนี้')),
      );
    }

    final question = questions[_currentQuestion] as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('แบบฝึกหัด: ${_topic!['title']}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() => _showQuiz = false),
        ),
      ),
      body: Column(
        children: [
          // Progress
          LinearProgressIndicator(
            value: (_currentQuestion + 1) / questions.length,
            backgroundColor: AppTheme.grammarColor.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation(AppTheme.grammarColor),
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
                            ? AppTheme.grammarColor.withValues(alpha: 0.1)
                            : Theme.of(context).cardColor,
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
                                    ? AppTheme.grammarColor
                                    : Theme.of(context).dividerColor,
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
                                        ? AppTheme.grammarColor
                                        : Theme.of(context)
                                            .dividerColor
                                            .withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
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
                                          ? AppTheme.grammarColor
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
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
                      backgroundColor: AppTheme.grammarColor,
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
      ),
    );
  }

  Widget _buildResultsScreen() {
    final questions = _topic!['quizQuestions'] as List? ?? [];
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
                    : 'ลองทบทวนอีกครั้ง 💪',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 48),

              // Review answers button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showAnswerReview(questions),
                  icon: const Icon(Icons.visibility),
                  label: const Text('ดูเฉลย'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Retry button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showQuiz = true;
                      _showResults = false;
                      _currentQuestion = 0;
                      _answers.clear();
                    });
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('ทำใหม่'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.grammarColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Back button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showQuiz = false;
                      _showResults = false;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('กลับไปหน้าหลักการ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnswerReview(List questions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'เฉลยคำตอบ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index] as Map<String, dynamic>;
                    final correctIndex = q['correctIndex'] as int;
                    final userAnswer = _answers[index];
                    final isCorrect = userAnswer == correctIndex;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? AppTheme.successColor.withValues(alpha: 0.1)
                            : AppTheme.errorColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCorrect
                              ? AppTheme.successColor.withValues(alpha: 0.3)
                              : AppTheme.errorColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ข้อ ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(q['stem'] as String),
                          const SizedBox(height: 12),
                          Text(
                            'คำตอบถูก: ${(q['choices'] as List)[correctIndex]}',
                            style: const TextStyle(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (!isCorrect && userAnswer != null)
                            Text(
                              'คำตอบของคุณ: ${(q['choices'] as List)[userAnswer]}',
                              style: const TextStyle(
                                color: AppTheme.errorColor,
                              ),
                            ),
                          if (q['explanation'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              q['explanation'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleCard(String english, String thai, String highlight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            english,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            thai,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.grammarColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              highlight,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.grammarColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
