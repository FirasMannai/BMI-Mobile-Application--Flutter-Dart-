// Importing necessary packages
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

// Notification service
// This class handles notifications and reminders
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Initialize notification service
  Future<void> init() async {
    if (_isInitialized) {
      debugPrint('NotificationService already initialized');
      return;
    }

    // Initialize time zones
    try {
      tz.initializeTimeZones();
      final String currentTimeZone = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    } catch (e) {
      debugPrint('Error initializing time zones: $e');
    }

    // Set up Android notification settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    try {
      bool? initialized = await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification tapped: ${details.payload}');
        },
      );
      if (initialized == true) {
        _isInitialized = true;
        debugPrint('Notification plugin initialized successfully');
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'bmi_channel',
      'BMI Notifications',
      description: 'Notifications for BMI reminders',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
      enableLights: true,
    );

    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      debugPrint('Notification channel created: bmi_channel');
    } catch (e) {
      debugPrint('Error creating notification channel: $e');
    }
  }

  // Schedule a daily reminder
  Future<void> scheduleDailyReminderAt({
    required int hour,
    required int minute,
  }) async {
    if (!_isInitialized) {
      debugPrint('Cannot schedule notification: Plugin not initialized');
      return;
    }

    // Request exact alarm permission
    final exactAlarmPermission = await Permission.scheduleExactAlarm.request();
    debugPrint(
        'Exact alarm permission granted: ${exactAlarmPermission.isGranted}');

    // Construct scheduled time
    final now = DateTime.now();
    var selectedTime = DateTime(now.year, now.month, now.day, hour, minute);
    if (selectedTime.isBefore(now)) {
      selectedTime = selectedTime.add(const Duration(days: 1));
    }
    final tz.TZDateTime scheduledTime =
        tz.TZDateTime.from(selectedTime, tz.local);

    try {
      await _notificationsPlugin.zonedSchedule(
        0,
        'BMI Check Reminder',
        'Time to check your BMI and stay healthy!',
        scheduledTime,
        _notificationDetails(),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Daily notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  // Send a test notification
  Future<void> sendTestNotification() async {
    if (!_isInitialized) {
      debugPrint('Cannot send test notification: Plugin not initialized');
      return;
    }

    try {
      await _notificationsPlugin.show(
        1,
        'Test BMI Reminder',
        'This is a test notification from BMI Calculator!',
        _notificationDetails(),
      );
      debugPrint('Test notification sent immediately');
    } catch (e) {
      debugPrint('Error sending test notification: $e');
    }
  }

  // Cancel daily reminder
  Future<void> cancelReminder() async {
    try {
      await _notificationsPlugin.cancel(0);
      debugPrint('Daily notification cancelled');
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  // Define notification details
  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'bmi_channel',
        'BMI Notifications',
        channelDescription: 'Notifications for BMI reminders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        showWhen: true,
      ),
    );
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    try {
      final granted = await androidPlugin?.requestNotificationsPermission();
      debugPrint('Notification permission granted: $granted');
      final exactAlarmStatus = await Permission.scheduleExactAlarm.request();
      debugPrint(
          'Exact alarm permission granted: ${exactAlarmStatus.isGranted}');
      final batteryStatus =
          await Permission.ignoreBatteryOptimizations.request();
      debugPrint(
          'Battery optimization exemption granted: ${batteryStatus.isGranted}');
      return granted ?? false;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }
}
