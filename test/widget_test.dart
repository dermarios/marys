import 'package:flutter_test/flutter_test.dart';

import 'package:maryssecretbox/main.dart';

void main() {
  testWidgets('Pitty Player smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Pitty Player'), findsWidgets);
  });
}
