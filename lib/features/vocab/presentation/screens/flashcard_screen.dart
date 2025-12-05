/// Flashcard Screen - หน้าท่องศัพท์แบบ flashcard
library;

import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/models/vocab_item.dart';
import '../widgets/vocab_card.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _currentIndex = 0;

  // Sample data - จะถูกแทนที่ด้วยข้อมูลจริงจาก Provider
  final List<VocabItem> _sampleVocab = [
    const VocabItem(
      id: '1',
      word: 'achieve',
      translation: 'บรรลุ, ประสบความสำเร็จ',
      partOfSpeech: 'verb',
      exampleEn: 'She worked hard to achieve her goals.',
      exampleTh: 'เธอทำงานหนักเพื่อบรรลุเป้าหมาย',
      level: 'intermediate',
      packId: 'TGAT_V1',
      tags: ['TGAT', 'success'],
    ),
    const VocabItem(
      id: '2',
      word: 'benefit',
      translation: 'ประโยชน์, ผลดี',
      partOfSpeech: 'noun',
      exampleEn: 'Exercise has many health benefits.',
      exampleTh: 'การออกกำลังกายมีประโยชน์ต่อสุขภาพมากมาย',
      level: 'basic',
      packId: 'TGAT_V1',
      tags: ['TGAT', 'health'],
    ),
    const VocabItem(
      id: '3',
      word: 'challenge',
      translation: 'ความท้าทาย',
      partOfSpeech: 'noun',
      exampleEn: 'Learning a new language is a challenge.',
      exampleTh: 'การเรียนภาษาใหม่เป็นความท้าทาย',
      level: 'basic',
      packId: 'TGAT_V1',
      tags: ['TGAT', 'education'],
    ),
  ];

  VocabItem get _currentVocab => _sampleVocab[_currentIndex];
  bool get _hasNext => _currentIndex < _sampleVocab.length - 1;
  bool get _hasPrevious => _currentIndex > 0;

  void _nextCard() {
    if (_hasNext) {
      setState(() => _currentIndex++);
    }
  }

  void _previousCard() {
    if (_hasPrevious) {
      setState(() => _currentIndex--);
    }
  }

  void _onKnow() {
    // Mark word as known - show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${_currentVocab.word}" - จำได้แล้ว! ✓'),
        duration: const Duration(milliseconds: 800),
        backgroundColor: AppTheme.successColor,
      ),
    );
    _nextCard();
  }

  void _onDontKnow() {
    // Mark word for review - show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${_currentVocab.word}" - จะทบทวนอีกครั้ง'),
        duration: const Duration(milliseconds: 800),
        backgroundColor: AppTheme.warningColor,
      ),
    );
    _nextCard();
  }

  void _showSettings() {
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
                'ตั้งค่า Flashcard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.shuffle_rounded),
                title: const Text('สุ่มลำดับคำศัพท์'),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {},
                ),
              ),
              ListTile(
                leading: const Icon(Icons.replay_rounded),
                title: const Text('รีเซ็ตความก้าวหน้า'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.numbers_rounded),
                title: const Text('จำนวนคำต่อรอบ'),
                subtitle: const Text('10 คำ'),
                onTap: () {},
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard'),
        actions: [
          TextButton.icon(
            onPressed: () {
              _showSettings();
            },
            icon: const Icon(Icons.settings_rounded),
            label: const Text('ตั้งค่า'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(),
              const SizedBox(height: 24),

              // Vocab Card
              Expanded(
                child: VocabCard(
                  vocab: _currentVocab,
                  onKnow: _onKnow,
                  onDontKnow: _onDontKnow,
                ),
              ),
              const SizedBox(height: 24),

              // Navigation buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'คำที่ ${_currentIndex + 1} จาก ${_sampleVocab.length}',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            Text(
              '${((_currentIndex + 1) / _sampleVocab.length * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.vocabColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_currentIndex + 1) / _sampleVocab.length,
          backgroundColor: AppTheme.vocabColor.withValues(alpha: 0.2),
          valueColor: const AlwaysStoppedAnimation(AppTheme.vocabColor),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filled(
          onPressed: _hasPrevious ? _previousCard : null,
          icon: const Icon(Icons.chevron_left_rounded),
          style: IconButton.styleFrom(
            backgroundColor: _hasPrevious
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            foregroundColor: _hasPrevious ? AppTheme.primaryColor : Colors.grey,
          ),
        ),
        const SizedBox(width: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.vocabColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              ...List.generate(_sampleVocab.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentIndex
                        ? AppTheme.vocabColor
                        : AppTheme.vocabColor.withValues(alpha: 0.3),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(width: 24),
        IconButton.filled(
          onPressed: _hasNext ? _nextCard : null,
          icon: const Icon(Icons.chevron_right_rounded),
          style: IconButton.styleFrom(
            backgroundColor: _hasNext
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            foregroundColor: _hasNext ? AppTheme.primaryColor : Colors.grey,
          ),
        ),
      ],
    );
  }
}
