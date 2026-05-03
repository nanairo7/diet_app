import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/daily_record.dart';
import '../models/favorite_entry.dart';
import '../models/food_entry.dart';
import '../models/notification_slot.dart';
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
  List<NotificationSlot> _notificationSlots = const [
    NotificationSlot(enabled: false, hour: 8, minute: 0),
    NotificationSlot(enabled: false, hour: 12, minute: 0),
    NotificationSlot(enabled: false, hour: 20, minute: 0),
  ];
  List<FavoriteEntry> _favorites = [];

  DietProvider(this._storage);

  DailyRecord get todayRecord => _todayRecord;
  List<String> get allDates => _allDates;
  bool get isLoading => _isLoading;
  double? get targetWeight => _targetWeight;
  double? get calorieGoal =>
      _targetWeight != null ? _targetWeight! * 34 : null;
  bool get notificationEnabled => _notificationSlots.any((s) => s.enabled);
  List<NotificationSlot> get notificationSlots => List.unmodifiable(_notificationSlots);
  List<FavoriteEntry> get favorites => List.unmodifiable(_favorites);

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> init() async {
    await _storage.init();
    _allDates = _storage.getAllRecordDates();
    _targetWeight = _storage.loadTargetWeight();
    _notificationSlots = _storage.loadNotificationSlots();
    _favorites = _storage.loadFavorites();
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

  Future<void> addEntryForDate({
    required String dateKey,
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

    if (dateKey == _todayKey()) {
      _todayRecord.entries.add(entry);
      await _storage.saveDailyRecord(_todayRecord);
    } else {
      final record = _storage.loadDailyRecord(dateKey) ??
          DailyRecord(dateKey: dateKey, entries: []);
      record.entries.add(entry);
      await _storage.saveDailyRecord(record);
    }
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

  Future<void> addFavorite({
    required String name,
    required double calories,
    required double protein,
  }) async {
    final entry = FavoriteEntry.create(
      name: name,
      calories: calories,
      protein: protein,
    );
    _favorites = [..._favorites, entry];
    await _storage.saveFavorites(_favorites);
    notifyListeners();
  }

  Future<void> removeFavorite(String id) async {
    _favorites = _favorites.where((e) => e.id != id).toList();
    await _storage.saveFavorites(_favorites);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await _storage.setFirstLaunchDone();
  }

  Future<void> saveNotificationSettings({
    required List<NotificationSlot> slots,
  }) async {
    _notificationSlots = slots;
    await _storage.saveNotificationEnabled(slots.any((s) => s.enabled));
    await _storage.saveNotificationSlots(slots);
    notifyListeners();
  }
}
