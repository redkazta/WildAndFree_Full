import 'package:flutter_test/flutter_test.dart';
import 'package:wild_erp_mobile/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WildErpApp());
    await tester.pump();
  });
}
