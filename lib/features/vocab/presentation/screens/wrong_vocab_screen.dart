/// Wrong Vocab Screen - หน้าแสดงคำศัพท์ที่ตอบผิดบ่อย
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../config/app_theme.dart';
import '../../../../core/services/srs_service.dart';
import '../../../../core/services/study_time_service.dart';
import '../../../../core/models/wrong_vocab.dart';

class WrongVocabScreen extends StatefulWidget {
  const WrongVocabScreen({super.key});

  @override
  State<WrongVocabScreen> createState() => _WrongVocabScreenState();
}

class _WrongVocabScreenState extends State<WrongVocabScreen> {
  final SrsService _srsService = SrsService();
  final StudyTimeService _studyTimeService = StudyTimeService();
  List<WrongVocab> _wrongVocabList = [];
  final Map<String, Map<String, dynamic>> _vocabDetails = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _studyTimeService.startSession('vocab');
  }

  @override
  void dispose() {
    _studyTimeService.endSession();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _srsService.init();

    // Get wrong vocab list
    _wrongVocabList = _srsService.getAllWrongVocab();

    if (_wrongVocabList.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    // Load vocab details for wrong words
    try {
      final vocabFiles = <String>[
        'assets/data/vocab_stock_500.json',
        for (int i = 2; i <= 101; i++) 'assets/data/vocab_part$i.json',
      ];

      final allVocab = <Map<String, dynamic>>[];
      for (final file in vocabFiles) {
        try {
          final jsonString = await rootBundle.loadString(file);
          final List<dynamic> data = json.decode(jsonString);
          allVocab.addAll(data.map((e) => e as Map<String, dynamic>));
        } catch (e) {
          // Skip if file not found
        }
      }

      // Create a map of vocab id to details
      for (final vocab in allVocab) {
        final id = vocab['id'] as String?;
        if (id != null) {
          _vocabDetails[id] = vocab;
        }
      }
    } catch (e) {
      debugPrint('Error loading vocab details: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 คำศัพท์ที่ต้องทบทวน'),
        actions: [
          if (_wrongVocabList.isNotEmpty)
            TextButton.icon(
              onPressed: _startPractice,
              icon: const Icon(Icons.play_arrow),
              label: const Text('ฝึกใหม่'),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_wrongVocabList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppTheme.successColor.withValues(alpha: 0.5),
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
            const Text(
              'ไม่มีคำศัพท์ที่ต้องทบทวน',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Summary card
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.errorColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: AppTheme.errorColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_wrongVocabList.length} คำที่ต้องทบทวน',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'คำศัพท์ที่ตอบผิดบ่อย ควรฝึกซ้ำเพิ่ม',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.builder(
            itemCount: _wrongVocabList.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final wrongVocab = _wrongVocabList[index];
              final details = _vocabDetails[wrongVocab.vocabId];
              return _buildVocabCard(wrongVocab, details);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVocabCard(WrongVocab wrongVocab, Map<String, dynamic>? details) {
    final word = details?['word'] ?? wrongVocab.vocabId;
    final translation = details?['translation'] ?? '-';
    final pos = details?['pos'] ?? '';
    final example = details?['example'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (pos.isNotEmpty)
                        Text(
                          pos,
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getWrongCountColor(wrongVocab.wrongCount)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ผิด ${wrongVocab.wrongCount} ครั้ง',
                    style: TextStyle(
                      color: _getWrongCountColor(wrongVocab.wrongCount),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              translation,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.primaryColor,
              ),
            ),
            if (example.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  example,
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'ผิดล่าสุด: ${_formatDate(wrongVocab.lastWrongDate)}',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getWrongCountColor(int count) {
    if (count >= 5) return Colors.red;
    if (count >= 3) return Colors.orange;
    return Colors.amber;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'วันนี้';
    } else if (diff.inDays == 1) {
      return 'เมื่อวาน';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} วันที่แล้ว';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _startPractice() {
    if (_wrongVocabList.isEmpty) return;

    // Get the vocab details for wrong vocab
    final practiceVocab = <Map<String, dynamic>>[];
    for (final wrong in _wrongVocabList) {
      final details = _vocabDetails[wrong.vocabId];
      if (details != null) {
        practiceVocab.add(details);
      }
    }

    if (practiceVocab.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่พบข้อมูลคำศัพท์'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Navigate to practice session with wrong vocab
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _WrongVocabPracticeScreen(
          practiceVocab: practiceVocab,
        ),
      ),
    );
  }
}

/// Practice screen specifically for wrong vocab
class _WrongVocabPracticeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> practiceVocab;

  const _WrongVocabPracticeScreen({required this.practiceVocab});

  @override
  State<_WrongVocabPracticeScreen> createState() =>
      _WrongVocabPracticeScreenState();
}

class _WrongVocabPracticeScreenState extends State<_WrongVocabPracticeScreen> {
  final StudyTimeService _studyTimeService = StudyTimeService();
  int _currentIndex = 0;
  bool _isFlipped = false;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _studyTimeService.startSession('vocab');
  }

  @override
  void dispose() {
    _studyTimeService.endSession();
    super.dispose();
  }

  Map<String, dynamic> get _currentVocab => widget.practiceVocab[_currentIndex];
  bool get _hasNext => _currentIndex < widget.practiceVocab.length - 1;

  void _flipCard() => setState(() => _isFlipped = !_isFlipped);

  void _markCorrect() {
    _correctCount++;
    _nextCard();
  }

  void _markWrong() {
    _nextCard();
  }

  void _nextCard() {
    setState(() => _isFlipped = false);

    if (_hasNext) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _currentIndex++);
      });
    } else {
      _showCompleteDialog();
    }
  }

  void _showCompleteDialog() {
    final percent = widget.practiceVocab.isNotEmpty
        ? (_correctCount / widget.practiceVocab.length * 100).round()
        : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: AppTheme.successColor),
            SizedBox(width: 8),
            Text('เสร็จสิ้น!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'จำได้ $_correctCount / ${widget.practiceVocab.length} คำ',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '$percent%',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.successColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('กลับ'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() {
                _currentIndex = 0;
                _correctCount = 0;
                _isFlipped = false;
              });
            },
            child: const Text('ทำใหม่'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1}/${widget.practiceVocab.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '✓ $_correctCount',
                style: const TextStyle(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentIndex + 1) / widget.practiceVocab.length,
                backgroundColor: AppTheme.errorColor.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation(AppTheme.errorColor),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCard(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isFlipped) _buildRatingButtons(),
              if (!_isFlipped)
                const Text(
                  'แตะเพื่อดูความหมาย',
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    final vocab = _currentVocab;

    return Card(
      key: ValueKey('$_currentIndex-$_isFlipped'),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isFlipped) ...[
              Text(
                vocab['word'] ?? '',
                style:
                    const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                vocab['pos'] ?? '',
                style: const TextStyle(color: AppTheme.textSecondaryColor),
              ),
            ] else ...[
              Text(
                vocab['word'] ?? '',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                vocab['translation'] ?? '',
                style:
                    const TextStyle(fontSize: 28, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 16),
              if (vocab['example'] != null &&
                  (vocab['example'] as String).isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    vocab['example'] ?? '',
                    style: const TextStyle(
                        fontSize: 14, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: _markWrong,
              icon: const Icon(Icons.close),
              label: const Text('ยังจำไม่ได้'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: _markCorrect,
              icon: const Icon(Icons.check),
              label: const Text('จำได้แล้ว'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
