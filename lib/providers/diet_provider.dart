import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/daily_record.dart';
import '../models/food_entry.dart';
import '../services/storage_service.dart';

class DietProvider extends ChangeNotifier {
  final StorageService _storage;
  final _uuid = const Uuid();

  DailyRecord _todayRecord = DailyRecord(
    dateKey: _todayKey(),
    entries: [],
  );
  List<String> _allDates = [];
  bool _isLoading = true;
  double? _targetWeight;
  bool _notificationEnabled = false;
  int _notificationHour = 20;
  int _notificationMinute = 0;

  DietProvider(this._storage);

  DailyRecord get todayRecord => _todayRecord;
  List<String> get allDates => _allDates;
  bool get isLoading => _isLoading;
  double? get targetWeight => _targetWeight;
  double? get calorieGoal =>
      _targetWeight != null ? _targetWeight! * 34 : null;
  bool get notificationEnabled => _notificationEnabled;
  int get notificationHour => _notificationHour;
  int get notificationMinute => _notificationMinute;

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> init() async {
    await _storage.init();
    _allDates = _storage.getAllRecordDates();
    _targetWeight = _storage.loadTargetWeight();
    _notificationEnabled = _storage.loadNotificationEnabled();
    _notificationHour = _storage.loadNotificationHour();
    _notificationMinute = _storage.loadNotificationMinute();
    final today = _storage.loadDailyRecord(_todayKey());
    if (today != null) {
      _todayRecord = today;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setTargetWeight(double weight) async {
    _targetWeight = weight;
    await _storage.saveTargetWeight(weight);
    notifyListeners();
  }

  Future<void> addEntry({
    required String name,
    required double calories,
    required double protein,
  }) async {
    final entry = FoodEntry(
      id: _uuid.v4(),
      name: name,
      calories: calories,
      protein: protein,
      createdAt: DateTime.now(),
    );
    _todayRecord.entries.add(entry);
    await _storage.saveDailyRecord(_todayRecord);
    _allDates = _storage.getAllRecordDates();
    notifyListeners();
  }

  Future<void> deleteEntry(String entryId) async {
    _todayRecord.entries.removeWhere((e) => e.id == entryId);
    await _storage.saveDailyRecord(_todayRecord);
    notifyListeners();
  }

  DailyRecord? getRecordForDate(String dateKey) {
    if (dateKey == _todayKey()) return _todayRecord;
    return _storage.loadDailyRecord(dateKey);
  }

  Future<void> completeOnboarding() async {
    await _storage.setFirstLaunchDone();
  }

  Future<void> saveNotificationSettings({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    _notificationEnabled = enabled;
    _notificationHour = hour;
    _notificationMinute = minute;
    await _storage.saveNotificationSettings(
      enabled: enabled,
      hour: hour,
      minute: minute,
    );
    notifyListeners();
  }
}
