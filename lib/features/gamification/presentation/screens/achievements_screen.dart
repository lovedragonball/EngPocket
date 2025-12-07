/// Achievements Screen
library;

import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/models/achievement.dart';
import '../../../../core/services/achievement_service.dart';
import '../widgets/achievement_badge.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<({Achievement achievement, bool isUnlocked, double progress})>
      _achievements = [];
  bool _isLoading = true;

  // Stats
  int _unlockedCount = 0;
  int _totalCount = 0;

  final _categories = [
    (null, 'ทั้งหมด', Icons.grid_view_rounded),
    (AchievementCategory.vocabulary, 'คำศัพท์', Icons.book_rounded),
    (AchievementCategory.exam, 'ข้อสอบ', Icons.quiz_rounded),
    (AchievementCategory.streak, 'Streak', Icons.local_fire_department_rounded),
    (AchievementCategory.level, 'Level', Icons.trending_up_rounded),
    (AchievementCategory.reading, 'Reading', Icons.article_rounded),
    (AchievementCategory.grammar, 'Grammar', Icons.rule_rounded),
    (AchievementCategory.special, 'พิเศษ', Icons.star_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    try {
      final achievements =
          await AchievementService.instance.getAllAchievementsWithStatus();
      final stats = await AchievementService.instance.getAchievementStats();

      setState(() {
        _achievements = achievements;
        _unlockedCount = stats.unlocked;
        _totalCount = stats.total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<({Achievement achievement, bool isUnlocked, double progress})>
      _getFilteredAchievements(AchievementCategory? category) {
    if (category == null) return _achievements;
    return _achievements
        .where((a) => a.achievement.category == category)
        .toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Progress header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildProgressHeader(),
              ),
              const SizedBox(height: 12),
              // Category tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                tabs: _categories.map((cat) {
                  return Tab(
                    child: Row(
                      children: [
                        Icon(cat.$3, size: 16),
                        const SizedBox(width: 6),
                        Text(cat.$2),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _categories.map((cat) {
                return _buildAchievementList(_getFilteredAchievements(cat.$1));
              }).toList(),
            ),
    );
  }

  Widget _buildProgressHeader() {
    final progress = _totalCount > 0 ? _unlockedCount / _totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.secondaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Trophy icon
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              ),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Progress info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_unlockedCount / $_totalCount',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor:
                        Theme.of(context).dividerColor.withValues(alpha: 0.3),
                    valueColor:
                        const AlwaysStoppedAnimation(AppTheme.primaryColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).round()}% ปลดล็อคแล้ว',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementList(
      List<({Achievement achievement, bool isUnlocked, double progress})>
          achievements) {
    if (achievements.isEmpty) {
      return const Center(
        child: Text('ไม่มี achievement ในหมวดนี้'),
      );
    }

    // Sort: unlocked first, then by rarity
    final sortedAchievements = [...achievements]..sort((a, b) {
        if (a.isUnlocked != b.isUnlocked) {
          return a.isUnlocked ? -1 : 1;
        }
        return b.achievement.rarity.index.compareTo(a.achievement.rarity.index);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedAchievements.length,
      itemBuilder: (context, index) {
        final item = sortedAchievements[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AchievementListItem(
            achievement: item.achievement,
            isUnlocked: item.isUnlocked,
            progress: item.progress,
            onTap: () => _showAchievementDetail(item),
          ),
        );
      },
    );
  }

  void _showAchievementDetail(
      ({Achievement achievement, bool isUnlocked, double progress}) item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _AchievementDetailSheet(
        achievement: item.achievement,
        isUnlocked: item.isUnlocked,
        progress: item.progress,
      ),
    );
  }
}

class _AchievementDetailSheet extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final double progress;

  const _AchievementDetailSheet({
    required this.achievement,
    required this.isUnlocked,
    required this.progress,
  });

  Color get _rarityColor => Color(achievement.rarity.colorValue);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Badge
                Container(
                  width: 100,
                  height: 100,
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
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isUnlocked
                        ? Text(
                            achievement.icon,
                            style: const TextStyle(fontSize: 48),
                          )
                        : Icon(
                            achievement.isSecret
                                ? Icons.help_outline_rounded
                                : Icons.lock_outline_rounded,
                            color: AppTheme.textSecondaryColor,
                            size: 40,
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  isUnlocked || !achievement.isSecret
                      ? achievement.title
                      : '???',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  isUnlocked || !achievement.isSecret
                      ? achievement.description
                      : 'ปลดล็อคเพื่อดูรายละเอียด',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Rarity and XP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: _rarityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _rarityColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            achievement.category.emoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            achievement.rarity.displayName,
                            style: TextStyle(
                              color: _rarityColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            color: AppTheme.primaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${achievement.xpReward} XP',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Progress (if not unlocked)
                if (!isUnlocked && achievement.targetValue != null) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation(_rarityColor),
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _rarityColor,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
