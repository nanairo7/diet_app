import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:diet_app/constants/app_strings.dart';
import 'package:diet_app/models/daily_record.dart';
import 'package:diet_app/models/food_entry.dart';
import 'package:diet_app/screens/day_detail_screen.dart';

DailyRecord _makeRecord({
  String dateKey = '2024-01-15',
  List<FoodEntry>? entries,
}) {
  return DailyRecord(
    dateKey: dateKey,
    entries: entries ?? [],
  );
}

FoodEntry _makeEntry({
  String id = 'e1',
  String name = '鶏むね肉',
  double calories = 150,
  double protein = 30,
}) {
  return FoodEntry(
    id: id,
    name: name,
    calories: calories,
    protein: protein,
    createdAt: DateTime(2024, 1, 15),
  );
}

Widget _buildTestWidget(DailyRecord record) {
  return MaterialApp(home: DayDetailScreen(record: record));
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ja');
  });

  group('DayDetailScreen - 表示', () {
    testWidgets('日付がアプリバーに表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(_makeRecord(dateKey: '2024-01-15')));

      // 日本語フォーマットで1月が含まれる
      expect(find.textContaining('1月'), findsOneWidget);
    });

    testWidgets('SummaryCardが表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(_makeRecord()));

      expect(find.textContaining(AppStrings.totalCalories), findsOneWidget);
      expect(find.textContaining(AppStrings.totalProtein), findsOneWidget);
    });

    testWidgets('エントリがある場合、FoodEntryTileが表示される', (tester) async {
      final record = _makeRecord(
        entries: [_makeEntry(name: 'サーモン')],
      );
      await tester.pumpWidget(_buildTestWidget(record));

      expect(find.text('サーモン'), findsOneWidget);
    });

    testWidgets('複数エントリがある場合、すべて表示される', (tester) async {
      final record = _makeRecord(
        entries: [
          _makeEntry(id: '1', name: '食品A'),
          _makeEntry(id: '2', name: '食品B'),
          _makeEntry(id: '3', name: '食品C'),
        ],
      );
      await tester.pumpWidget(_buildTestWidget(record));

      expect(find.text('食品A'), findsOneWidget);
      expect(find.text('食品B'), findsOneWidget);
      expect(find.text('食品C'), findsOneWidget);
    });

    testWidgets('DayDetailScreenでは削除ボタンが表示されない', (tester) async {
      final record = _makeRecord(
        entries: [_makeEntry()],
      );
      await tester.pumpWidget(_buildTestWidget(record));

      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });
  });

  group('DayDetailScreen - 集計値', () {
    testWidgets('合計カロリーが正しく表示される', (tester) async {
      final record = _makeRecord(
        entries: [
          _makeEntry(id: '1', calories: 300, protein: 10),
          _makeEntry(id: '2', calories: 200, protein: 20),
        ],
      );
      await tester.pumpWidget(_buildTestWidget(record));

      expect(find.textContaining('500'), findsOneWidget);
    });

    testWidgets('記録数が正しく表示される', (tester) async {
      final record = _makeRecord(
        entries: [
          _makeEntry(id: '1'),
          _makeEntry(id: '2'),
        ],
      );
      await tester.pumpWidget(_buildTestWidget(record));

      expect(find.textContaining('2 ${AppStrings.entryUnit}'), findsOneWidget);
    });
  });
}
