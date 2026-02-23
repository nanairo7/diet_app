import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_app/constants/app_strings.dart';
import 'package:diet_app/models/food_entry.dart';
import 'package:diet_app/widgets/food_entry_tile.dart';

FoodEntry _makeEntry({
  String id = 'test-id',
  String name = '鶏むね肉',
  double calories = 150,
  double protein = 30,
}) {
  return FoodEntry(
    id: id,
    name: name,
    calories: calories,
    protein: protein,
    createdAt: DateTime(2024, 1, 15, 12, 0),
  );
}

Widget _buildTestWidget(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('FoodEntryTile - 基本表示', () {
    testWidgets('食品名が表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        FoodEntryTile(entry: _makeEntry(name: 'サーモン')),
      ));

      expect(find.text('サーモン'), findsOneWidget);
    });

    testWidgets('カロリーが表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        FoodEntryTile(entry: _makeEntry(calories: 200)),
      ));

      expect(find.textContaining('200'), findsOneWidget);
      expect(find.textContaining(AppStrings.kcalUnit), findsOneWidget);
    });

    testWidgets('タンパク質が表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        FoodEntryTile(entry: _makeEntry(protein: 25.5)),
      ));

      expect(find.textContaining('25.5'), findsOneWidget);
      expect(find.textContaining(AppStrings.gramUnit), findsOneWidget);
    });

    testWidgets('レストランアイコンが表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        FoodEntryTile(entry: _makeEntry()),
      ));

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
    });
  });

  group('FoodEntryTile - 削除ボタン', () {
    testWidgets('onDeleteがnullの場合、削除ボタンが表示されない', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        FoodEntryTile(entry: _makeEntry()),
      ));

      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('onDeleteが設定されると削除ボタンが表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        FoodEntryTile(entry: _makeEntry(), onDelete: () {}),
      ));

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('削除ボタンをタップすると確認ダイアログが表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        FoodEntryTile(entry: _makeEntry(), onDelete: () {}),
      ));

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.deleteConfirm), findsOneWidget);
    });

    testWidgets('確認ダイアログにキャンセルボタンがある', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        FoodEntryTile(entry: _makeEntry(), onDelete: () {}),
      ));

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.cancel), findsOneWidget);
    });

    testWidgets('確認ダイアログに削除ボタンがある', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        FoodEntryTile(entry: _makeEntry(), onDelete: () {}),
      ));

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.delete), findsOneWidget);
    });

    testWidgets('キャンセルをタップするとダイアログが閉じる', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        FoodEntryTile(entry: _makeEntry(), onDelete: () {}),
      ));

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.deleteConfirm), findsNothing);
    });

    testWidgets('削除ボタンをタップするとonDeleteコールバックが呼ばれる', (tester) async {
      bool deleted = false;

      await tester.pumpWidget(_buildTestWidget(
        FoodEntryTile(
          entry: _makeEntry(),
          onDelete: () => deleted = true,
        ),
      ));

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.delete));
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
    });

    testWidgets('キャンセルをタップしてもonDeleteは呼ばれない', (tester) async {
      bool deleted = false;

      await tester.pumpWidget(_buildTestWidget(
        FoodEntryTile(
          entry: _makeEntry(),
          onDelete: () => deleted = true,
        ),
      ));

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();

      expect(deleted, isFalse);
    });
  });
}
