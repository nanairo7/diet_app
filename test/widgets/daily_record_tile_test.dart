import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:diet_app/constants/app_strings.dart';
import 'package:diet_app/models/daily_record.dart';
import 'package:diet_app/models/food_entry.dart';
import 'package:diet_app/widgets/daily_record_tile.dart';

DailyRecord _makeRecord({
  String dateKey = '2024-01-15',
  List<FoodEntry>? entries,
}) {
  return DailyRecord(
    dateKey: dateKey,
    entries: entries ?? [],
  );
}

FoodEntry _makeEntry(String id, String name, double cal, double prot) {
  return FoodEntry(
    id: id,
    name: name,
    calories: cal,
    protein: prot,
    createdAt: DateTime(2024, 1, 15),
  );
}

Widget _buildTestWidget(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ja');
  });

  group('DailyRecordTile - 基本表示', () {
    testWidgets('日付が表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        DailyRecordTile(record: _makeRecord(), onTap: () {}),
      ));

      // 日付フォーマット確認: 1月15日が含まれること
      expect(find.textContaining('1月'), findsOneWidget);
    });

    testWidgets('日のCircleAvatarが表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        DailyRecordTile(
          record: _makeRecord(dateKey: '2024-01-15'),
          onTap: () {},
        ),
      ));

      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('右矢印アイコンが表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        DailyRecordTile(record: _makeRecord(), onTap: () {}),
      ));

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });

  group('DailyRecordTile - 集計値の表示', () {
    testWidgets('合計カロリーが表示される', (tester) async {
      final record = _makeRecord(
        entries: [
          _makeEntry('1', 'A', 300, 10),
          _makeEntry('2', 'B', 200, 20),
        ],
      );

      await tester.pumpWidget(_buildTestWidget(
        DailyRecordTile(record: record, onTap: () {}),
      ));

      expect(find.textContaining('500'), findsOneWidget);
      expect(find.textContaining(AppStrings.kcalUnit), findsOneWidget);
    });

    testWidgets('合計タンパク質が表示される', (tester) async {
      final record = _makeRecord(
        entries: [
          _makeEntry('1', 'A', 100, 15.5),
          _makeEntry('2', 'B', 100, 10.0),
        ],
      );

      await tester.pumpWidget(_buildTestWidget(
        DailyRecordTile(record: record, onTap: () {}),
      ));

      expect(find.textContaining('25.5'), findsOneWidget);
      expect(find.textContaining(AppStrings.gramUnit), findsOneWidget);
    });

    testWidgets('記録数が表示される', (tester) async {
      final record = _makeRecord(
        entries: [
          _makeEntry('1', 'A', 100, 10),
          _makeEntry('2', 'B', 200, 20),
          _makeEntry('3', 'C', 300, 30),
        ],
      );

      await tester.pumpWidget(_buildTestWidget(
        DailyRecordTile(record: record, onTap: () {}),
      ));

      expect(find.textContaining('3${AppStrings.entryUnit}'), findsOneWidget);
    });

    testWidgets('エントリなしの場合0が表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        DailyRecordTile(record: _makeRecord(), onTap: () {}),
      ));

      expect(find.textContaining('0 ${AppStrings.kcalUnit}'), findsOneWidget);
    });
  });

  group('DailyRecordTile - タップ操作', () {
    testWidgets('タップするとonTapコールバックが呼ばれる', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(_buildTestWidget(
        DailyRecordTile(
          record: _makeRecord(),
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
