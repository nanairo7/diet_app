import 'package:flutter_test/flutter_test.dart';

import 'package:diet_app/main.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const DietApp());
    await tester.pump();

    expect(find.text('今日の記録'), findsOneWidget);
  });
}
