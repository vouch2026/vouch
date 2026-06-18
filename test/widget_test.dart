import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vouch_v2/main.dart';
import 'package:vouch_v2/routes/app_router.dart';
import 'package:vouch_v2/features/auth/views/login_page.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    final testRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LoginPage(),
        ),
      ],
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routerProvider.overrideWithValue(testRouter),
        ],
        child: const VouchApp(),
      ),
    );

    await tester.pumpAndSettle();
    
    // In LoginPage we have 'Welcome back'
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
