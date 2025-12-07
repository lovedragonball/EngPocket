/// Statistics Home Screen - หน้าสถิติการเรียนรู้พร้อม Charts
library;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/services/study_time_service.dart';

class StatisticsHomeScreen extends StatefulWidget {
  const StatisticsHomeScreen({super.key});

  @override
  State<StatisticsHomeScreen> createState() => _StatisticsHomeScreenState();
}

class _StatisticsHomeScreenState extends State<StatisticsHomeScreen> {
  final StudyTimeService _studyTimeService = StudyTimeService();

  int _selectedPeriod = 0; // 0=Week, 1=Month, 2=All
  int _streak = 0;
  int _learnedWords = 0;
  int _studyTimeMinutes = 0;
  bool _isLoading = true;

  // Weekly data from real learning activity
  List<Map<String, dynamic>> _weeklyData = [];

  // Pie chart data
  double _vocabPercent = 33.3;
  double _grammarPercent = 33.3;
  double _examPercent = 33.3;

  // Achievement tracking
  bool _first10Words = false;
  bool _streak7Days = false;
  bool _exams5Done = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _studyTimeService.init();

      // Load basic stats
      final streak = prefs.getInt('streak') ?? 0;
      final learnedWords = prefs.getInt('totalLearnedWords') ?? 0;
      final studyMinutes = await _studyTimeService.getTotalStudyMinutes();

      // Load weekly activity
      final weeklyData = await _studyTimeService.getWeeklyActivity();

      // Load study distribution for pie chart
      final distribution = await _studyTimeService.getStudyDistribution();

      // Load exam count
      final examCount = prefs.getInt('examCount') ?? 0;

      // Calculate achievements
      final first10 = learnedWords >= 10;
      final streak7 = streak >= 7;
      final exams5 = examCount >= 5;

      if (mounted) {
        setState(() {
          _streak = streak;
          _learnedWords = learnedWords;
          _studyTimeMinutes = studyMinutes;
          _weeklyData = weeklyData;
          _vocabPercent = distribution['vocab'] ?? 33.3;
          _grammarPercent = distribution['grammar'] ?? 33.3;
          _examPercent = distribution['exam'] ?? 33.3;
          _first10Words = first10;
          _streak7Days = streak7;
          _exams5Done = exams5;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('📊 สถิติการเรียน')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 สถิติการเรียน'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Cards
              _buildOverviewSection(),
              const SizedBox(height: 24),

              // Period Selector
              _buildPeriodSelector(),
              const SizedBox(height: 16),

              // Activity Chart
              _buildActivityChart(),
              const SizedBox(height: 24),

              // Category Breakdown
              _buildCategoryBreakdown(),
              const SizedBox(height: 24),

              // Streak Calendar
              _buildStreakSection(),
              const SizedBox(height: 24),

              // Achievements
              _buildAchievementsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_fire_department_rounded,
            value: '$_streak',
            label: 'Streak วัน',
            color: AppTheme.examColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.book_rounded,
            value: '$_learnedWords',
            label: 'คำศัพท์',
            color: AppTheme.vocabColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.timer_rounded,
            value: '${(_studyTimeMinutes / 60).toStringAsFixed(1)}h',
            label: 'เวลาเรียน',
            color: AppTheme.progressColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPeriodButton('สัปดาห์', 0),
          _buildPeriodButton('เดือน', 1),
          _buildPeriodButton('ทั้งหมด', 2),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, int index) {
    final isSelected = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedPeriod = index);
          // In the future, load different data based on period
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    // Calculate max value for chart scaling
    double maxY = 10;
    for (var data in _weeklyData) {
      final total = (data['total'] as int? ?? 0).toDouble();
      if (total > maxY) maxY = total;
    }
    maxY = (maxY * 1.2).ceilToDouble(); // Add 20% padding
    if (maxY < 10) maxY = 10;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'กิจกรรมรายวัน',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _weeklyData.isEmpty
                ? const Center(child: Text('ยังไม่มีข้อมูลกิจกรรม'))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.blueGrey.shade800,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            if (groupIndex >= _weeklyData.length) return null;
                            final data = _weeklyData[groupIndex];
                            return BarTooltipItem(
                              '${data['day']}\n${rod.toY.toInt()} นาที',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < _weeklyData.length) {
                                return Text(
                                  _weeklyData[value.toInt()]['day'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                            reservedSize: 28,
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: _weeklyData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        final total = (data['total'] as int? ?? 0).toDouble();
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: total,
                              color: total > 0
                                  ? AppTheme.vocabColor
                                  : Colors.grey.shade300,
                              width: 12,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'สัดส่วนการเรียน',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: [
                      PieChartSectionData(
                        value: _vocabPercent,
                        color: AppTheme.vocabColor,
                        radius: 25,
                        title: '',
                      ),
                      PieChartSectionData(
                        value: _grammarPercent,
                        color: AppTheme.grammarColor,
                        radius: 25,
                        title: '',
                      ),
                      PieChartSectionData(
                        value: _examPercent,
                        color: AppTheme.examColor,
                        radius: 25,
                        title: '',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildLegendItem(
                        'คำศัพท์',
                        '${_vocabPercent.toStringAsFixed(0)}%',
                        AppTheme.vocabColor),
                    const SizedBox(height: 12),
                    _buildLegendItem(
                        'ไวยากรณ์',
                        '${_grammarPercent.toStringAsFixed(0)}%',
                        AppTheme.grammarColor),
                    const SizedBox(height: 12),
                    _buildLegendItem(
                        'ข้อสอบ',
                        '${_examPercent.toStringAsFixed(0)}%',
                        AppTheme.examColor),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakSection() {
    // Get current day of week for highlighting
    final today = DateTime.now().weekday; // 1=Monday, 7=Sunday

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.examColor.withValues(alpha: 0.1),
            AppTheme.examColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.examColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: AppTheme.examColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Streak 🔥',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.examColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_streak วัน',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              // index 0 = Monday, index 6 = Sunday
              // Highlight days up to current streak (working backwards from today)
              final dayIndex = index + 1; // 1-7
              final daysFromToday = today - dayIndex;
              final isActive = daysFromToday >= 0 && daysFromToday < _streak;
              final isToday = dayIndex == today;

              final days = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color:
                          isActive ? AppTheme.examColor : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: AppTheme.examColor, width: 2)
                          : null,
                    ),
                    child: Icon(
                      isActive ? Icons.check : Icons.close,
                      color: isActive ? Colors.white : Colors.grey.shade400,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isActive
                          ? AppTheme.examColor
                          : AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🏆 รางวัล',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildAchievementCard(
                icon: Icons.star_rounded,
                title: 'เริ่มต้น',
                subtitle: 'ท่อง 10 คำแรก',
                isUnlocked: _first10Words,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAchievementCard(
                icon: Icons.local_fire_department_rounded,
                title: 'ไฟแรง',
                subtitle: 'Streak 7 วัน',
                isUnlocked: _streak7Days,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAchievementCard(
                icon: Icons.emoji_events_rounded,
                title: 'นักสอบ',
                subtitle: 'ทำข้อสอบ 5 ชุด',
                isUnlocked: _exams5Done,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isUnlocked,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppTheme.warningColor.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? AppTheme.warningColor.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isUnlocked ? AppTheme.warningColor : Colors.grey.shade400,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isUnlocked ? AppTheme.textPrimaryColor : Colors.grey,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: isUnlocked
                  ? AppTheme.textSecondaryColor
                  : Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
