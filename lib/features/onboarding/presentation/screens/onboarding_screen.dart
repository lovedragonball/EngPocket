/// Onboarding Screen - หน้า welcome สำหรับ user ใหม่
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/services/user_preferences_service.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({super.key, this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // User preferences
  int _dailyGoal = 10;
  String _examType = 'tgat';

  final List<OnboardingPage> _pages = const [
    OnboardingPage(
      icon: Icons.school_rounded,
      title: 'ยินดีต้อนรับสู่\nEngPocket! 📚',
      subtitle: 'เตรียมสอบ TGAT & A-Level\nด้วยวิธีที่สนุกและมีประสิทธิภาพ',
      color: AppTheme.primaryColor,
    ),
    OnboardingPage(
      icon: Icons.style_rounded,
      title: 'ท่องศัพท์ด้วย\nFlashcards 🎴',
      subtitle:
          'เรียนรู้คำศัพท์ใหม่ทุกวัน\nด้วยระบบการเรียนรู้แบบ Spaced Repetition',
      color: AppTheme.vocabColor,
    ),
    OnboardingPage(
      icon: Icons.quiz_rounded,
      title: 'ทดสอบความรู้\nด้วย Quiz 📝',
      subtitle: 'ฝึกทำข้อสอบจริง\nพร้อมคำอธิบายละเอียด',
      color: AppTheme.examColor,
    ),
    OnboardingPage(
      icon: Icons.trending_up_rounded,
      title: 'ติดตาม\nความก้าวหน้า 📊',
      subtitle: 'ดูสถิติการเรียน\nและ streak ของคุณ',
      color: AppTheme.progressColor,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showGoalSetting();
    }
  }

  void _showGoalSetting() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'ตั้งเป้าหมายการเรียน 🎯',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'เลือกจำนวนคำศัพท์ที่จะท่องต่อวัน',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: 24),

              // Daily Goal Options
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [5, 10, 15, 20].map((goal) {
                  final isSelected = _dailyGoal == goal;
                  return GestureDetector(
                    onTap: () => setModalState(() => _dailyGoal = goal),
                    child: Container(
                      width: 80,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor.withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$goal',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.textPrimaryColor,
                            ),
                          ),
                          Text(
                            'คำ/วัน',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Exam Type
              const Text(
                'คุณเตรียมสอบอะไร?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildExamTypeCard(
                      'TGAT',
                      'tgat',
                      Icons.assignment_rounded,
                      setModalState,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildExamTypeCard(
                      'A-Level',
                      'alevel',
                      Icons.school_rounded,
                      setModalState,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildExamTypeCard(
                      'ทั้งสอง',
                      'both',
                      Icons.auto_awesome_rounded,
                      setModalState,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'หรือ',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 24),

              // Beginner Option
              const Text(
                'สำหรับผู้เริ่มต้น',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildBeginnerCard(setModalState),
              const SizedBox(height: 32),

              // Start Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _completeOnboarding(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'เริ่มเรียนเลย! 🚀',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamTypeCard(
    String label,
    String value,
    IconData icon,
    StateSetter setModalState,
  ) {
    final isSelected = _examType == value;
    return GestureDetector(
      onTap: () => setModalState(() => _examType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.examColor.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.examColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  isSelected ? AppTheme.examColor : AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppTheme.examColor
                    : AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeginnerCard(StateSetter setModalState) {
    final isSelected = _examType == 'beginner';
    return GestureDetector(
      onTap: () => setModalState(() => _examType = 'beginner'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.successColor.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.successColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.successColor.withValues(alpha: 0.2)
                    : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.spa_rounded,
                color:
                    isSelected ? AppTheme.successColor : Colors.grey.shade400,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'กำลังเริ่มต้นฝึกภาษาอังกฤษ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppTheme.successColor
                          : AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'เน้นปูพื้นฐาน คำศัพท์ในชีวิตประจำวัน และไวยากรณ์เบื้องต้น',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? AppTheme.successColor.withValues(alpha: 0.8)
                          : AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.successColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _completeOnboarding() async {
    // Save preferences to local storage
    final prefs = UserPreferencesService();
    await prefs.init();
    await prefs.setHasSeenOnboarding(true);
    await prefs.setDailyGoal(_dailyGoal);
    await prefs.setExamType(_examType);

    // Notify router that onboarding is complete
    widget.onComplete?.call();

    // Navigate to home
    if (mounted) {
      Navigator.pop(context); // Close modal
      context.go('/'); // Go to home
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            const SizedBox(height: 16),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(page);
                },
              ),
            ),

            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? _pages[_currentPage].color
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // Next button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pages[_currentPage].color,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1
                        ? 'ถัดไป'
                        : 'เริ่มต้นใช้งาน',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 64,
              color: page.color,
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            page.subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
