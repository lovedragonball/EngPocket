/// Animated Counter Widget
library;

import 'package:flutter/material.dart';

class AnimatedCounter extends StatefulWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final String? prefix;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 500),
    this.prefix,
    this.suffix,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _previousValue = widget.value;
    _animation = IntTween(begin: widget.value, end: widget.value)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _animation = IntTween(begin: _previousValue, end: widget.value)
          .animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));

      _previousValue = widget.value;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix ?? ''}${_formatNumber(_animation.value)}${widget.suffix ?? ''}',
          style: widget.style,
        );
      },
    );
  }

  String _formatNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }
}

/// Animated XP Display with icon
class AnimatedXpDisplay extends StatelessWidget {
  final int xp;
  final TextStyle? style;
  final double iconSize;
  final bool showIcon;

  const AnimatedXpDisplay({
    super.key,
    required this.xp,
    this.style,
    this.iconSize = 16,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Icon(
            Icons.bolt_rounded,
            color: style?.color ?? Theme.of(context).colorScheme.primary,
            size: iconSize,
          ),
          const SizedBox(width: 4),
        ],
        AnimatedCounter(
          value: xp,
          style: style,
          suffix: ' XP',
        ),
      ],
    );
  }
}

/// Level Badge with animation
class AnimatedLevelBadge extends StatefulWidget {
  final int level;
  final double size;
  final Color? color;

  const AnimatedLevelBadge({
    super.key,
    required this.level,
    this.size = 32,
    this.color,
  });

  @override
  State<AnimatedLevelBadge> createState() => _AnimatedLevelBadgeState();
}

class _AnimatedLevelBadgeState extends State<AnimatedLevelBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousLevel = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_controller);

    _previousLevel = widget.level;
  }

  @override
  void didUpdateWidget(AnimatedLevelBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.level != widget.level && widget.level > _previousLevel) {
      _controller.forward(from: 0);
      _previousLevel = widget.level;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withValues(alpha: 0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${widget.level}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: widget.size * 0.4,
            ),
          ),
        ),
      ),
    );
  }
}
