import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pop_toast/pop_toast.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
    WidgetsApp(
      color: const Color(0xFF000000),
      navigatorKey: Toast.navigatorKey,
      onGenerateRoute: (settings) => PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondary) => const SizedBox.expand(),
      ),
    ),
  );

  tearDown(Toast.dismissAll);

  testWidgets('shows a toast and hides it after its duration', (tester) async {
    await pumpApp(tester);
    Toast.show('Hello', duration: const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Hello'), findsNothing);
  });

  testWidgets('queues toasts and shows them in order', (tester) async {
    await pumpApp(tester);
    final first = Toast.show('First');
    Toast.show('Second');
    await tester.pumpAndSettle();
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsNothing);

    first.dismiss();
    await tester.pumpAndSettle();
    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);
  });

  testWidgets('replace clears the current and queued toasts', (tester) async {
    await pumpApp(tester);
    Toast.show('First');
    Toast.show('Second');
    Toast.show('Urgent', replace: true);
    await tester.pumpAndSettle();
    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsNothing);
    expect(find.text('Urgent'), findsOneWidget);
  });

  testWidgets('tap dismisses and completes closed', (tester) async {
    await pumpApp(tester);
    var closed = false;
    Toast.show('Tap me').closed.then((_) => closed = true);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tap me'));
    await tester.pumpAndSettle();
    expect(find.text('Tap me'), findsNothing);
    expect(closed, isTrue);
  });

  testWidgets('works after the app is rebuilt from scratch', (tester) async {
    await pumpApp(tester);
    Toast.show('Old');
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester);
    Toast.show('New');
    await tester.pumpAndSettle();
    expect(find.text('New'), findsOneWidget);
  });

  testWidgets('throws a clear error without an overlay', (tester) async {
    await tester.pumpWidget(const SizedBox());
    expect(() => Toast.show('x'), throwsFlutterError);
  });
}
