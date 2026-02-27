import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_app/main.dart';
import 'package:diet_app/providers/diet_provider.dart';
import 'package:diet_app/services/storage_service.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    final provider = DietProvider(storage);
    await provider.init();

    await tester.pumpWidget(
      ChangeNotifierProvider<DietProvider>.value(
        value: provider,
        child: const DietApp(isFirstLaunch: false),
      ),
    );
    await tester.pump();

    expect(find.text('今日の記録'), findsOneWidget);
  });
}
