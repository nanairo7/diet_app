import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_app/constants/app_strings.dart';
import 'package:diet_app/providers/diet_provider.dart';
import 'package:diet_app/screens/onboarding_screen.dart';
import 'package:diet_app/services/storage_service.dart';

Future<Widget> _buildTestWidget() async {
  SharedPreferences.setMockInitialValues({});
  final storage = StorageService();
  final provider = DietProvider(storage);
  await provider.init();

  return ChangeNotifierProvider<DietProvider>.value(
    value: provider,
    child: const MaterialApp(home: OnboardingScreen()),
  );
}

// 画面の全要素が表示されるよう十分な縦幅を確保
void _setLargeScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('OnboardingScreen - 表示', () {
    testWidgets('アプリタイトルが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      expect(find.text(AppStrings.onboardingTitle), findsOneWidget);
    });

    testWidgets('サブタイトルが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      expect(find.text(AppStrings.onboardingSubtitle), findsOneWidget);
    });

    testWidgets('3つの機能説明が表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      expect(find.text(AppStrings.onboardingFeature1), findsOneWidget);
      expect(find.text(AppStrings.onboardingFeature2), findsOneWidget);
      expect(find.text(AppStrings.onboardingFeature3), findsOneWidget);
    });

    testWidgets('目標体重フィールドが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      expect(find.text(AppStrings.targetWeight), findsOneWidget);
    });

    testWidgets('はじめるボタンが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      expect(find.text(AppStrings.onboardingStart), findsOneWidget);
    });

    testWidgets('スキップボタンが表示される', (tester) async {
      await tester.pumpWidget(await _buildTestWidget());
      expect(find.text(AppStrings.onboardingSkip), findsOneWidget);
    });
  });

  group('OnboardingScreen - バリデーション', () {
    testWidgets('空のまま「はじめる」を押すとバリデーションエラーが表示される', (tester) async {
      _setLargeScreen(tester);
      await tester.pumpWidget(await _buildTestWidget());
      await tester.tap(find.text(AppStrings.onboardingStart));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.required), findsOneWidget);
    });

    testWidgets('無効な値で「はじめる」を押すとバリデーションエラーが表示される', (tester) async {
      _setLargeScreen(tester);
      await tester.pumpWidget(await _buildTestWidget());
      await tester.enterText(find.byType(TextFormField), '-5');
      await tester.tap(find.text(AppStrings.onboardingStart));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.invalidNumber), findsOneWidget);
    });
  });

  group('OnboardingScreen - カロリープレビュー', () {
    testWidgets('目標体重を入力するとカロリー目標がプレビュー表示される', (tester) async {
      _setLargeScreen(tester);
      await tester.pumpWidget(await _buildTestWidget());
      await tester.enterText(find.byType(TextFormField), '60');
      await tester.pump();
      // 60 × 34 = 2040
      expect(find.textContaining('2040'), findsOneWidget);
    });
  });
}
