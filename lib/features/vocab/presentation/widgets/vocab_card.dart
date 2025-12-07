/// Vocab Card Widget
library;

import 'package:flutter/material.dart';
import '../../../../core/models/vocab_item.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/services/tts_service.dart';

class VocabCard extends StatefulWidget {
  final VocabItem vocab;
  final bool showTranslation;
  final VoidCallback? onTap;
  final VoidCallback? onKnow;
  final VoidCallback? onDontKnow;

  const VocabCard({
    super.key,
    required this.vocab,
    this.showTranslation = false,
    this.onTap,
    this.onKnow,
    this.onDontKnow,
  });

  @override
  State<VocabCard> createState() => _VocabCardState();
}

class _VocabCardState extends State<VocabCard> {
  bool _isFlipped = false;
  final TtsService _tts = TtsService();

  @override
  void didUpdateWidget(VocabCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vocab.id != widget.vocab.id) {
      _isFlipped = false;
    }
  }

  void _flip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isFlipped ? _buildBack() : _buildFront(),
      ),
    );
  }

  Widget _buildFront() {
    return Card(
      key: const ValueKey('front'),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.vocabColor.withValues(alpha: 0.1),
              AppTheme.vocabColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.vocabColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.vocab.partOfSpeech,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.vocabColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.vocab.word,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _tts.speak(widget.vocab.word),
                  icon: const Icon(
                    Icons.volume_up_rounded,
                    color: AppTheme.vocabColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'แตะเพื่อดูความหมาย',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack() {
    return Card(
      key: const ValueKey('back'),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.1),
              AppTheme.primaryColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                widget.vocab.word,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                widget.vocab.translation,
                style: const TextStyle(
                  fontSize: 20,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'ตัวอย่างประโยค:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.vocab.exampleEn,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.vocab.exampleTh,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            if (widget.onKnow != null && widget.onDontKnow != null)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onDontKnow,
                      icon: const Icon(Icons.close, color: AppTheme.errorColor),
                      label: const Text('ไม่รู้'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: const BorderSide(color: AppTheme.errorColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: widget.onKnow,
                      icon: const Icon(Icons.check),
                      label: const Text('รู้แล้ว'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
