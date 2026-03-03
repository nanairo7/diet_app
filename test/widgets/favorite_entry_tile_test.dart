import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_app/constants/app_strings.dart';
import 'package:diet_app/models/favorite_entry.dart';
import 'package:diet_app/widgets/favorite_entry_tile.dart';

FavoriteEntry _makeEntry({
  String id = 'fav-id',
  String name = '鶏むね肉',
  double calories = 150,
  double protein = 30,
}) {
  return FavoriteEntry(id: id, name: name, calories: calories, protein: protein);
}

Widget _buildTestWidget(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('FavoriteEntryTile - 基本表示', () {
    testWidgets('食品名が表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        FavoriteEntryTile(
          entry: _makeEntry(),
          onAdd: () {},
          onDelete: () {},
        ),
      ));
      expect(find.text('鶏むね肉'), findsOneWidget);
    });

    testWidgets('カロリーが表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        FavoriteEntryTile(
          entry: _makeEntry(),
          onAdd: () {},
          onDelete: () {},
        ),
      ));
      expect(find.textContaining('150'), findsOneWidget);
      expect(find.textContaining(AppStrings.kcalUnit), findsOneWidget);
    });

    testWidgets('タンパク質が表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        FavoriteEntryTile(
          entry: _makeEntry(),
          onAdd: () {},
          onDelete: () {},
        ),
      ));
      expect(find.textContaining('30.0'), findsOneWidget);
      expect(find.textContaining(AppStrings.gramUnit), findsOneWidget);
    });

    testWidgets('タイルがタップ可能（onTapが設定されている）', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        FavoriteEntryTile(
          entry: _makeEntry(),
          onAdd: () {},
          onDelete: () {},
        ),
      ));
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('削除アイコンボタンが表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        FavoriteEntryTile(
          entry: _makeEntry(),
          onAdd: () {},
          onDelete: () {},
        ),
      ));
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });
  });

  group('FavoriteEntryTile - コールバック', () {
    testWidgets('タイルタップでonAddが呼ばれる', (tester) async {
      bool addCalled = false;
      await tester.pumpWidget(_buildTestWidget(
        FavoriteEntryTile(
          entry: _makeEntry(),
          onAdd: () => addCalled = true,
          onDelete: () {},
        ),
      ));
      await tester.tap(find.byType(ListTile));
      await tester.pump();
      expect(addCalled, isTrue);
    });

    testWidgets('削除ボタンタップでonDeleteが呼ばれる', (tester) async {
      bool deleteCalled = false;
      await tester.pumpWidget(_buildTestWidget(
        FavoriteEntryTile(
          entry: _makeEntry(),
          onAdd: () {},
          onDelete: () => deleteCalled = true,
        ),
      ));
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();
      expect(deleteCalled, isTrue);
    });
  });
}
