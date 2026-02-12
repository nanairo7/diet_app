import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_record.dart';

class StorageService {
  static const String _prefix = 'diet_';
  static const String _dateListKey = 'diet_date_list';

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
}
