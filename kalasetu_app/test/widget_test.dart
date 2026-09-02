import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalasetu_app/app/app.dart';

void main() {
  testWidgets('KalaSetuApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KalaSetuApp(),
      ),
    );
    expect(find.byType(KalaSetuApp), findsOneWidget);
  });
}
