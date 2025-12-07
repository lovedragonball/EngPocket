/// Flashcard Screen - หน้าท่องศัพท์แบบ flashcard พร้อม SRS
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/services/srs_service.dart';
import '../../../../core/services/study_time_service.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final SrsService _srsService = SrsService();
  final StudyTimeService _studyTimeService = StudyTimeService();
  List<Map<String, dynamic>> _sessionVocab = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isFlipped = false;
  int _sessionCorrect = 0;
  int _sessionTotal = 0;

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
    final prefs = await SharedPreferences.getInstance();
    final dailyGoal = prefs.getInt('dailyGoal') ?? 10;

    try {
      final dueIds = _srsService.getActualDueCardIds();
      final newWordsNeeded = dailyGoal;
      const reviewLimit = 20;

      List<Map<String, dynamic>> newVocab = [];
      List<Map<String, dynamic>> reviewVocab = [];

      // Dynamic generation: vocab_stock_500.json + vocab_part2.json to vocab_part101.json
      final vocabFiles = <String>[
        'assets/data/vocab_stock_500.json',
        for (int i = 2; i <= 101; i++) 'assets/data/vocab_part$i.json',
      ];

      int loadedNewCount = 0;
      Set<String> foundDueIds = {};

      for (final file in vocabFiles) {
        // Stop if we have enough new words AND (found all due words OR reached review limit OR no due words)
        if (loadedNewCount >= newWordsNeeded &&
            (dueIds.isEmpty ||
                foundDueIds.length >= dueIds.length ||
                reviewVocab.length >= reviewLimit)) {
          break;
        }

        try {
          final jsonString = await rootBundle.loadString(file);
          final List<dynamic> data = json.decode(jsonString);

          for (final item in data) {
            final vocab = item as Map<String, dynamic>;
            final id = vocab['id'] as String;

            if (dueIds.contains(id)) {
              if (reviewVocab.length < reviewLimit &&
                  !foundDueIds.contains(id)) {
                reviewVocab.add(vocab);
                foundDueIds.add(id);
              }
            } else if (!_srsService.isLearned(id)) {
              if (loadedNewCount < newWordsNeeded) {
                newVocab.add(vocab);
                loadedNewCount++;
              }
            }
          }
        } catch (e) {
          debugPrint('Could not load $file: $e');
        }
      }

      _sessionVocab = [...newVocab, ...reviewVocab];
      debugPrint('Loaded ${_sessionVocab.length} vocabulary words for session');
    } catch (e) {
      debugPrint('Error loading vocab: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Map<String, dynamic> get _currentVocab => _sessionVocab[_currentIndex];
  bool get _hasNext => _currentIndex < _sessionVocab.length - 1;

  void _flipCard() => setState(() => _isFlipped = !_isFlipped);

  void _rateCard(int quality) async {
    final vocabId = _currentVocab['id'] as String;
    await _srsService.recordReview(vocabId, quality);

    _sessionTotal++;
    if (quality >= 2) _sessionCorrect++;

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
    final percent =
        _sessionTotal > 0 ? (_sessionCorrect / _sessionTotal * 100).round() : 0;
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
            Text('ท่องได้ $_sessionCorrect / $_sessionTotal คำ',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('$percent%',
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('กลับหน้าหลัก'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() {
                _currentIndex = 0;
                _sessionCorrect = 0;
                _sessionTotal = 0;
              });
            },
            child: const Text('ท่องใหม่'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcard')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_sessionVocab.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcard')),
        body: const Center(child: Text('ไม่มีคำศัพท์')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1}/${_sessionVocab.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
                child: Text('✓ $_sessionCorrect',
                    style: const TextStyle(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _sessionVocab.length,
                backgroundColor: AppTheme.vocabColor.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation(AppTheme.vocabColor),
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
                const Text('แตะเพื่อดูความหมาย',
                    style: TextStyle(color: AppTheme.textSecondaryColor)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    final vocab = _currentVocab;
    final imageUrl = vocab['imageUrl'] as String?;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

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
            // Show image if available
            if (hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 120,
                  width: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                  loadingBuilder: (_, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      height: 120,
                      width: 180,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (!_isFlipped) ...[
              Text(vocab['word'] ?? '',
                  style: const TextStyle(
                      fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(vocab['pos'] ?? '',
                  style: const TextStyle(color: AppTheme.textSecondaryColor)),
            ] else ...[
              Text(vocab['word'] ?? '',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(vocab['translation'] ?? '',
                  style: const TextStyle(
                      fontSize: 28, color: AppTheme.primaryColor)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12)),
                child: Text(vocab['example'] ?? '',
                    style: const TextStyle(
                        fontSize: 14, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center),
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
        _ratingButton(1, 'ยาก', Colors.orange, Icons.sentiment_dissatisfied),
        _ratingButton(3, 'ง่าย', Colors.blue, Icons.sentiment_very_satisfied),
      ],
    );
  }

  Widget _ratingButton(int quality, String label, Color color, IconData icon) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: () => _rateCard(quality),
          icon: Icon(icon),
          style: IconButton.styleFrom(
              backgroundColor: color.withValues(alpha: 0.1),
              foregroundColor: color),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
