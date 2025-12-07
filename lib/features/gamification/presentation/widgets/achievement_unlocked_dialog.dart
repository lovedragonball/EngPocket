/// Achievement Unlocked Dialog Widget
library;

import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/models/achievement.dart';

class AchievementUnlockedDialog extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;

  const AchievementUnlockedDialog({
    super.key,
    required this.achievement,
    this.onDismiss,
  });

  /// แสดง Achievement Unlocked Dialog
  static void show(
    BuildContext context, {
    required Achievement achievement,
  }) {
    try {
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        builder: (context) => AchievementUnlockedDialog(
          achievement: achievement,
          onDismiss: () => Navigator.of(context).pop(),
        ),
      );
    } catch (e) {
      // Ignore if dialog cannot be shown
    }
  }

  @override
  State<AchievementUnlockedDialog> createState() =>
      _AchievementUnlockedDialogState();
}

class _AchievementUnlockedDialogState extends State<AchievementUnlockedDialog>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _shineController;
  late AnimationController _sparkleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _badgeScaleAnimation;

  final List<_SparkleParticle> _sparkles = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();

    // Main animation
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_mainController);

    _badgeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 1.0),
    ));

    // Shine animation
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Sparkle animation
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Generate sparkles
    for (int i = 0; i < 20; i++) {
      _sparkles.add(_SparkleParticle(
        angle: _random.nextDouble() * 2 * pi,
        distance: 60 + _random.nextDouble() * 40,
        size: 4 + _random.nextDouble() * 4,
        delay: _random.nextDouble() * 0.5,
      ));
    }

    _mainController.forward();
    _shineController.repeat();
    _sparkleController.repeat();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _shineController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  Color get _rarityColor => Color(widget.achievement.rarity.colorValue);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
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
                  color: _rarityColor.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge with sparkles
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Sparkles
                      AnimatedBuilder(
                        animation: _sparkleController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(140, 140),
                            painter: _SparklePainter(
                              sparkles: _sparkles,
                              progress: _sparkleController.value,
                              color: _rarityColor,
                            ),
                          );
                        },
                      ),

                      // Shine ring
                      AnimatedBuilder(
                        animation: _shineController,
                        builder: (context, child) {
                          return Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                startAngle: _shineController.value * 2 * pi,
                                colors: [
                                  _rarityColor.withValues(alpha: 0.0),
                                  _rarityColor.withValues(alpha: 0.5),
                                  _rarityColor.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Badge
                      AnimatedBuilder(
                        animation: _badgeScaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _badgeScaleAnimation.value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _rarityColor,
                                _rarityColor.withValues(alpha: 0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _rarityColor.withValues(alpha: 0.4),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.achievement.icon,
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Achievement Unlocked!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),

                // Achievement name
                Text(
                  widget.achievement.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  widget.achievement.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Rarity and XP
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rarity badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _rarityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _rarityColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        widget.achievement.rarity.displayName,
                        style: TextStyle(
                          color: _rarityColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // XP reward
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            color: AppTheme.primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${widget.achievement.xpReward} XP',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Continue button
                ElevatedButton(
                  onPressed: widget.onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _rarityColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'ยอดเยี่ยม! ✨',
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
    );
  }
}

class _SparkleParticle {
  final double angle;
  final double distance;
  final double size;
  final double delay;

  _SparkleParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
  });
}

class _SparklePainter extends CustomPainter {
  final List<_SparkleParticle> sparkles;
  final double progress;
  final Color color;

  _SparklePainter({
    required this.sparkles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final sparkle in sparkles) {
      // Calculate sparkle animation phase
      final phase = (progress + sparkle.delay) % 1.0;
      final opacity = sin(phase * pi).clamp(0.0, 1.0);

      if (opacity > 0.1) {
        final distance = sparkle.distance * (0.8 + phase * 0.4);
        final x = center.dx + cos(sparkle.angle) * distance;
        final y = center.dy + sin(sparkle.angle) * distance;

        final paint = Paint()
          ..color = color.withValues(alpha: opacity * 0.8)
          ..style = PaintingStyle.fill;

        // Draw star shape
        _drawStar(canvas, Offset(x, y), sparkle.size * opacity, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const points = 4;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * 0.4;
      final angle = (i * pi / points) - pi / 2;
      final x = center.dx + cos(angle) * r;
      final y = center.dy + sin(angle) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
