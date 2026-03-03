import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_app/constants/app_strings.dart';
import 'package:diet_app/providers/diet_provider.dart';
import 'package:diet_app/screens/favorites_screen.dart';
import 'package:diet_app/services/storage_service.dart';

Future<Widget> _buildTestWidget(DietProvider provider) async {
  return ChangeNotifierProvider<DietProvider>.value(
    value: provider,
    child: const MaterialApp(home: FavoritesScreen()),
  );
}

Future<DietProvider> _makeProvider() async {
  SharedPreferences.setMockInitialValues({});
  final storage = StorageService();
  final provider = DietProvider(storage);
  await provider.init();
  return provider;
}

void main() {
  group('FavoritesScreen - 空状態', () {
    testWidgets('お気に入りが空のとき空状態メッセージが表示される', (tester) async {
      final provider = await _makeProvider();
      await tester.pumpWidget(await _buildTestWidget(provider));

      expect(find.text(AppStrings.favoritesEmpty), findsOneWidget);
    });

    testWidgets('画面タイトルが表示される', (tester) async {
      final provider = await _makeProvider();
      await tester.pumpWidget(await _buildTestWidget(provider));

      expect(find.text(AppStrings.favorites), findsOneWidget);
    });
  });

  group('FavoritesScreen - リスト表示', () {
    testWidgets('お気に入りがあるときリストが表示される', (tester) async {
      final provider = await _makeProvider();
      await provider.addFavorite(name: '鶏むね肉', calories: 150, protein: 30);
      await tester.pumpWidget(await _buildTestWidget(provider));
      await tester.pump();

      expect(find.text('鶏むね肉'), findsOneWidget);
      expect(find.text(AppStrings.favoritesEmpty), findsNothing);
    });

    testWidgets('複数のお気に入りが表示される', (tester) async {
      final provider = await _makeProvider();
      await provider.addFavorite(name: '鶏むね肉', calories: 150, protein: 30);
      await provider.addFavorite(name: 'ご飯', calories: 250, protein: 4);
      await tester.pumpWidget(await _buildTestWidget(provider));
      await tester.pump();

      expect(find.text('鶏むね肉'), findsOneWidget);
      expect(find.text('ご飯'), findsOneWidget);
    });
  });

  group('FavoritesScreen - 追加操作', () {
    testWidgets('タイルをタップするとスナックバーが表示される', (tester) async {
      final provider = await _makeProvider();
      await provider.addFavorite(name: '鶏むね肉', calories: 150, protein: 30);
      await tester.pumpWidget(await _buildTestWidget(provider));
      await tester.pump();

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(find.text('鶏むね肉 ${AppStrings.added}'), findsOneWidget);
    });

    testWidgets('タイルをタップしてもお気に入りリストは変わらない', (tester) async {
      final provider = await _makeProvider();
      await provider.addFavorite(name: '鶏むね肉', calories: 150, protein: 30);
      await tester.pumpWidget(await _buildTestWidget(provider));
      await tester.pump();

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(provider.favorites.length, 1);
    });
  });

  group('FavoritesScreen - 削除操作', () {
    testWidgets('削除ボタンをタップすると確認ダイアログが表示される', (tester) async {
      final provider = await _makeProvider();
      await provider.addFavorite(name: '鶏むね肉', calories: 150, protein: 30);
      await tester.pumpWidget(await _buildTestWidget(provider));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('削除ダイアログでキャンセルするとリストが変わらない', (tester) async {
      final provider = await _makeProvider();
      await provider.addFavorite(name: '鶏むね肉', calories: 150, protein: 30);
      await tester.pumpWidget(await _buildTestWidget(provider));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();
      await tester.tap(find.text(AppStrings.cancel));
      await tester.pump();

      expect(provider.favorites.length, 1);
    });

    testWidgets('削除ダイアログで削除するとリストから消える', (tester) async {
      final provider = await _makeProvider();
      await provider.addFavorite(name: '鶏むね肉', calories: 150, protein: 30);
      await tester.pumpWidget(await _buildTestWidget(provider));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();
      await tester.tap(find.text(AppStrings.delete));
      await tester.pump();

      expect(provider.favorites, isEmpty);
    });
  });
}
