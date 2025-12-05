/// Today Task Card Widget
library;

import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';

class TodayTaskCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDone;
  final VoidCallback onTap;

  const TodayTaskCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.isDone = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isDone ? 0 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDone ? Colors.grey.shade100 : Colors.white,
      child: InkWell(
        onTap: isDone ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDone 
                      ? Colors.grey.shade300 
                      : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDone ? Icons.check_rounded : icon,
                  color: isDone ? Colors.grey : color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDone ? Colors.grey : AppTheme.textPrimaryColor,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDone ? Colors.grey : AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isDone)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textSecondaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
