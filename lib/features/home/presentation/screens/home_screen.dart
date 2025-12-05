/// Home Screen - Pocket Today
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../widgets/today_task_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                          style: TextStyle(
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        const Text(
                          '5',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.examColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Progress Overview Card
              _buildProgressCard(),
              const SizedBox(height: 24),

              // Today's Tasks
              const Row(
                children: [
                  Icon(Icons.today_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'สิ่งที่ควรทำวันนี้',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TodayTaskCard(
                icon: Icons.style_rounded,
                title: 'ท่องศัพท์ 10 คำ',
                subtitle: 'Flashcard วันนี้พร้อมแล้ว',
                color: AppTheme.vocabColor,
                onTap: () => context.go('/vocab/flashcard'),
              ),
              const SizedBox(height: 12),

              TodayTaskCard(
                icon: Icons.quiz_rounded,
                title: 'Grammar Mini Quiz',
                subtitle: 'Present Perfect - 5 ข้อ',
                color: AppTheme.grammarColor,
                onTap: () => context.go('/grammar'),
              ),
              const SizedBox(height: 12),

              TodayTaskCard(
                icon: Icons.assignment_rounded,
                title: 'ลองทำข้อสอบ',
                subtitle: 'TGAT Mock Test 1',
                color: AppTheme.examColor,
                onTap: () => context.go('/exam'),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'เข้าถึงด่วน',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      context,
                      icon: Icons.book_rounded,
                      label: 'คำศัพท์',
                      color: AppTheme.vocabColor,
                      onTap: () => context.go('/vocab'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      context,
                      icon: Icons.rule_rounded,
                      label: 'ไวยากรณ์',
                      color: AppTheme.grammarColor,
                      onTap: () => context.go('/grammar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      context,
                      icon: Icons.assignment_rounded,
                      label: 'ข้อสอบ',
                      color: AppTheme.examColor,
                      onTap: () => context.go('/exam'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      context,
                      icon: Icons.bar_chart_rounded,
                      label: 'สถิติ',
                      color: AppTheme.progressColor,
                      onTap: () => context.go('/progress'),
                    ),
                  ),
                ],
              ),
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
        gradient: LinearGradient(
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
                    const Text(
                      '60%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.6,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'เหลืออีก 2 กิจกรรม',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.emoji_events_rounded, color: Colors.white, size: 32),
                    SizedBox(height: 4),
                    Text(
                      '82',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'คำศัพท์',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
