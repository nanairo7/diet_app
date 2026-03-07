import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_app/constants/app_strings.dart';
import 'package:diet_app/providers/diet_provider.dart';
import 'package:diet_app/screens/settings_screen.dart';
import 'package:diet_app/services/storage_service.dart';

Future<Widget> _buildTestWidget({double? initialWeight}) async {
  final values = <String, Object>{};
  if (initialWeight != null) {
    values['diet_target_weight'] = initialWeight;
  }
  SharedPreferences.setMockInitialValues(values);
  final storage = StorageService();
  final provider = DietProvider(storage);
  await provider.init();

  return ChangeNotifierProvider<DietProvider>.value(
    value: provider,
    child: const MaterialApp(home: SettingsScreen()),
  );
}

void main() {
  group('SettingsScreen - 表示', () {
    testWidgets('画面タイトルが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      expect(find.text(AppStrings.settings), findsOneWidget);
    });

    testWidgets('目標体重フィールドが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      expect(find.text(AppStrings.targetWeight), findsOneWidget);
    });

    testWidgets('保存ボタンが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      expect(find.text(AppStrings.save), findsOneWidget);
    });

    testWidgets('初期状態では摂取基準が未設定と表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      expect(find.text(AppStrings.notSet), findsOneWidget);
    });

    testWidgets('既存の目標体重が入力フィールドに表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget(initialWeight: 65.0));
      expect(find.widgetWithText(TextFormField, '65.0'), findsOneWidget);
    });
  });

  group('SettingsScreen - カロリー目標プレビュー', () {
    testWidgets('体重を入力するとカロリー目標がリアルタイムで更新される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());

      await tester.enterText(
          find.byType(TextFormField), '70');
      await tester.pump();

      // 70 × 34 = 2380
      expect(find.textContaining('2380'), findsOneWidget);
    });

    testWidgets('無効な値を入力するとカロリー目標が表示されない', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());

      await tester.enterText(find.byType(TextFormField), 'abc');
      await tester.pump();

      expect(find.text(AppStrings.notSet), findsOneWidget);
    });

    testWidgets('0を入力するとカロリー目標が表示されない', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());

      await tester.enterText(find.byType(TextFormField), '0');
      await tester.pump();

      expect(find.text(AppStrings.notSet), findsOneWidget);
    });
  });

  group('SettingsScreen - バリデーション', () {
    testWidgets('空のまま保存するとエラーが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());

      await tester.tap(find.text(AppStrings.save));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.required), findsOneWidget);
    });

    testWidgets('無効な値で保存するとエラーが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());

      await tester.enterText(find.byType(TextFormField), '-10');
      await tester.tap(find.text(AppStrings.save));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.invalidNumber), findsOneWidget);
    });
  });

  group('SettingsScreen - 通知スロット', () {
    testWidgets('通知ONで朝・昼・晩のラベルが表示される', (tester) async {
      final values = <String, Object>{
        'diet_notification_enabled': true,
      };
      SharedPreferences.setMockInitialValues(values);
      final storage = StorageService();
      final provider = DietProvider(storage);
      await provider.init();
      await tester.pumpWidget(ChangeNotifierProvider<DietProvider>.value(
        value: provider,
        child: const MaterialApp(home: SettingsScreen()),
      ));
      await tester.pump();

      expect(find.text(AppStrings.notificationMorning), findsOneWidget);
      expect(find.text(AppStrings.notificationNoon), findsOneWidget);
      expect(find.text(AppStrings.notificationEvening), findsOneWidget);
    });

    testWidgets('通知OFFでは朝・昼・晩のラベルが表示されない', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      await tester.pump();

      expect(find.text(AppStrings.notificationMorning), findsNothing);
      expect(find.text(AppStrings.notificationNoon), findsNothing);
      expect(find.text(AppStrings.notificationEvening), findsNothing);
    });
  });

  group('SettingsScreen - 保存', () {
    testWidgets('正しい値を入力して保存すると保存完了スナックバーが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());

      await tester.enterText(find.byType(TextFormField), '70');
      await tester.tap(find.text(AppStrings.save));
      // Navigator.popで遷移する前にスナックバーを確認
      await tester.pump();

      expect(find.text(AppStrings.saved), findsOneWidget);
    });
  });
}
