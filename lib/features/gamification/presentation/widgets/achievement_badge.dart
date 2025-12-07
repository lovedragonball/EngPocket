/// Achievement Badge Widget
library;

import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/models/achievement.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final double progress;
  final bool showProgress;
  final double size;
  final VoidCallback? onTap;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.isUnlocked = false,
    this.progress = 0.0,
    this.showProgress = true,
    this.size = 80,
    this.onTap,
  });

  Color get _rarityColor => Color(achievement.rarity.colorValue);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge
          Stack(
            alignment: Alignment.center,
            children: [
              // Background circle with progress
              if (showProgress && !isUnlocked)
                SizedBox(
                  width: size + 8,
                  height: size + 8,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3,
                    backgroundColor:
                        Theme.of(context).dividerColor.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation(
                        _rarityColor.withValues(alpha: 0.5)),
                  ),
                ),

              // Badge container
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isUnlocked
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _rarityColor,
                            _rarityColor.withValues(alpha: 0.7),
                          ],
                        )
                      : null,
                  color: isUnlocked
                      ? null
                      : Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  boxShadow: isUnlocked
                      ? [
                          BoxShadow(
                            color: _rarityColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isUnlocked
                      ? Text(
                          achievement.icon,
                          style: TextStyle(fontSize: size * 0.45),
                        )
                      : Icon(
                          achievement.isSecret
                              ? Icons.help_outline_rounded
                              : Icons.lock_outline_rounded,
                          color: AppTheme.textSecondaryColor
                              .withValues(alpha: 0.5),
                          size: size * 0.35,
                        ),
                ),
              ),

              // Secret badge indicator
              if (achievement.isSecret && !isUnlocked)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.visibility_off_rounded,
                      size: size * 0.2,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          SizedBox(
            width: size + 20,
            child: Text(
              isUnlocked || !achievement.isSecret ? achievement.title : '???',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isUnlocked ? null : AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Rarity indicator
          if (isUnlocked) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _rarityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                achievement.rarity.displayName,
                style: TextStyle(
                  fontSize: 10,
                  color: _rarityColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Achievement List Item Widget - สำหรับแสดงในรายการ
class AchievementListItem extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final double progress;
  final VoidCallback? onTap;

  const AchievementListItem({
    super.key,
    required this.achievement,
    this.isUnlocked = false,
    this.progress = 0.0,
    this.onTap,
  });

  Color get _rarityColor => Color(achievement.rarity.colorValue);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked
              ? _rarityColor.withValues(alpha: 0.05)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? _rarityColor.withValues(alpha: 0.3)
                : Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // Badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isUnlocked
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _rarityColor,
                          _rarityColor.withValues(alpha: 0.7),
                        ],
                      )
                    : null,
                color: isUnlocked
                    ? null
                    : Theme.of(context).dividerColor.withValues(alpha: 0.3),
              ),
              child: Center(
                child: isUnlocked
                    ? Text(
                        achievement.icon,
                        style: const TextStyle(fontSize: 28),
                      )
                    : Icon(
                        achievement.isSecret
                            ? Icons.help_outline_rounded
                            : Icons.lock_outline_rounded,
                        color:
                            AppTheme.textSecondaryColor.withValues(alpha: 0.5),
                        size: 24,
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
                          isUnlocked || !achievement.isSecret
                              ? achievement.title
                              : '???',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color:
                                isUnlocked ? null : AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _rarityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          achievement.rarity.displayName,
                          style: TextStyle(
                            fontSize: 11,
                            color: _rarityColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUnlocked || !achievement.isSecret
                        ? achievement.description
                        : 'ปลดล็อคเพื่อดูรายละเอียด',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  if (!isUnlocked && achievement.targetValue != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.3),
                              valueColor: AlwaysStoppedAnimation(
                                  _rarityColor.withValues(alpha: 0.5)),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(progress * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            if (isUnlocked) ...[
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '+${achievement.xpReward}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
