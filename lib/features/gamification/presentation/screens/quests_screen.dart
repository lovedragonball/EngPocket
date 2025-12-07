/// Quests Screen
library;

import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/models/quest.dart';
import '../../../../core/services/quest_service.dart';
import '../widgets/quest_card.dart';
import '../widgets/xp_gain_popup.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<({Quest quest, int current, bool completed, bool claimed})>
      _dailyQuests = [];
  List<({Quest quest, int current, bool completed, bool claimed})>
      _weeklyQuests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQuests();
  }

  Future<void> _loadQuests() async {
    setState(() => _isLoading = true);

    try {
      final dailyQuests = await QuestService.instance.getDailyQuestProgress();
      final weeklyQuests = await QuestService.instance.getWeeklyQuestProgress();

      setState(() {
        _dailyQuests = dailyQuests;
        _weeklyQuests = weeklyQuests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _claimReward(String questId) async {
    final xpGained = await QuestService.instance.claimQuestReward(questId);

    if (xpGained > 0 && mounted) {
      XpGainPopup.show(context, xpGained: xpGained, source: 'Quest');
      await _loadQuests();
    }
  }

  int get _dailyCompleted => _dailyQuests.where((q) => q.completed).length;
  int get _weeklyCompleted => _weeklyQuests.where((q) => q.completed).length;
  int get _dailyClaimable =>
      _dailyQuests.where((q) => q.completed && !q.claimed).length;
  int get _weeklyClaimable =>
      _weeklyQuests.where((q) => q.completed && !q.claimed).length;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ภารกิจ'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Stats header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildStatsHeader(),
              ),
              const SizedBox(height: 12),
              // Tabs
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.today_rounded, size: 18),
                        const SizedBox(width: 6),
                        const Text('รายวัน'),
                        if (_dailyClaimable > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$_dailyClaimable',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.date_range_rounded, size: 18),
                        const SizedBox(width: 6),
                        const Text('รายสัปดาห์'),
                        if (_weeklyClaimable > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$_weeklyClaimable',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildQuestList(_dailyQuests, QuestType.daily),
                _buildQuestList(_weeklyQuests, QuestType.weekly),
              ],
            ),
    );
  }

  Widget _buildStatsHeader() {
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
          // Daily progress
          Expanded(
            child: _QuestProgressStat(
              icon: Icons.today_rounded,
              label: 'รายวัน',
              completed: _dailyCompleted,
              total: _dailyQuests.length,
              color: AppTheme.primaryColor,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).dividerColor,
          ),
          // Weekly progress
          Expanded(
            child: _QuestProgressStat(
              icon: Icons.date_range_rounded,
              label: 'รายสัปดาห์',
              completed: _weeklyCompleted,
              total: _weeklyQuests.length,
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestList(
    List<({Quest quest, int current, bool completed, bool claimed})> quests,
    QuestType type,
  ) {
    if (quests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == QuestType.daily
                  ? Icons.today_rounded
                  : Icons.date_range_rounded,
              size: 64,
              color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'ไม่มีภารกิจ${type.displayName}',
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    // Calculate time until reset
    final resetInfo = type == QuestType.daily
        ? _getTimeUntilMidnight()
        : _getTimeUntilMonday();

    return Column(
      children: [
        // Reset timer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.timer_outlined,
                size: 16,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                'รีเซ็ตใน $resetInfo',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),

        // Quest list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quests.length,
            itemBuilder: (context, index) {
              final item = quests[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: QuestCard(
                  quest: item.quest,
                  currentValue: item.current,
                  isCompleted: item.completed,
                  isClaimed: item.claimed,
                  onClaimReward: item.completed && !item.claimed
                      ? () => _claimReward(item.quest.id)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getTimeUntilMidnight() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final diff = midnight.difference(now);

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    if (hours > 0) {
      return '$hours ชม. $minutes น.';
    }
    return '$minutes นาที';
  }

  String _getTimeUntilMonday() {
    final now = DateTime.now();
    // Calculate days until next Monday (1 = Mon, ..., 7 = Sun)
    // If today is Mon(1), we want 7 days. If Sun(7), we want 1 day.
    int daysUntilMonday = 7 - (now.weekday - 1);

    final nextMonday = DateTime(now.year, now.month, now.day + daysUntilMonday);
    final diff = nextMonday.difference(now);

    final days = diff.inDays;
    final hours = diff.inHours % 24;

    if (days > 0) {
      return '$days วัน $hours ชม.';
    }
    return '$hours ชม.';
  }
}

class _QuestProgressStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final int completed;
  final int total;
  final Color color;

  const _QuestProgressStat({
    required this.icon,
    required this.label,
    required this.completed,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$completed / $total',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
