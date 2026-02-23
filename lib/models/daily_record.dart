import 'food_entry.dart';

class DailyRecord {
  final String dateKey;
  final List<FoodEntry> entries;

  DailyRecord({
    required this.dateKey,
    required this.entries,
  });

  double get totalCalories =>
      entries.fold(0.0, (sum, e) => sum + e.calories);

  double get totalProtein =>
      entries.fold(0.0, (sum, e) => sum + e.protein);

  int get entryCount => entries.length;

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'entries': entries.map((e) => e.toJson()).toList(),
      };

  factory DailyRecord.fromJson(Map<String, dynamic> json) => DailyRecord(
        dateKey: json['dateKey'] as String,
        entries: (json['entries'] as List)
            .map((e) => FoodEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
