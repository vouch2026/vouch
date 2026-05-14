import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vouch_v2/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: VouchApp(),
      ),
    );

    // Since it redirects to login, check for VOUCH text
    expect(find.text('VOUCH'), findsNothing); // It takes a frame to render/redirect
    await tester.pumpAndSettle();
    
    // In LoginPage we have 'Welcome Back'
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
