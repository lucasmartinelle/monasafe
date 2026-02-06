import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simpleflow/main.dart';

void main() {
  testWidgets('SimpleFlow app renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SimpleFlowApp(),
      ),
    );

    expect(find.text('SimpleFlow'), findsOneWidget);
  });
}
