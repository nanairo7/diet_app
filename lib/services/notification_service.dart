import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/notification_slot.dart';

class NotificationService {
  // 朝=1, 昼=2, 晩=3
  static const List<int> _slotIds = [1, 2, 3];
  static const String _channelId = 'diet_reminder';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    final String deviceTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(deviceTimeZone));
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(iOS: iosSettings);
    await _plugin.initialize(settings);
  }

  Future<bool> requestPermission() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (ios == null) return false;
    final granted = await ios.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    return granted ?? false;
  }

  /// 有効なスロット（最大3件）をスケジュールする。
  /// まず既存の全通知をキャンセルしてから再スケジュール。
  Future<void> scheduleSlots(List<NotificationSlot> slots) async {
    await cancelAll();
    for (int i = 0; i < slots.length && i < _slotIds.length; i++) {
      if (!slots[i].enabled) continue;
      await _scheduleOne(
        id: _slotIds[i],
        hour: slots[i].hour,
        minute: slots[i].minute,
      );
    }
  }

  Future<void> cancelAll() async {
    for (final id in _slotIds) {
      await _plugin.cancel(id);
    }
  }

  Future<void> _scheduleOne({
    required int id,
    required int hour,
    required int minute,
  }) async {
    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: _channelId,
    );
    const details = NotificationDetails(iOS: iosDetails);

    await _plugin.zonedSchedule(
      id,
      '🍽 食事を記録しましょう',
      '今日の食事をカロリー記録アプリに入力してください',
      _nextInstanceOfTime(hour, minute),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
