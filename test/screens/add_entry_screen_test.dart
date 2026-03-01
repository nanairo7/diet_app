import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_app/constants/app_strings.dart';
import 'package:diet_app/providers/diet_provider.dart';
import 'package:diet_app/screens/add_entry_screen.dart';
import 'package:diet_app/services/storage_service.dart';

Future<Widget> _buildTestWidget() async {
  SharedPreferences.setMockInitialValues({});
  final storage = StorageService();
  final provider = DietProvider(storage);
  await provider.init();

  return ChangeNotifierProvider<DietProvider>.value(
    value: provider,
    child: const MaterialApp(home: AddEntryScreen()),
  );
}

void main() {
  group('AddEntryScreen - 表示', () {
    testWidgets('画面タイトルが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      expect(find.text(AppStrings.addFood), findsOneWidget);
    });

    testWidgets('食品名フィールドが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      expect(find.text(AppStrings.foodName), findsOneWidget);
    });

    testWidgets('カロリーフィールドが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      expect(find.text(AppStrings.calories), findsOneWidget);
    });

    testWidgets('タンパク質フィールドが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      expect(find.text(AppStrings.protein), findsOneWidget);
    });

    testWidgets('追加ボタンが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      expect(find.text(AppStrings.addButton), findsOneWidget);
    });
  });

  group('AddEntryScreen - バリデーション', () {
    testWidgets('空のまま送信するとエラーメッセージが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());

      await tester.tap(find.text(AppStrings.addButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.required), findsWidgets);
    });

    testWidgets('食品名が空のままだとエラーが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());

      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.calories), '100');
      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.protein), '10');
      await tester.tap(find.text(AppStrings.addButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.required), findsOneWidget);
    });

    testWidgets('カロリーに無効な文字を入力するとエラーが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());

      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.foodName), 'テスト食品');
      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.calories), 'abc');
      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.protein), '10');
      await tester.tap(find.text(AppStrings.addButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.invalidNumber), findsOneWidget);
    });

    testWidgets('カロリーに負の数を入力するとエラーが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());

      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.foodName), 'テスト食品');
      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.calories), '-100');
      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.protein), '10');
      await tester.tap(find.text(AppStrings.addButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.invalidNumber), findsOneWidget);
    });

    testWidgets('タンパク質に無効な文字を入力するとエラーが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());

      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.foodName), 'テスト食品');
      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.calories), '100');
      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.protein), 'xyz');
      await tester.tap(find.text(AppStrings.addButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.invalidNumber), findsOneWidget);
    });
  });

  group('AddEntryScreen - 正常送信', () {
    testWidgets('正しいデータを入力して送信すると追加完了スナックバーが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());

      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.foodName), '鶏むね肉');
      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.calories), '150');
      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.protein), '30');
      await tester.tap(find.text(AppStrings.addButton));
      // pumpAndSettleではなくpumpを使う（Navigator.popでスナックバーが消える前に確認）
      await tester.pump();

      expect(find.text(AppStrings.added), findsOneWidget);
    });

    testWidgets('小数値を入力して送信できる', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());

      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.foodName), 'ヨーグルト');
      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.calories), '62.5');
      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.protein), '5.5');
      await tester.tap(find.text(AppStrings.addButton));
      await tester.pump();

      expect(find.text(AppStrings.added), findsOneWidget);
    });
  });

  group('AddEntryScreen - お気に入りスイッチ', () {
    testWidgets('お気に入りに登録スイッチが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      expect(find.text(AppStrings.addToFavorites), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('スイッチのデフォルトはOFF', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      final switchWidget =
          tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(switchWidget.value, isFalse);
    });

    testWidgets('スイッチをタップするとONになる', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();
      final switchWidget =
          tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('スイッチONで送信するとお気に入り登録済みスナックバーが表示される',
        (tester) async {
      await tester.pumpWidget(await _buildTestWidget());

      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.foodName), '鶏むね肉');
      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.calories), '150');
      await tester.enterText(
          find.widgetWithText(TextFormField, AppStrings.protein), '30');
      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();
      await tester.tap(find.text(AppStrings.addButton));
      await tester.pump();

      expect(find.text('${AppStrings.added}・${AppStrings.favoriteAdded}'),
          findsOneWidget);
    });
  });
}
