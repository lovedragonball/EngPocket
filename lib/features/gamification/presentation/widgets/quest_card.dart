/// Quest Card Widget
library;

import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/models/quest.dart';

class QuestCard extends StatefulWidget {
  final Quest quest;
  final int currentValue;
  final bool isCompleted;
  final bool isClaimed;
  final VoidCallback? onClaimReward;

  const QuestCard({
    super.key,
    required this.quest,
    required this.currentValue,
    this.isCompleted = false,
    this.isClaimed = false,
    this.onClaimReward,
  });

  @override
  State<QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
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
  void didUpdateWidget(QuestCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentValue != widget.currentValue) {
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
    if (widget.quest.targetValue <= 0) return 1.0;
    return (widget.currentValue / widget.quest.targetValue).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _questColor {
    if (widget.isClaimed) return AppTheme.textSecondaryColor;
    if (widget.isCompleted) return AppTheme.successColor;
    return widget.quest.type == QuestType.daily
        ? AppTheme.primaryColor
        : AppTheme.secondaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isClaimed
            ? Theme.of(context).dividerColor.withValues(alpha: 0.1)
            : widget.isCompleted
                ? AppTheme.successColor.withValues(alpha: 0.05)
                : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isCompleted && !widget.isClaimed
              ? AppTheme.successColor.withValues(alpha: 0.5)
              : Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: widget.isCompleted && !widget.isClaimed ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _questColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: widget.isClaimed
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.textSecondaryColor,
                      size: 24,
                    )
                  : Text(
                      widget.quest.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.quest.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: widget.isClaimed
                              ? AppTheme.textSecondaryColor
                              : null,
                          decoration: widget.isClaimed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    // Quest type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _questColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.quest.type.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          color: _questColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.quest.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),

                // Progress bar
                Row(
                  children: [
                    Expanded(
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Stack(
                            children: [
                              // Background
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .dividerColor
                                      .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              // Progress
                              FractionallySizedBox(
                                widthFactor: _progressAnimation.value,
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: widget.isCompleted
                                          ? [
                                              AppTheme.successColor,
                                              AppTheme.successColor
                                                  .withValues(alpha: 0.8),
                                            ]
                                          : [
                                              _questColor,
                                              _questColor.withValues(
                                                  alpha: 0.8),
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${widget.currentValue}/${widget.quest.targetValue}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: widget.isCompleted
                            ? AppTheme.successColor
                            : AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Claim button or XP reward
          const SizedBox(width: 12),
          if (widget.isCompleted && !widget.isClaimed)
            _ClaimButton(
              xpReward: widget.quest.xpReward,
              onTap: widget.onClaimReward,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: widget.isClaimed
                    ? AppTheme.textSecondaryColor.withValues(alpha: 0.1)
                    : AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    color: widget.isClaimed
                        ? AppTheme.textSecondaryColor
                        : AppTheme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '+${widget.quest.xpReward}',
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.isClaimed
                          ? AppTheme.textSecondaryColor
                          : AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ClaimButton extends StatefulWidget {
  final int xpReward;
  final VoidCallback? onTap;

  const _ClaimButton({
    required this.xpReward,
    this.onTap,
  });

  @override
  State<_ClaimButton> createState() => _ClaimButtonState();
}

class _ClaimButtonState extends State<_ClaimButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppTheme.successColor,
                  Color(0xFF059669),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.successColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '+${widget.xpReward}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
