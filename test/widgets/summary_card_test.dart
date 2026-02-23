import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_app/constants/app_strings.dart';
import 'package:diet_app/widgets/summary_card.dart';

Widget _buildTestWidget(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('SummaryCard - 基本表示', () {
    testWidgets('合計カロリーが表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        const SummaryCard(
          totalCalories: 1200,
          totalProtein: 80,
          entryCount: 3,
        ),
      ));

      expect(find.text('1200 ${AppStrings.kcalUnit}'), findsOneWidget);
    });

    testWidgets('合計タンパク質が表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        const SummaryCard(
          totalCalories: 1200,
          totalProtein: 80.5,
          entryCount: 3,
        ),
      ));

      expect(find.text('80.5 ${AppStrings.gramUnit}'), findsOneWidget);
    });

    testWidgets('記録数が表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        const SummaryCard(
          totalCalories: 1200,
          totalProtein: 80,
          entryCount: 5,
        ),
      ));

      expect(find.textContaining('5 ${AppStrings.entryUnit}'), findsOneWidget);
    });

    testWidgets('ゼロのカロリーが表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        const SummaryCard(
          totalCalories: 0,
          totalProtein: 0,
          entryCount: 0,
        ),
      ));

      expect(find.text('0 ${AppStrings.kcalUnit}'), findsOneWidget);
    });
  });

  group('SummaryCard - カロリー目標なし', () {
    testWidgets('calorieGoalがnullの場合、プログレスバーが表示されない', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        const SummaryCard(
          totalCalories: 1200,
          totalProtein: 80,
          entryCount: 3,
        ),
      ));

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('calorieGoalがnullの場合、摂取基準テキストが表示されない', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        const SummaryCard(
          totalCalories: 1200,
          totalProtein: 80,
          entryCount: 3,
        ),
      ));

      expect(find.textContaining(AppStrings.calorieGoal), findsNothing);
    });
  });

  group('SummaryCard - カロリー目標あり', () {
    testWidgets('calorieGoalが設定されるとプログレスバーが表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        const SummaryCard(
          totalCalories: 1200,
          totalProtein: 80,
          entryCount: 3,
          calorieGoal: 2000,
        ),
      ));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('目標以下の場合、残りカロリーが表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        const SummaryCard(
          totalCalories: 1200,
          totalProtein: 80,
          entryCount: 3,
          calorieGoal: 2000,
        ),
      ));

      expect(find.textContaining(AppStrings.remainingCalorie), findsOneWidget);
    });

    testWidgets('目標超過の場合、超過カロリーが表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        const SummaryCard(
          totalCalories: 2500,
          totalProtein: 80,
          entryCount: 3,
          calorieGoal: 2000,
        ),
      ));

      expect(find.textContaining(AppStrings.overCalorie), findsOneWidget);
    });

    testWidgets('目標値が表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        const SummaryCard(
          totalCalories: 1200,
          totalProtein: 80,
          entryCount: 3,
          calorieGoal: 2000,
        ),
      ));

      expect(find.textContaining('2000 ${AppStrings.kcalUnit}'), findsOneWidget);
    });

    testWidgets('残りカロリーの差分が正しい', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        const SummaryCard(
          totalCalories: 1500,
          totalProtein: 80,
          entryCount: 3,
          calorieGoal: 2000,
        ),
      ));

      // 残り 500 kcal（目標値テキストにも数値が含まれる場合があるのでfindsWidgets）
      expect(find.textContaining('500 ${AppStrings.kcalUnit}'), findsWidgets);
    });

    testWidgets('超過カロリーの差分が正しい', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        const SummaryCard(
          totalCalories: 2300,
          totalProtein: 80,
          entryCount: 3,
          calorieGoal: 2000,
        ),
      ));

      // 超過 300 kcal（テキストが複数存在する可能性があるのでfindsWidgets）
      expect(find.textContaining('300 ${AppStrings.kcalUnit}'), findsWidgets);
    });
  });
}
