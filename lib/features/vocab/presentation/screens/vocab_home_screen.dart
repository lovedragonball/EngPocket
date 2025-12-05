/// Vocab Home Screen - หน้ารวม Vocab Pocket
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';

class VocabHomeScreen extends StatelessWidget {
  const VocabHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Vocab Pocket'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Stats Card
              _buildStatsCard(),
              const SizedBox(height: 24),

              // Menu Options
              const Text(
                'เลือกโหมดเรียนรู้',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Flashcard Mode
              _buildMenuCard(
                context,
                icon: Icons.style_rounded,
                title: 'Flashcard',
                subtitle: 'ท่องศัพท์แบบการ์ด พลิกดูความหมาย',
                color: AppTheme.vocabColor,
                onTap: () => context.push('/vocab/flashcard'),
              ),
              const SizedBox(height: 12),

              // Quiz Mode
              _buildMenuCard(
                context,
                icon: Icons.quiz_rounded,
                title: 'Vocab Quiz',
                subtitle: 'ทดสอบคำศัพท์แบบเลือกตอบ',
                color: AppTheme.accentColor,
                onTap: () {
                  // Navigate to flashcard as quiz mode (same learning experience)
                  context.push('/vocab/flashcard');
                },
              ),
              const SizedBox(height: 12),

              // Browse All
              _buildMenuCard(
                context,
                icon: Icons.list_rounded,
                title: 'ดูคำศัพท์ทั้งหมด',
                subtitle: 'เรียกดูคำศัพท์แบบรายการ',
                color: AppTheme.textSecondaryColor,
                onTap: () {
                  // Navigate to flashcard to browse vocab
                  context.push('/vocab/flashcard');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.vocabColor,
            AppTheme.vocabColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.vocabColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'สถิติคำศัพท์ของฉัน',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('ใหม่', '45', Icons.fiber_new_rounded),
              _buildStatItem('กำลังเรียน', '23', Icons.school_rounded),
              _buildStatItem('จำได้แล้ว', '82', Icons.check_circle_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
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
