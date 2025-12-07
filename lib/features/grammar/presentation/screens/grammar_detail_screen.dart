/// Grammar Detail Screen - Load grammar topic from JSON
library;

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/services/study_time_service.dart';
import '../../../../core/models/question.dart';

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
  QuizDifficulty _selectedDifficulty = QuizDifficulty.easy;
  int _selectedQuestionCount = 10;
  List<Map<String, dynamic>> _currentQuestions = [];

  // All available questions from separate file
  Map<String, List<Map<String, dynamic>>>? _allQuizQuestions;
  bool _isLoadingQuestions = false;

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

  Future<void> _loadQuizQuestions() async {
    if (_allQuizQuestions != null) return; // Already loaded

    setState(() => _isLoadingQuestions = true);

    try {
      // Get the topic number from ID (e.g., "grammar_001" -> "001")
      final topicNum = widget.topicId.replaceFirst('grammar_', '');

      // Find the tense name based on topic ID
      final tenseNames = {
        '001': 'present_simple',
        '002': 'present_continuous',
        '003': 'present_perfect',
        '004': 'present_perfect_continuous',
        '005': 'past_simple',
        '006': 'past_continuous',
        '007': 'past_perfect',
        '008': 'past_perfect_continuous',
        '009': 'future_simple',
        '010': 'future_continuous',
        '011': 'future_perfect',
        '012': 'future_perfect_continuous',
        '013': 'passive_voice',
      };

      final tenseName = tenseNames[topicNum];
      if (tenseName == null) {
        throw Exception('Unknown topic ID: ${widget.topicId}');
      }

      final filename =
          'assets/data/quiz/grammar_quiz_${topicNum}_$tenseName.json';
      final String jsonString = await rootBundle.loadString(filename);
      final Map<String, dynamic> data = json.decode(jsonString);

      _allQuizQuestions = {
        'easy': (data['easy'] as List)
            .map((q) => q as Map<String, dynamic>)
            .toList(),
        'medium': (data['medium'] as List)
            .map((q) => q as Map<String, dynamic>)
            .toList(),
        'hard': (data['hard'] as List)
            .map((q) => q as Map<String, dynamic>)
            .toList(),
      };

      if (mounted) {
        setState(() => _isLoadingQuestions = false);
      }
    } catch (e) {
      debugPrint('Error loading quiz questions: $e');
      // Fallback to embedded questions if separate file not found
      _allQuizQuestions = _getEmbeddedQuestions();
      if (mounted) {
        setState(() => _isLoadingQuestions = false);
      }
    }
  }

  Map<String, List<Map<String, dynamic>>> _getEmbeddedQuestions() {
    if (_topic == null) return {'easy': [], 'medium': [], 'hard': []};

    final quizQuestions = _topic!['quizQuestions'];
    if (quizQuestions == null) return {'easy': [], 'medium': [], 'hard': []};

    // Check format
    if (quizQuestions is Map) {
      return {
        'easy': (quizQuestions['easy'] as List?)
                ?.map((q) => q as Map<String, dynamic>)
                .toList() ??
            [],
        'medium': (quizQuestions['medium'] as List?)
                ?.map((q) => q as Map<String, dynamic>)
                .toList() ??
            [],
        'hard': (quizQuestions['hard'] as List?)
                ?.map((q) => q as Map<String, dynamic>)
                .toList() ??
            [],
      };
    } else if (quizQuestions is List) {
      // Old format - put all in 'easy'
      return {
        'easy': quizQuestions.map((q) => q as Map<String, dynamic>).toList(),
        'medium': [],
        'hard': [],
      };
    }

    return {'easy': [], 'medium': [], 'hard': []};
  }

  List<Map<String, dynamic>> _getQuestionsForDifficulty(
      QuizDifficulty difficulty) {
    final questions = _allQuizQuestions ?? _getEmbeddedQuestions();
    return questions[difficulty.name] ?? [];
  }

  int _getTotalQuestionCount(QuizDifficulty difficulty) {
    final questions = _allQuizQuestions ?? _getEmbeddedQuestions();
    return questions[difficulty.name]?.length ?? 0;
  }

  int get _correctCount {
    int count = 0;
    for (int i = 0; i < _currentQuestions.length; i++) {
      if (_answers[i] == _currentQuestions[i]['correctIndex']) {
        count++;
      }
    }
    return count;
  }

  void _showDifficultyDialog() async {
    // Load questions first
    await _loadQuizQuestions();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.quiz_rounded, color: AppTheme.grammarColor),
            SizedBox(width: 8),
            Text('เลือกระดับความยาก'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDifficultyOption(ctx, QuizDifficulty.easy,
                  Icons.sentiment_very_satisfied_rounded, Colors.green),
              const SizedBox(height: 12),
              _buildDifficultyOption(ctx, QuizDifficulty.medium,
                  Icons.sentiment_satisfied_rounded, Colors.orange),
              const SizedBox(height: 12),
              _buildDifficultyOption(ctx, QuizDifficulty.hard,
                  Icons.sentiment_dissatisfied_rounded, Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyOption(
      BuildContext ctx, QuizDifficulty difficulty, IconData icon, Color color) {
    final questionCount = _getTotalQuestionCount(difficulty);

    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: questionCount > 0
            ? () {
                Navigator.pop(ctx);
                _showQuestionCountDialog(difficulty);
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${difficulty.emoji} ${difficulty.label}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: questionCount > 0 ? color : Colors.grey,
                      ),
                    ),
                    Text(
                      'มี ${_formatNumber(questionCount)} ข้อ',
                      style: TextStyle(
                        fontSize: 12,
                        color: questionCount > 0
                            ? color.withValues(alpha: 0.8)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: questionCount > 0 ? color : Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  void _showQuestionCountDialog(QuizDifficulty difficulty) {
    final totalQuestions = _getTotalQuestionCount(difficulty);
    final difficultyColor = switch (difficulty) {
      QuizDifficulty.easy => Colors.green,
      QuizDifficulty.medium => Colors.orange,
      QuizDifficulty.hard => Colors.red,
    };

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: difficultyColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                difficulty.label,
                style: TextStyle(
                    fontSize: 14,
                    color: difficultyColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            const Text('เลือกจำนวนข้อ'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuestionCountOption(ctx, difficulty, 10, totalQuestions),
            const SizedBox(height: 8),
            _buildQuestionCountOption(ctx, difficulty, 12, totalQuestions),
            const SizedBox(height: 8),
            _buildQuestionCountOption(ctx, difficulty, 15, totalQuestions),
            const SizedBox(height: 8),
            _buildQuestionCountOption(ctx, difficulty, 20, totalQuestions),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCountOption(BuildContext ctx, QuizDifficulty difficulty,
      int count, int totalQuestions) {
    final isAvailable = totalQuestions >= count;

    return Material(
      color: isAvailable
          ? AppTheme.grammarColor.withValues(alpha: 0.1)
          : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isAvailable
            ? () {
                Navigator.pop(ctx);
                _startQuiz(difficulty, count);
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.format_list_numbered,
                color: isAvailable ? AppTheme.grammarColor : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                '$count ข้อ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isAvailable ? AppTheme.grammarColor : Colors.grey,
                ),
              ),
              if (count == 10) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'เร็ว',
                    style: TextStyle(fontSize: 10, color: Colors.green),
                  ),
                ),
              ],
              if (count == 20) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ท้าทาย',
                    style: TextStyle(fontSize: 10, color: Colors.purple),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _startQuiz(QuizDifficulty difficulty, int questionCount) {
    final allQuestions = _getQuestionsForDifficulty(difficulty);

    // Shuffle and pick random questions
    final shuffled = List<Map<String, dynamic>>.from(allQuestions)
      ..shuffle(Random());
    final selectedQuestions = shuffled.take(questionCount).toList();

    setState(() {
      _selectedDifficulty = difficulty;
      _selectedQuestionCount = questionCount;
      _currentQuestions = selectedQuestions;
      _showQuiz = true;
      _currentQuestion = 0;
      _answers.clear();
      _showResults = false;
    });
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
                    color: AppTheme.grammarColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: AppTheme.grammarColor),
                      SizedBox(width: 8),
                      Text('หลักการ',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _topic!['explanation'] as String,
                    style: const TextStyle(fontSize: 15, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quiz Button with question count info
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoadingQuestions ? null : _showDifficultyDialog,
                icon: _isLoadingQuestions
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.quiz_rounded),
                label:
                    Text(_isLoadingQuestions ? 'กำลังโหลด...' : 'ทำแบบฝึกหัด'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.grammarColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                '📚 มีคำถามมากกว่า 5,000 ข้อ • สุ่มใหม่ทุกครั้ง',
                style:
                    TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
              ),
            ),
            const SizedBox(height: 24),

            // Examples Section
            const Text('ตัวอย่างประโยค',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

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
    if (_currentQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('แบบฝึกหัด')),
        body: const Center(child: Text('ไม่มีแบบฝึกหัดสำหรับหัวข้อนี้')),
      );
    }

    final question = _currentQuestions[_currentQuestion];
    final difficultyColor = switch (_selectedDifficulty) {
      QuizDifficulty.easy => Colors.green,
      QuizDifficulty.medium => Colors.orange,
      QuizDifficulty.hard => Colors.red,
    };

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                _topic!['title'] as String,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: difficultyColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _selectedDifficulty.label,
                style: TextStyle(
                    fontSize: 12,
                    color: difficultyColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() => _showQuiz = false),
        ),
      ),
      body: Column(
        children: [
          // Progress
          LinearProgressIndicator(
            value: (_currentQuestion + 1) / _currentQuestions.length,
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
                    'ข้อ ${_currentQuestion + 1} จาก ${_currentQuestions.length}',
                    style: const TextStyle(
                        fontSize: 14, color: AppTheme.textSecondaryColor),
                  ),
                  const SizedBox(height: 12),

                  // Question
                  Text(
                    question['stem'] as String,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
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
                          onTap: () => setState(
                              () => _answers[_currentQuestion] = index),
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
                    onPressed: () => setState(() => _currentQuestion--),
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('ก่อนหน้า'),
                  ),
                const Spacer(),
                if (_currentQuestion < _currentQuestions.length - 1)
                  ElevatedButton.icon(
                    onPressed: _answers.containsKey(_currentQuestion)
                        ? () => setState(() => _currentQuestion++)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('ถัดไป'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.grammarColor),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _answers.length == _currentQuestions.length
                        ? () => setState(() => _showResults = true)
                        : null,
                    icon: const Icon(Icons.check),
                    label: const Text('ส่งคำตอบ'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsScreen() {
    final score = _currentQuestions.isNotEmpty
        ? (_correctCount / _currentQuestions.length * 100).round()
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
                '$_correctCount/${_currentQuestions.length} ข้อถูก',
                style: const TextStyle(
                    fontSize: 20, color: AppTheme.textSecondaryColor),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: switch (_selectedDifficulty) {
                    QuizDifficulty.easy => Colors.green.withValues(alpha: 0.1),
                    QuizDifficulty.medium =>
                      Colors.orange.withValues(alpha: 0.1),
                    QuizDifficulty.hard => Colors.red.withValues(alpha: 0.1),
                  },
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ระดับ ${_selectedDifficulty.label}',
                  style: TextStyle(
                    color: switch (_selectedDifficulty) {
                      QuizDifficulty.easy => Colors.green,
                      QuizDifficulty.medium => Colors.orange,
                      QuizDifficulty.hard => Colors.red,
                    },
                    fontWeight: FontWeight.w500,
                  ),
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
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 48),

              // Review answers button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showAnswerReview(),
                  icon: const Icon(Icons.visibility),
                  label: const Text('ดูเฉลย'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Retry with same settings
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _startQuiz(_selectedDifficulty, _selectedQuestionCount),
                  icon: const Icon(Icons.replay),
                  label: const Text('ทำใหม่ (สุ่มข้อใหม่)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.grammarColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Try different settings
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showQuiz = false;
                      _showResults = false;
                    });
                    _showDifficultyDialog();
                  },
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('เปลี่ยนระดับ/จำนวนข้อ'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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

  void _showAnswerReview() {
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
              const Text('เฉลยคำตอบ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _currentQuestions.length,
                  itemBuilder: (context, index) {
                    final q = _currentQuestions[index];
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
                              Text('ข้อ ${index + 1}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(q['stem'] as String),
                          const SizedBox(height: 12),
                          Text(
                            'คำตอบถูก: ${(q['choices'] as List)[correctIndex]}',
                            style: const TextStyle(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w500),
                          ),
                          if (!isCorrect && userAnswer != null)
                            Text(
                              'คำตอบของคุณ: ${(q['choices'] as List)[userAnswer]}',
                              style:
                                  const TextStyle(color: AppTheme.errorColor),
                            ),
                          if (q['explanation'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              q['explanation'] as String,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondaryColor),
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
          Text(english,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(thai,
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textSecondaryColor)),
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
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
