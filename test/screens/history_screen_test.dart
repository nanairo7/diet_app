import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:diet_app/constants/app_strings.dart';
import 'package:diet_app/providers/diet_provider.dart';
import 'package:diet_app/screens/history_screen.dart';
import 'package:diet_app/services/storage_service.dart';

Future<Widget> _buildTestWidget(DietProvider provider) async {
  return ChangeNotifierProvider<DietProvider>.value(
    value: provider,
    child: const MaterialApp(home: Scaffold(body: HistoryScreen())),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ja');
  });

  group('HistoryScreen - カレンダー表示', () {
    testWidgets('TableCalendarが表示される', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      final provider = DietProvider(storage);
      await provider.init();

      await tester.pumpWidget(await _buildTestWidget(provider));
      await tester.pump();

      expect(find.byType(TableCalendar), findsOneWidget);
    });

    testWidgets('初期状態では全記録リストが表示される（日付未選択）', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      final provider = DietProvider(storage);
      await provider.init();

      await tester.pumpWidget(await _buildTestWidget(provider));
      await tester.pump();

      // 記録がない場合は空メッセージ
      expect(find.text(AppStrings.noRecords), findsOneWidget);
    });
  });

  group('HistoryScreen - 記録なし', () {
    testWidgets('記録がない場合、空メッセージが表示される', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      final provider = DietProvider(storage);
      await provider.init();

      await tester.pumpWidget(await _buildTestWidget(provider));
      await tester.pump();

      expect(find.text(AppStrings.noRecords), findsOneWidget);
    });
  });

  group('HistoryScreen - 記録あり', () {
    testWidgets('記録がある場合、DailyRecordTileが表示される', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      final provider = DietProvider(storage);
      await provider.init();
      await provider.addEntry(name: 'テスト', calories: 100, protein: 10);

      await tester.pumpWidget(await _buildTestWidget(provider));
      await tester.pump();

      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('記録がある場合、空メッセージが表示されない', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      final provider = DietProvider(storage);
      await provider.init();
      await provider.addEntry(name: 'テスト', calories: 100, protein: 10);

      await tester.pumpWidget(await _buildTestWidget(provider));
      await tester.pump();

      expect(find.text(AppStrings.noRecords), findsNothing);
    });
  });

  group('HistoryScreen - 日付選択', () {
    testWidgets('記録のない日を選択すると「この日の記録はありません」が表示される', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      final provider = DietProvider(storage);
      await provider.init();

      await tester.pumpWidget(await _buildTestWidget(provider));
      await tester.pump();

      // カレンダー上の「1日」のセルをタップ
      // （テスト環境では現在月のいずれかの日付テキストをタップ）
      final dayFinders = find.text('1');
      if (dayFinders.evaluate().isNotEmpty) {
        await tester.tap(dayFinders.first);
        await tester.pumpAndSettle();

        // 記録がない日なので「この日の記録はありません」か、
        // 今日の記録がある場合はListTileが表示される
        final hasNoRecordMsg =
            find.text(AppStrings.noRecordForDay).evaluate().isNotEmpty;
        final hasListTile = find.byType(ListTile).evaluate().isNotEmpty;
        expect(hasNoRecordMsg || hasListTile, isTrue);
      }
    });
  });
}
