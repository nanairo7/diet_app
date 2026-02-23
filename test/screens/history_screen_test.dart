import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_app/constants/app_strings.dart';
import 'package:diet_app/providers/diet_provider.dart';
import 'package:diet_app/screens/history_screen.dart';
import 'package:diet_app/services/storage_service.dart';

Future<Widget> _buildTestWidget(DietProvider provider) async {
  return ChangeNotifierProvider<DietProvider>.value(
    value: provider,
    child: const MaterialApp(home: Scaffold(body: HistoryScreen())),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ja');
  });

  group('HistoryScreen - 記録なし', () {
    testWidgets('記録がない場合、空メッセージが表示される', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      final provider = DietProvider(storage);
      await provider.init();

      await tester.pumpWidget(await _buildTestWidget(provider));
      await tester.pump();

      expect(find.text(AppStrings.noRecords), findsOneWidget);
    });
  });

  group('HistoryScreen - 記録あり', () {
    testWidgets('記録がある場合、DailyRecordTileが表示される', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      final provider = DietProvider(storage);
      await provider.init();
      await provider.addEntry(name: 'テスト', calories: 100, protein: 10);

      await tester.pumpWidget(await _buildTestWidget(provider));
      await tester.pump();

      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('記録がある場合、空メッセージが表示されない', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      final provider = DietProvider(storage);
      await provider.init();
      await provider.addEntry(name: 'テスト', calories: 100, protein: 10);

      await tester.pumpWidget(await _buildTestWidget(provider));
      await tester.pump();

      expect(find.text(AppStrings.noRecords), findsNothing);
    });
  });
}
