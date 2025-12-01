import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notification service
  static Future<void> initialize() async {
    print('🔔 Initializing notification service for Android...');
    
    // Initialize timezone
    tz.initializeTimeZones();
    // Set timezone lokal ke Asia/Jakarta (WIB)
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); 
    
    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Combined initialization settings (hanya Android)
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    // Initialize plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification tapped: ${response.payload}');
      },
    );

    // Request permissions
    await _requestPermissions();
    
    print('✅ Notification service initialized');
  }

  // Request notification permissions
  static Future<void> _requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      // 1. Meminta izin notifikasi standar (Android 13+)
      await androidPlugin.requestNotificationsPermission();
      print('✅ Android notification permission requested');

      // 2. Meminta izin notifikasi TEPAT WAKTU (Android 12+)
      await androidPlugin.requestExactAlarmsPermission();
      print('✅ Android exact alarm permission requested');
    }
  }

  // Schedule Angelus notifications (6 AM, 12 PM, 6 PM)
  static Future<void> scheduleAngelusNotifications() async {
    print('🔔 Scheduling Angelus notifications...');

    await cancelAngelusNotifications();

    // Menggunakan waktu standar Waktu Indonesia Barat (WIB)
    await _scheduleDailyNotification(
      id: 1,
      hour: 6,
      minute: 0, 
      title: '🙏 Angelus Pagi',
      body: 'Waktunya berdoa Angelus (06:00 WIB)',
    );

    await _scheduleDailyNotification(
      id: 2,
      hour: 16,
      minute: 05,
      title: '🙏 Angelus Siang',
      body: 'Waktunya berdoa Angelus (12:00 WIB)',
    );

    await _scheduleDailyNotification(
      id: 3,
      hour: 18,
      minute: 00,
      title: '🙏 Angelus Sore',
      body: 'Waktunya berdoa Angelus (18:00 WIB)',
    );

    print('✅ Angelus notifications scheduled!');
  }

  // Schedule daily notification at specific time
  static Future<void> _scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'angelus_channel',
          'Angelus Notifications',
          channelDescription: 'Daily Angelus prayer reminders',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, 
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print('✅ Scheduled #$id for $hour:${minute.toString().padLeft(2, '0')}');
  }

  // Calculate next instance of time
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    // Dipastikan menggunakan tz.local yang sudah disetel ke Asia/Jakarta
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local); 
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Jika waktu yang dijadwalkan sudah lewat hari ini, jadwalkan untuk besok
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print('📅 Next notification: $scheduledDate');
    return scheduledDate;
  }

  // Cancel Angelus notifications
  static Future<void> cancelAngelusNotifications() async {
    await _notifications.cancel(1);
    await _notifications.cancel(2);
    await _notifications.cancel(3);
    print('❌ Angelus notifications canceled');
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('❌ All notifications canceled');
  }

  // Check pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    final pending = await _notifications.pendingNotificationRequests();
    print('📋 Pending: ${pending.length}');
    for (var n in pending) {
      print('- ID: ${n.id}, Title: ${n.title}, Payload: ${n.payload}, Body: ${n.body}');
    }
    return pending;
  }
}