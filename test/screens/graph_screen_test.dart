import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_app/constants/app_strings.dart';
import 'package:diet_app/providers/diet_provider.dart';
import 'package:diet_app/screens/graph_screen.dart';
import 'package:diet_app/services/storage_service.dart';

Future<Widget> _buildTestWidget({DietProvider? provider}) async {
  SharedPreferences.setMockInitialValues({});
  final storage = StorageService();
  final p = provider ?? DietProvider(storage);
  await p.init();

  return ChangeNotifierProvider<DietProvider>.value(
    value: p,
    child: const MaterialApp(home: Scaffold(body: GraphScreen())),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ja');
  });

  group('GraphScreen - 表示', () {
    testWidgets('週ボタンが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.text(AppStrings.graphWeekly), findsOneWidget);
    });

    testWidgets('月ボタンが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.text(AppStrings.graphMonthly), findsOneWidget);
    });

    testWidgets('カロリーボタンが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.text(AppStrings.graphCalories), findsOneWidget);
    });

    testWidgets('タンパク質ボタンが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.text(AppStrings.graphProtein), findsOneWidget);
    });

    testWidgets('データなしのときデータなしメッセージが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.text(AppStrings.graphNoData), findsOneWidget);
    });

    testWidgets('データなしのときバーチャートアイコンが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
    });
  });

  group('GraphScreen - 期間切り替え', () {
    testWidgets('月ボタンをタップしても画面が壊れない', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      await tester.tap(find.text(AppStrings.graphMonthly));
      await tester.pump();

      // 月次に切り替えてもデータなしメッセージが出る
      expect(find.text(AppStrings.graphNoData), findsOneWidget);
    });

    testWidgets('タンパク質ボタンをタップしても画面が壊れない', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      await tester.tap(find.text(AppStrings.graphProtein));
      await tester.pump();

      expect(find.text(AppStrings.graphNoData), findsOneWidget);
    });
  });

  group('GraphScreen - データあり', () {
    testWidgets('記録がある場合はサマリー行が表示される', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      final provider = DietProvider(storage);
      await provider.init();
      await provider.addEntry(
        name: '鶏むね肉',
        calories: 200,
        protein: 30,
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<DietProvider>.value(
          value: provider,
          child: const MaterialApp(home: Scaffold(body: GraphScreen())),
        ),
      );
      await tester.pump();

      expect(find.text(AppStrings.graphAvg), findsOneWidget);
      expect(find.text(AppStrings.graphMax), findsOneWidget);
      expect(find.text(AppStrings.graphTotal), findsOneWidget);
    });
  });
}
