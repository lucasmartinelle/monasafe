import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monasafe/main.dart';

void main() {
  testWidgets('Monasafe app renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MonasafeApp(),
      ),
    );

    expect(find.text('Monasafe'), findsOneWidget);
  });
}
