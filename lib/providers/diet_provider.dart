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

  DietProvider(this._storage);

  DailyRecord get todayRecord => _todayRecord;
  List<String> get allDates => _allDates;
  bool get isLoading => _isLoading;

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> init() async {
    await _storage.init();
    _allDates = _storage.getAllRecordDates();
    final today = _storage.loadDailyRecord(_todayKey());
    if (today != null) {
      _todayRecord = today;
    }
    _isLoading = false;
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
}
