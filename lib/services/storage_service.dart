import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_record.dart';

class StorageService {
  static const String _prefix = 'diet_';
  static const String _dateListKey = 'diet_date_list';
  static const String _targetWeightKey = 'diet_target_weight';
  static const String _firstLaunchKey = 'diet_first_launch_done';

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
}
