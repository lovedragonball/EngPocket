/// Notification Service - บริการแจ้งเตือนรายวัน
library;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - can navigate to specific screen
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    return true;
  }

  /// Schedule daily study reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    String title = '📚 เวลาเรียนแล้ว!',
    String body = 'อย่าลืมท่องศัพท์วันนี้นะ มาต่อ Streak กันเถอะ! 🔥',
  }) async {
    if (!_isInitialized) await init();

    // Cancel existing reminder first
    await cancelDailyReminder();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      1, // Notification ID for daily reminder
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Study Reminder',
          channelDescription: 'Reminds you to study daily',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  /// Cancel daily reminder
  Future<void> cancelDailyReminder() async {
    await _notifications.cancel(1);
  }

  /// Show instant notification (for testing or achievements)
  Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (!_isInitialized) await init();

    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general',
          'General Notifications',
          channelDescription: 'General app notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Show streak achievement notification
  Future<void> showStreakNotification(int streakDays) async {
    String title;
    String body;

    if (streakDays == 7) {
      title = '🔥 Streak 7 วัน!';
      body = 'ยอดเยี่ยม! คุณเรียนติดต่อกัน 1 สัปดาห์แล้ว!';
    } else if (streakDays == 30) {
      title = '🏆 Streak 30 วัน!';
      body = 'เหลือเชื่อ! คุณเรียนติดต่อกัน 1 เดือนแล้ว!';
    } else if (streakDays % 10 == 0) {
      title = '🎉 Streak $streakDays วัน!';
      body = 'ทำได้ดีมาก ต่อไปนะ!';
    } else {
      return; // Don't show for other numbers
    }

    await showNotification(title: title, body: body, id: 100 + streakDays);
  }

  /// Show vocab milestone notification
  Future<void> showVocabMilestoneNotification(int vocabCount) async {
    if (vocabCount % 50 != 0) return; // Only show at milestones

    await showNotification(
      title: '📚 เรียนรู้ $vocabCount คำแล้ว!',
      body: 'คำศัพท์ของคุณเพิ่มขึ้นเรื่อยๆ ยอดเยี่ยม!',
      id: 200 + vocabCount,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
