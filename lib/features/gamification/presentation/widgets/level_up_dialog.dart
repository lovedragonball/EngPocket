/// Level Up Dialog Widget
library;

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/models/user_gamification.dart';

class LevelUpDialog extends StatefulWidget {
  final int newLevel;
  final VoidCallback? onDismiss;

  const LevelUpDialog({
    super.key,
    required this.newLevel,
    this.onDismiss,
  });

  /// แสดง Level Up Dialog
  static void show(
    BuildContext context, {
    required int newLevel,
  }) {
    try {
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        builder: (context) => LevelUpDialog(
          newLevel: newLevel,
          onDismiss: () => Navigator.of(context).pop(),
        ),
      );
    } catch (e) {
      // Ignore if dialog cannot be shown
    }
  }

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  final List<_ConfettiParticle> _confetti = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();

    // Main animation
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_mainController);

    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.05, end: 0.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_mainController);

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Generate confetti particles
    for (int i = 0; i < 50; i++) {
      _confetti.add(_ConfettiParticle(
        color: _getRandomColor(),
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.3 - 0.3,
        speed: 0.3 + _random.nextDouble() * 0.7,
        angle: _random.nextDouble() * 2 * pi,
        size: 8 + _random.nextDouble() * 8,
      ));
    }

    _mainController.forward();
    _confettiController.repeat();
  }

  Color _getRandomColor() {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.examColor,
      AppTheme.successColor,
      const Color(0xFFEC4899), // Pink
      const Color(0xFF8B5CF6), // Purple
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _mainController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final levelTitle = LevelTitle.fromLevel(widget.newLevel);

    return Stack(
      children: [
        // Confetti layer
        AnimatedBuilder(
          animation: _confettiController,
          builder: (context, child) {
            return CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _ConfettiPainter(
                confetti: _confetti,
                progress: _confettiController.value,
              ),
            );
          },
        ),

        // Dialog
        Center(
          child: AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotateAnimation.value,
                  child: child,
                ),
              );
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Crown/Star icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.examColor,
                            AppTheme.examColor.withValues(alpha: 0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.examColor.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'LEVEL UP!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Level number
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Level ${widget.newLevel}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Level title
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          levelTitle.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          levelTitle.title,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppTheme.textSecondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Continue button
                    ElevatedButton(
                      onPressed: widget.onDismiss,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'เยี่ยมไปเลย! 🎉',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfettiParticle {
  final Color color;
  final double x;
  final double y;
  final double speed;
  final double angle;
  final double size;

  _ConfettiParticle({
    required this.color,
    required this.x,
    required this.y,
    required this.speed,
    required this.angle,
    required this.size,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> confetti;
  final double progress;

  _ConfettiPainter({
    required this.confetti,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in confetti) {
      final yOffset = (particle.y + progress * particle.speed * 1.5) % 1.3;
      final xOffset =
          particle.x + sin(progress * 4 * pi + particle.angle) * 0.05;

      if (yOffset > 0 && yOffset < 1.0) {
        final paint = Paint()
          ..color = particle.color.withValues(alpha: (1 - yOffset) * 0.8)
          ..style = PaintingStyle.fill;

        canvas.save();
        canvas.translate(
          xOffset * size.width,
          yOffset * size.height,
        );
        canvas.rotate(progress * 4 * pi + particle.angle);

        // Draw rectangle confetti
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.6,
          ),
          paint,
        );

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
