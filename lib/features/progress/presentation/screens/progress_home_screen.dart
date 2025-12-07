/// Progress Home Screen
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/services/srs_service.dart';
import '../widgets/stats_card.dart';

class ProgressHomeScreen extends StatefulWidget {
  const ProgressHomeScreen({super.key});

  @override
  State<ProgressHomeScreen> createState() => _ProgressHomeScreenState();
}

class _ProgressHomeScreenState extends State<ProgressHomeScreen> {
  final SrsService _srsService = SrsService();
  bool _isLoading = true;

  // Stats
  int _streak = 0;
  int _mastered = 0;
  int _learned = 0;
  int _dueToday = 0;
  int _examsTaken = 0;
  int _averageScore = 0;
  List<Map<String, dynamic>> _recentExams = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    await _srsService.init();
    final prefs = await SharedPreferences.getInstance();

    // Get SRS stats
    final stats = _srsService.getStats();

    // Get SharedPrefs data
    final streak = prefs.getInt('streak') ?? 0;

    // Get exam history from SharedPrefs
    final examHistory = <Map<String, dynamic>>[];
    final examCount = prefs.getInt('examCount') ?? 0;
    int totalScore = 0;

    for (int i = 0; i < examCount && i < 5; i++) {
      final examName = prefs.getString('exam_${i}_name');
      final examScore = prefs.getInt('exam_${i}_score') ?? 0;
      final examTotal = prefs.getInt('exam_${i}_total') ?? 1;
      final examDateStr = prefs.getString('exam_${i}_date');

      if (examName != null) {
        DateTime? examDate;
        try {
          examDate = examDateStr != null
              ? DateTime.parse(examDateStr)
              : DateTime.now();
        } catch (_) {
          examDate = DateTime.now();
        }

        examHistory.add({
          'name': examName,
          'score': examScore,
          'total': examTotal,
          'date': examDate,
        });

        totalScore += ((examScore / examTotal) * 100).round();
      }
    }

    if (mounted) {
      setState(() {
        _streak = streak;
        _mastered = stats['mastered'] ?? 0;
        _learned = stats['learned'] ?? 0;
        _dueToday = stats['dueToday'] ?? 0;
        _examsTaken = examCount;
        _averageScore = examCount > 0 ? (totalScore / examCount).round() : 0;
        _recentExams = examHistory;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('📊 Progress Pocket')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Progress Pocket'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/statistics'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'สถิติ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                    Text(
                      '🔥 $_streak วันติดต่อกัน',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _streak > 0
                          ? 'สุดยอด! เรียนต่อเนื่องเพื่อรักษา streak!'
                          : 'เริ่มเรียนวันนี้เพื่อสร้าง streak!',
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
                children: [
                  StatsCard(
                    title: 'คำศัพท์ที่จำได้',
                    value: '$_mastered',
                    subtitle: 'เรียนแล้ว $_learned คำ',
                    icon: Icons.book_rounded,
                    color: AppTheme.vocabColor,
                  ),
                  StatsCard(
                    title: 'รอทบทวน',
                    value: '$_dueToday',
                    subtitle: 'วันนี้',
                    icon: Icons.schedule_rounded,
                    color: AppTheme.warningColor,
                  ),
                  StatsCard(
                    title: 'ข้อสอบที่ทำ',
                    value: '$_examsTaken',
                    icon: Icons.assignment_rounded,
                    color: AppTheme.examColor,
                  ),
                  StatsCard(
                    title: 'คะแนนเฉลี่ย',
                    value: '$_averageScore%',
                    icon: Icons.trending_up_rounded,
                    color: _averageScore >= 60
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
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
              if (_recentExams.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ยังไม่มีประวัติการสอบ',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => context.go('/exam'),
                        child: const Text('ไปทำข้อสอบ'),
                      ),
                    ],
                  ),
                )
              else
                ..._recentExams.map((exam) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildRecentExam(
                        exam['name'] as String,
                        exam['score'] as int,
                        exam['total'] as int,
                        exam['date'] as DateTime,
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVocabProgress() {
    final total = _mastered + _learned + _dueToday;
    final displayTotal =
        total > 0 ? total : 100; // Use 100 as default for display

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
          _buildProgressRow(
              'จำได้แล้ว', _mastered, displayTotal, AppTheme.successColor),
          const SizedBox(height: 12),
          _buildProgressRow(
              'กำลังเรียน', _learned, displayTotal, AppTheme.warningColor),
          const SizedBox(height: 12),
          _buildProgressRow(
              'รอทบทวน', _dueToday, displayTotal, AppTheme.primaryColor),
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
            value: total > 0 ? value / total : 0,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentExam(String name, int score, int total, DateTime date) {
    final percentage = total > 0 ? (score / total * 100).toInt() : 0;

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
