import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_app/constants/app_strings.dart';
import 'package:diet_app/providers/diet_provider.dart';
import 'package:diet_app/screens/home_screen.dart';
import 'package:diet_app/services/storage_service.dart';

Future<Widget> _buildTestWidget() async {
  SharedPreferences.setMockInitialValues({});
  final storage = StorageService();
  final provider = DietProvider(storage);
  await provider.init();

  return ChangeNotifierProvider<DietProvider>.value(
    value: provider,
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  group('HomeScreen - 表示', () {
    testWidgets('今日タブが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.text(AppStrings.today), findsOneWidget);
    });

    testWidgets('履歴タブが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.text(AppStrings.history), findsOneWidget);
    });

    testWidgets('設定ボタンが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('初期表示で今日の記録タイトルが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.text(AppStrings.todayRecord), findsOneWidget);
    });

    testWidgets('記録がない場合、空メッセージが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.text(AppStrings.noEntries), findsOneWidget);
    });

    testWidgets('追加ボタン(FAB)が表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('HomeScreen - ナビゲーション', () {
    testWidgets('履歴タブに切り替えるとFABが消える', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      await tester.tap(find.text(AppStrings.history));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('履歴タブに切り替えるとタイトルが変わる', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      await tester.tap(find.text(AppStrings.history));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.history), findsWidgets);
    });

    testWidgets('追加ボタンをタップするとAddEntryScreenに遷移する', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.addFood), findsOneWidget);
    });

    testWidgets('設定ボタンをタップするとSettingsScreenに遷移する', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.settings), findsOneWidget);
    });
  });

  group('HomeScreen - 今日のビュー', () {
    testWidgets('SummaryCardが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.textContaining(AppStrings.totalCalories), findsOneWidget);
    });
  });
}
