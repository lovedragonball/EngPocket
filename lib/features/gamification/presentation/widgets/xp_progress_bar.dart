/// XP Progress Bar Widget
library;

import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';

class XpProgressBar extends StatefulWidget {
  final int currentXp;
  final int xpForNextLevel;
  final int level;
  final bool showLabels;
  final double height;
  final Color? barColor;
  final Color? backgroundColor;

  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.xpForNextLevel,
    required this.level,
    this.showLabels = true,
    this.height = 8,
    this.barColor,
    this.backgroundColor,
  });

  @override
  State<XpProgressBar> createState() => _XpProgressBarState();
}

class _XpProgressBarState extends State<XpProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _previousProgress = _calculateProgress();
    _progressAnimation = Tween<double>(
      begin: _previousProgress,
      end: _previousProgress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(XpProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentXp != widget.currentXp ||
        oldWidget.xpForNextLevel != widget.xpForNextLevel) {
      final newProgress = _calculateProgress();

      _progressAnimation = Tween<double>(
        begin: _previousProgress,
        end: newProgress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));

      _previousProgress = newProgress;
      _controller.forward(from: 0);
    }
  }

  double _calculateProgress() {
    if (widget.xpForNextLevel <= 0) return 1.0;
    final xpInLevel = widget.currentXp - (widget.level * widget.level * 100);
    final xpRequired =
        widget.xpForNextLevel - (widget.level * widget.level * 100);
    return (xpInLevel / xpRequired).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barColor = widget.barColor ?? AppTheme.primaryColor;
    final bgColor = widget.backgroundColor ??
        Theme.of(context).dividerColor.withValues(alpha: 0.3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showLabels) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${widget.level}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: barColor,
                  fontSize: 13,
                ),
              ),
              Text(
                '${widget.currentXp} / ${widget.xpForNextLevel} XP',
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                // Background
                Container(
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),
                ),
                // Progress
                FractionallySizedBox(
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    height: widget.height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          barColor,
                          barColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(widget.height / 2),
                      boxShadow: [
                        BoxShadow(
                          color: barColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                // Shine effect
                if (_progressAnimation.value > 0.1)
                  FractionallySizedBox(
                    widthFactor: _progressAnimation.value,
                    child: Container(
                      height: widget.height / 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.3),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(widget.height / 2),
                          topRight: Radius.circular(widget.height / 2),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
