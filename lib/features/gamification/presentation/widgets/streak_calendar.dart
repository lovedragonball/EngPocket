/// Streak Calendar Widget
library;

import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';

class StreakCalendar extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final List<DateTime>? activeDates;

  const StreakCalendar({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    this.activeDates,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header stats
          Row(
            children: [
              _StreakStat(
                icon: Icons.local_fire_department_rounded,
                label: 'Streak ปัจจุบัน',
                value: '$currentStreak วัน',
                color: AppTheme.examColor,
              ),
              const SizedBox(width: 16),
              _StreakStat(
                icon: Icons.emoji_events_rounded,
                label: 'Streak สูงสุด',
                value: '$longestStreak วัน',
                color: AppTheme.secondaryColor,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          // Week view (last 7 days)
          const Text(
            '7 วันที่ผ่านมา',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _WeekView(activeDates: activeDates ?? []),
        ],
      ),
    );
  }
}

class _StreakStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StreakStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekView extends StatelessWidget {
  final List<DateTime> activeDates;

  const _WeekView({required this.activeDates});

  static const _dayNames = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final date = today.subtract(Duration(days: 6 - index));
        final isActive = _isDateActive(date);
        final isToday = index == 6;

        return _DayCircle(
          dayName: _dayNames[date.weekday - 1],
          day: date.day,
          isActive: isActive,
          isToday: isToday,
        );
      }),
    );
  }

  bool _isDateActive(DateTime date) {
    for (final activeDate in activeDates) {
      if (activeDate.year == date.year &&
          activeDate.month == date.month &&
          activeDate.day == date.day) {
        return true;
      }
    }
    return false;
  }
}

class _DayCircle extends StatelessWidget {
  final String dayName;
  final int day;
  final bool isActive;
  final bool isToday;

  const _DayCircle({
    required this.dayName,
    required this.day,
    required this.isActive,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          dayName,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppTheme.examColor
                : Theme.of(context).dividerColor.withValues(alpha: 0.2),
            border: isToday
                ? Border.all(
                    color: AppTheme.primaryColor,
                    width: 2,
                  )
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.examColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isActive
                ? const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 20,
                  )
                : Text(
                    '$day',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// Compact streak display for header/home
class StreakBadge extends StatelessWidget {
  final int streak;
  final bool showAnimation;

  const StreakBadge({
    super.key,
    required this.streak,
    this.showAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.examColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.examColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showAnimation && streak > 0)
            _AnimatedFireIcon(streak: streak)
          else
            Icon(
              Icons.local_fire_department_rounded,
              color:
                  streak > 0 ? AppTheme.examColor : AppTheme.textSecondaryColor,
              size: 20,
            ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color:
                  streak > 0 ? AppTheme.examColor : AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedFireIcon extends StatefulWidget {
  final int streak;

  const _AnimatedFireIcon({required this.streak});

  @override
  State<_AnimatedFireIcon> createState() => _AnimatedFireIconState();
}

class _AnimatedFireIconState extends State<_AnimatedFireIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    if (widget.streak > 0) {
      _controller.repeat();
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
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: const Icon(
        Icons.local_fire_department_rounded,
        color: AppTheme.examColor,
        size: 20,
      ),
    );
  }
}
