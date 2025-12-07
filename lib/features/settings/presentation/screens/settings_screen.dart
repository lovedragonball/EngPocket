/// Settings Screen - หน้าตั้งค่าแอป
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/app_theme.dart';
import '../../../../config/app_router.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/controllers/theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();

  // Settings state
  int _dailyGoal = 10;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 18, minute: 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyGoal = prefs.getInt('daily_goal') ?? 10;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      final hour = prefs.getInt('notification_hour') ?? 18;
      final minute = prefs.getInt('notification_minute') ?? 0;
      _notificationTime = TimeOfDay(hour: hour, minute: minute);
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('⚙️ ตั้งค่า')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ ตั้งค่า'),
      ),
      body: ListView(
        children: [
          // Learning Section
          _buildSectionHeader('การเรียนรู้'),
          _buildDailyGoalTile(),
          const Divider(height: 1),

          // Appearance Section
          _buildSectionHeader('หน้าตา'),
          _buildDarkModeTile(),
          const Divider(height: 1),

          // Notifications Section
          _buildSectionHeader('การแจ้งเตือน'),
          _buildNotificationTile(),
          if (_notificationsEnabled) _buildNotificationTimeTile(),
          const Divider(height: 1),

          // Sound Section
          _buildSectionHeader('เสียง'),
          _buildSoundTile(),
          const Divider(height: 1),

          // Data Section
          _buildSectionHeader('ข้อมูล'),
          _buildResetProgressTile(),
          const Divider(height: 1),

          // About Section
          _buildSectionHeader('เกี่ยวกับ'),
          _buildAboutTile(),
          _buildVersionTile(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildDailyGoalTile() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.vocabColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.flag_rounded, color: AppTheme.vocabColor),
      ),
      title: const Text('เป้าหมายรายวัน'),
      subtitle: Text('$_dailyGoal คำต่อวัน'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showDailyGoalDialog(),
    );
  }

  Widget _buildDarkModeTile() {
    final isDark = themeController.isDarkMode;
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isDark ? Icons.dark_mode : Icons.light_mode,
          color: Colors.purple,
        ),
      ),
      title: const Text('โหมดกลางคืน'),
      subtitle: Text(isDark ? 'เปิดใช้งาน' : 'ปิดใช้งาน'),
      value: isDark,
      onChanged: (value) async {
        await themeController.setDarkMode(value);
        setState(() {}); // Refresh UI
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(value ? 'เปิดโหมดกลางคืน' : 'ปิดโหมดกลางคืน'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
    );
  }

  Widget _buildNotificationTile() {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.warningColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.notifications_rounded,
            color: AppTheme.warningColor),
      ),
      title: const Text('การแจ้งเตือนรายวัน'),
      subtitle: Text(_notificationsEnabled ? 'เปิดใช้งาน' : 'ปิดใช้งาน'),
      value: _notificationsEnabled,
      onChanged: (value) async {
        setState(() => _notificationsEnabled = value);
        await _saveSetting('notifications_enabled', value);
        if (value) {
          await _notificationService.scheduleDailyReminder(
            hour: _notificationTime.hour,
            minute: _notificationTime.minute,
          );
        } else {
          await _notificationService.cancelDailyReminder();
        }
      },
    );
  }

  Widget _buildNotificationTimeTile() {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 72, right: 16),
      title: const Text('เวลาแจ้งเตือน'),
      subtitle: Text(_formatTime(_notificationTime)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _notificationTime,
        );
        if (time != null) {
          setState(() => _notificationTime = time);
          await _saveSetting('notification_hour', time.hour);
          await _saveSetting('notification_minute', time.minute);
          if (_notificationsEnabled) {
            await _notificationService.scheduleDailyReminder(
              hour: time.hour,
              minute: time.minute,
            );
          }
        }
      },
    );
  }

  Widget _buildSoundTile() {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
          color: AppTheme.successColor,
        ),
      ),
      title: const Text('เสียงเอฟเฟกต์'),
      subtitle: Text(_soundEnabled ? 'เปิดใช้งาน' : 'ปิดใช้งาน'),
      value: _soundEnabled,
      onChanged: (value) async {
        setState(() => _soundEnabled = value);
        await _saveSetting('sound_enabled', value);
      },
    );
  }

  Widget _buildResetProgressTile() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.refresh_rounded, color: AppTheme.errorColor),
      ),
      title: const Text('รีเซ็ตความก้าวหน้า'),
      subtitle: const Text('ลบข้อมูลการเรียนทั้งหมด'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showResetConfirmation(),
    );
  }

  Widget _buildAboutTile() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.info_outline_rounded,
            color: AppTheme.primaryColor),
      ),
      title: const Text('เกี่ยวกับ EngPocket'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showAboutDialog(),
    );
  }

  Widget _buildVersionTile() {
    return const ListTile(
      leading: SizedBox(width: 40),
      title: Text('เวอร์ชัน'),
      trailing: Text(
        '1.0.0',
        style: TextStyle(color: AppTheme.textSecondaryColor),
      ),
    );
  }

  void _showDailyGoalDialog() {
    int tempGoal = _dailyGoal;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('เป้าหมายรายวัน'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [5, 10, 15, 20, 30].map((goal) {
              final isSelected = tempGoal == goal;
              return ListTile(
                title: Text('$goal คำต่อวัน'),
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? AppTheme.primaryColor : null,
                ),
                onTap: () async {
                  setDialogState(() => tempGoal = goal);
                  setState(() => _dailyGoal = goal);
                  await _saveSetting('daily_goal', goal);
                  if (context.mounted) Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppTheme.errorColor),
            SizedBox(width: 8),
            Text('ยืนยันการรีเซ็ต'),
          ],
        ),
        content: const Text(
          'ข้อมูลการเรียนทั้งหมดจะถูกลบ\nรวมถึง streak และคะแนนสอบ\n\nการดำเนินการนี้ไม่สามารถย้อนกลับได้',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);

              // Reset all SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // Reset theme controller
              await themeController.setDarkMode(false);

              // Reset onboarding check so user sees onboarding again
              AppRouter.resetOnboardingCheck();

              // Reset local state
              setState(() {
                _dailyGoal = 10;
                _notificationsEnabled = true;
                _soundEnabled = true;
                _notificationTime = const TimeOfDay(hour: 18, minute: 0);
              });

              messenger.showSnackBar(
                const SnackBar(
                  content:
                      Text('รีเซ็ตข้อมูลเรียบร้อยแล้ว - เริ่มใหม่อีกครั้ง'),
                  backgroundColor: AppTheme.successColor,
                ),
              );

              // Navigate to onboarding
              if (context.mounted) {
                context.go('/onboarding');
              }
            },
            child: const Text(
              'รีเซ็ต',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'EngPocket',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'แอปเตรียมสอบภาษาอังกฤษ\nสำหรับนักเรียนไทย',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              '© ${DateTime.now().year} EngPocket Team',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute น.';
  }
}
