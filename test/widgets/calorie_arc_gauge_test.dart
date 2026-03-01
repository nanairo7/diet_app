import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:diet_app/widgets/calorie_arc_gauge.dart';

Widget _buildTestWidget(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ja');
  });

  final testDate = DateTime(2026, 3, 2);

  group('CalorieArcGauge - 基本表示', () {
    testWidgets('現在のカロリーが表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        CalorieArcGauge(
          currentCalories: 500,
          date: testDate,
        ),
      ));
      expect(find.textContaining('500'), findsOneWidget);
      expect(find.textContaining('kcal'), findsWidgets);
    });

    testWidgets('日付が表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        CalorieArcGauge(
          currentCalories: 0,
          date: testDate,
        ),
      ));
      expect(find.textContaining('2026'), findsOneWidget);
    });

    testWidgets('目標カロリーが設定されている場合、目標カロリーが表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        CalorieArcGauge(
          currentCalories: 500,
          goalCalories: 2000,
          date: testDate,
        ),
      ));
      expect(find.textContaining('2000'), findsOneWidget);
    });

    testWidgets('目標カロリーが未設定の場合、未設定テキストが表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        CalorieArcGauge(
          currentCalories: 0,
          date: testDate,
        ),
      ));
      expect(find.text('未設定'), findsOneWidget);
    });

    testWidgets('CalorieArcGaugeが表示される', (tester) async {
      await tester.pumpWidget(_buildTestWidget(
        CalorieArcGauge(
          currentCalories: 1000,
          goalCalories: 2000,
          date: testDate,
        ),
      ));
      expect(find.byType(CalorieArcGauge), findsOneWidget);
    });
  });
}
