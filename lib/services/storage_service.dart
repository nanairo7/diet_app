import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_record.dart';
import '../models/favorite_entry.dart';
import '../models/notification_slot.dart';

class StorageService {
  static const String _prefix = 'diet_';
  static const String _dateListKey = 'diet_date_list';
  static const String _targetWeightKey = 'diet_target_weight';
  static const String _firstLaunchKey = 'diet_first_launch_done';
  static const String _notificationEnabledKey = 'diet_notification_enabled';
  // 旧キー（後方互換のため読み取りのみ使用）
  static const String _notificationHourKey = 'diet_notification_hour';
  static const String _notificationMinuteKey = 'diet_notification_minute';
  // スロットキー
  static const _slotKeys = [
    ('diet_notification_morning', 8, 0),   // 朝: デフォルト08:00 OFF
    ('diet_notification_noon', 12, 0),     // 昼: デフォルト12:00 OFF
    ('diet_notification_evening', 20, 0),  // 晩: デフォルト20:00 ON
  ];
  static const String _favoritesKey = 'diet_favorites';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveDailyRecord(DailyRecord record) async {
    final key = '$_prefix${record.dateKey}';
    final json = jsonEncode(record.toJson());
    await _prefs.setString(key, json);

    final dateList = _prefs.getStringList(_dateListKey) ?? [];
    if (!dateList.contains(record.dateKey)) {
      dateList.add(record.dateKey);
      dateList.sort((a, b) => b.compareTo(a));
      await _prefs.setStringList(_dateListKey, dateList);
    }
  }

  DailyRecord? loadDailyRecord(String dateKey) {
    final key = '$_prefix$dateKey';
    final jsonStr = _prefs.getString(key);
    if (jsonStr == null) return null;
    return DailyRecord.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
  }

  List<String> getAllRecordDates() {
    return _prefs.getStringList(_dateListKey) ?? [];
  }

  Future<void> saveTargetWeight(double weight) async {
    await _prefs.setDouble(_targetWeightKey, weight);
  }

  double? loadTargetWeight() {
    return _prefs.getDouble(_targetWeightKey);
  }

  bool isFirstLaunch() {
    return !(_prefs.getBool(_firstLaunchKey) ?? false);
  }

  Future<void> setFirstLaunchDone() async {
    await _prefs.setBool(_firstLaunchKey, true);
  }

  bool loadNotificationEnabled() {
    return _prefs.getBool(_notificationEnabledKey) ?? false;
  }

  Future<void> saveNotificationEnabled(bool enabled) async {
    await _prefs.setBool(_notificationEnabledKey, enabled);
  }

  /// 3スロット（朝・昼・晩）を読み込む。
  /// 晩スロットは旧設定キーが存在すれば時刻を引き継ぐ。
  List<NotificationSlot> loadNotificationSlots() {
    final slots = <NotificationSlot>[];
    for (int i = 0; i < _slotKeys.length; i++) {
      final (prefix, defaultHour, defaultMinute) = _slotKeys[i];
      // 晩スロット（index=2）は旧設定から時刻を引き継ぐ
      final legacyHour = i == 2 ? (_prefs.getInt(_notificationHourKey) ?? defaultHour) : defaultHour;
      final legacyMinute = i == 2 ? (_prefs.getInt(_notificationMinuteKey) ?? defaultMinute) : defaultMinute;
      slots.add(NotificationSlot(
        enabled: _prefs.getBool('${prefix}_enabled') ?? false,
        hour: _prefs.getInt('${prefix}_hour') ?? legacyHour,
        minute: _prefs.getInt('${prefix}_minute') ?? legacyMinute,
      ));
    }
    return slots;
  }

  Future<void> saveNotificationSlots(List<NotificationSlot> slots) async {
    for (int i = 0; i < slots.length && i < _slotKeys.length; i++) {
      final (prefix, _, __) = _slotKeys[i];
      await _prefs.setBool('${prefix}_enabled', slots[i].enabled);
      await _prefs.setInt('${prefix}_hour', slots[i].hour);
      await _prefs.setInt('${prefix}_minute', slots[i].minute);
    }
  }

  Future<void> saveFavorites(List<FavoriteEntry> favorites) async {
    final jsonList = favorites.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(_favoritesKey, jsonList);
  }

  List<FavoriteEntry> loadFavorites() {
    final jsonList = _prefs.getStringList(_favoritesKey) ?? [];
    return jsonList
        .map((s) => FavoriteEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }
}
