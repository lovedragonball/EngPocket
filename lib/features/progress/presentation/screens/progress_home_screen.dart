/// Progress Home Screen
library;

import 'package:flutter/material.dart';
import '../../../../config/app_theme.dart';
import '../widgets/stats_card.dart';

class ProgressHomeScreen extends StatelessWidget {
  const ProgressHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Progress Pocket'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.progressColor,
                    AppTheme.progressColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '🔥 5 วันติดต่อกัน',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'เรียนต่อเนื่องเพื่อรักษา streak!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Grid
            const Text(
              'สถิติของฉัน',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: const [
                StatsCard(
                  title: 'คำศัพท์ที่จำได้',
                  value: '82',
                  subtitle: '+5 สัปดาห์นี้',
                  icon: Icons.book_rounded,
                  color: AppTheme.vocabColor,
                ),
                StatsCard(
                  title: 'วันที่เรียน',
                  value: '15',
                  icon: Icons.calendar_today_rounded,
                  color: AppTheme.primaryColor,
                ),
                StatsCard(
                  title: 'ข้อสอบที่ทำ',
                  value: '8',
                  icon: Icons.assignment_rounded,
                  color: AppTheme.examColor,
                ),
                StatsCard(
                  title: 'คะแนนเฉลี่ย',
                  value: '72%',
                  icon: Icons.trending_up_rounded,
                  color: AppTheme.successColor,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Vocab Progress
            const Text(
              'ความก้าวหน้าคำศัพท์',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildVocabProgress(),
            const SizedBox(height: 24),

            // Recent Exams
            const Text(
              'ข้อสอบล่าสุด',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecentExam('TGAT Mock Test 1', 24, 30,
                DateTime.now().subtract(const Duration(days: 1))),
            const SizedBox(height: 8),
            _buildRecentExam('A-Level Mock Test 1', 35, 50,
                DateTime.now().subtract(const Duration(days: 3))),
          ],
        ),
      ),
    );
  }

  Widget _buildVocabProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProgressRow('จำได้แล้ว', 82, 150, AppTheme.successColor),
          const SizedBox(height: 12),
          _buildProgressRow('กำลังเรียน', 23, 150, AppTheme.warningColor),
          const SizedBox(height: 12),
          _buildProgressRow(
              'ยังไม่ได้เรียน', 45, 150, AppTheme.textSecondaryColor),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, int value, int total, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              '$value คำ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / total,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentExam(String name, int score, int total, DateTime date) {
    final percentage = (score / total * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: percentage >= 60
                  ? AppTheme.successColor.withValues(alpha: 0.1)
                  : AppTheme.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$percentage%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: percentage >= 60
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$score/$total คะแนน',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(date),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'วันนี้';
    if (diff == 1) return 'เมื่อวาน';
    return '$diff วันที่แล้ว';
  }
}
