/// Home Screen - Pocket Today
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/app_theme.dart';
import '../widgets/today_task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Today's progress tracking
  int _completedTasks = 0;
  static const int _totalTasks = 1;
  int _learnedWords = 0;
  int _streak = 0;

  // Task completion status
  bool _vocabDone = false;
  int _dailyGoal = 10;

  @override
  void initState() {
    super.initState();
    _loadTodayProgress();
  }

  Future<void> _loadTodayProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final today =
        DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
    final savedDate = prefs.getString('lastActiveDate') ?? '';

    // Reset progress if it's a new day
    if (savedDate != today) {
      await prefs.setString('lastActiveDate', today);
      await prefs.setInt('todayCompletedTasks', 0);
      await prefs.setBool('vocabDone', false);

      // Update streak
      if (savedDate.isNotEmpty) {
        final lastDate = DateTime.tryParse(savedDate);
        final todayDate = DateTime.now();
        if (lastDate != null) {
          final diff = todayDate.difference(lastDate).inDays;
          if (diff == 1) {
            // Consecutive day - increase streak
            final currentStreak = prefs.getInt('streak') ?? 0;
            await prefs.setInt('streak', currentStreak + 1);
          } else if (diff > 1) {
            // Missed days - reset streak
            await prefs.setInt('streak', 0);
          }
        }
      }
    }

    setState(() {
      _completedTasks = prefs.getInt('todayCompletedTasks') ?? 0;
      _learnedWords = prefs.getInt('totalLearnedWords') ?? 0;
      _streak = prefs.getInt('streak') ?? 0;
      _vocabDone = prefs.getBool('vocabDone') ?? false;
      _dailyGoal = prefs.getInt('daily_goal') ?? 10;
    });
  }

  int get _progressPercent =>
      _totalTasks > 0 ? ((_completedTasks / _totalTasks) * 100).round() : 0;

  int get _remainingTasks => _totalTasks - _completedTasks;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pocket Today 📚',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Streak badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.examColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: AppTheme.examColor,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_streak',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.examColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Settings button
                  IconButton(
                    onPressed: () async {
                      await context.push('/settings');
                      _loadTodayProgress();
                    },
                    icon: const Icon(Icons.settings_rounded),
                    color: AppTheme.textSecondaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Progress Overview Card
              _buildProgressCard(),
              const SizedBox(height: 24),

              // Today's Tasks
              Row(
                children: [
                  const Icon(Icons.today_rounded, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'สิ่งที่ควรทำวันนี้',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$_completedTasks/$_totalTasks',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TodayTaskCard(
                icon: Icons.style_rounded,
                title: 'ท่องศัพท์ $_dailyGoal คำ',
                subtitle: _vocabDone
                    ? 'เสร็จแล้ววันนี้ ✓'
                    : 'Flashcard วันนี้พร้อมแล้ว',
                color: AppTheme.vocabColor,
                isDone: _vocabDone,
                onTap: () async {
                  // ไปหน้าท่องศัพท์ประจำวัน - จะนับเสร็จเมื่อท่องครบในหน้านั้น
                  final result = await context.push('/vocab/daily');
                  // โหลด progress ใหม่เมื่อกลับมา
                  if (result == true && context.mounted) {
                    await _loadTodayProgress();
                  } else if (context.mounted) {
                    await _loadTodayProgress();
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'สวัสดีตอนเช้า ☀️';
    if (hour < 17) return 'สวัสดีตอนบ่าย 🌤';
    return 'สวัสดีตอนเย็น 🌙';
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ความก้าวหน้าวันนี้',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_progressPercent%',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progressPercent / 100,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _remainingTasks > 0
                          ? 'เหลืออีก $_remainingTasks กิจกรรม'
                          : 'ทำครบแล้ววันนี้! 🎉',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/statistics'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events_rounded,
                                color: Colors.white, size: 32),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 16,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_learnedWords',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'คำศัพท์',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
