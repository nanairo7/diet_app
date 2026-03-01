import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_app/constants/app_strings.dart';
import 'package:diet_app/providers/diet_provider.dart';
import 'package:diet_app/screens/home_screen.dart';
import 'package:diet_app/services/storage_service.dart';
import 'package:diet_app/widgets/calorie_arc_gauge.dart';

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

void _setLargeScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ja');
  });

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

    testWidgets('初期表示で今日のカロリータイトルが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.text(AppStrings.todayCalories), findsOneWidget);
    });

    testWidgets('記録がない場合、空メッセージが表示される', (tester) async {
      _setLargeScreen(tester);
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.text(AppStrings.noEntries), findsOneWidget);
    });

    testWidgets('FABは表示されない', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });

  group('HomeScreen - インラインフォーム', () {
    testWidgets('食品名フィールドが表示される', (tester) async {
      _setLargeScreen(tester);
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(
          find.widgetWithText(TextFormField, AppStrings.foodName), findsOneWidget);
    });

    testWidgets('カロリーフィールドが表示される', (tester) async {
      _setLargeScreen(tester);
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.widgetWithText(TextFormField, AppStrings.calories),
          findsOneWidget);
    });

    testWidgets('タンパク質フィールドが表示される', (tester) async {
      _setLargeScreen(tester);
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.widgetWithText(TextFormField, AppStrings.protein),
          findsOneWidget);
    });

    testWidgets('追加ボタンが表示される', (tester) async {
      _setLargeScreen(tester);
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.text(AppStrings.addCalorieButton), findsOneWidget);
    });

    testWidgets('お気に入りから追加ボタンが表示される', (tester) async {
      _setLargeScreen(tester);
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.text(AppStrings.addFromFavoritesButton), findsOneWidget);
    });

    testWidgets('お気に入りアイコンボタンが表示される', (tester) async {
      _setLargeScreen(tester);
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.star_outline), findsOneWidget);
    });

    testWidgets('正しいデータを入力して追加するとフォームがクリアされる', (tester) async {
      _setLargeScreen(tester);
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.foodName), '鶏むね肉');
      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.calories), '150');
      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.protein), '30');
      await tester.tap(find.text(AppStrings.addCalorieButton));
      await tester.pump();

      // フォームがクリアされ食品名フィールドが空になっていることを確認
      final nameField = tester.widget<TextFormField>(
          find.widgetWithText(TextFormField, AppStrings.foodName));
      expect(nameField.controller?.text ?? '', isEmpty);
    });

    testWidgets('お気に入りから追加ボタンをタップするとFavoritesScreenに遷移する',
        (tester) async {
      _setLargeScreen(tester);
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      await tester.tap(find.text(AppStrings.addFromFavoritesButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.favorites), findsOneWidget);
    });
  });

  group('HomeScreen - ナビゲーション', () {
    testWidgets('履歴タブに切り替えるとタイトルが変わる', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      await tester.tap(find.text(AppStrings.history));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.history), findsWidgets);
    });

    testWidgets('設定ボタンをタップするとSettingsScreenに遷移する', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.settings), findsOneWidget);
    });
  });

  group('HomeScreen - 円弧ゲージ', () {
    testWidgets('CalorieArcGaugeが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.byType(CalorieArcGauge), findsOneWidget);
    });
  });
}
