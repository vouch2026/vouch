import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vouch_v2/features/governor/views/governor_finance_page.dart';
import 'package:vouch_v2/features/finance/models/fee_model.dart';
import 'package:vouch_v2/features/finance/models/student_payment_model.dart';
import 'package:vouch_v2/features/finance/providers/finance_provider.dart';
import 'package:vouch_v2/features/auth/providers/auth_provider.dart';
import 'package:vouch_v2/features/auth/models/user_model.dart';
import 'package:vouch_v2/features/organizations/providers/workspace_provider.dart';
import 'package:vouch_v2/core/models/app_role.dart';
import 'package:vouch_v2/features/organizations/models/organization_model.dart';
import 'package:vouch_v2/features/finance/models/payment_receiver_model.dart';

void main() {
  testWidgets('Test _StudentFinanceView on mobile size with empty lists', (WidgetTester tester) async {
    // Set mobile size
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final now = DateTime.now();

    final mockFees = <FeeModel>[];
    final mockSubmissions = <StudentPaymentModel>[];

    final mockUser = UserModel(
      id: 'user-1',
      authId: 'auth-1',
      email: 'student@test.com',
      firstName: 'John',
      lastName: 'Doe',
      role: 'student',
      schoolId: '2023-0001',
      createdAt: now,
    );

    final mockWorkspaceState = WorkspaceState(
      selectedOrganization: const OrganizationModel(
        id: 'org-1',
        name: 'Test Org',
        code: 'TO',
      ),
      activeRole: AppRole(
        roleName: 'Student',
        hierarchyLevel: 1,
        scopeType: 'college',
        permissions: [],
      ),
      isInitialized: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workspaceFeesProvider.overrideWith((ref) => mockFees),
          workspaceStudentPaymentsProvider.overrideWith((ref) => mockSubmissions),
          userProfileProvider.overrideWith((ref) => mockUser),
          paymentReceiversProvider.overrideWith((ref) => []),
          workspaceProvider.overrideWith((ref) => WorkspaceNotifierMock(mockWorkspaceState)),
        ],
        child: const MaterialApp(
          home: GovernorFinancePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Print all text widgets
    for (final element in find.byType(Text).evaluate()) {
      final widget = element.widget as Text;
      print('FOUND TEXT: "${widget.data}"');
    }

    // Verify it rendered the Student View successfully
    expect(find.text('My Fees & Payments'), findsOneWidget);
    expect(find.text('AVAILABLE FEES (0)'), findsOneWidget);
  });

  testWidgets('Test GovernorFinancePage with Governor role showing payment method filter', (WidgetTester tester) async {
    // Set desktop/wider size
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final now = DateTime.now();

    final mockFees = <FeeModel>[];
    final mockSubmissions = <StudentPaymentModel>[];
    final mockReceivers = [
      const PaymentReceiverModel(
        id: 'rec-1',
        bankType: 'GCash',
        accountName: 'Test GCash',
        accountNumber: '09123456789',
      ),
      const PaymentReceiverModel(
        id: 'rec-2',
        bankType: 'Maya',
        accountName: 'Test Maya',
        accountNumber: '09123456780',
      ),
    ];

    final mockUser = UserModel(
      id: 'user-1',
      authId: 'auth-1',
      email: 'governor@test.com',
      firstName: 'Jane',
      lastName: 'Smith',
      role: 'governor',
      schoolId: '2023-0002',
      createdAt: now,
    );

    final mockWorkspaceState = WorkspaceState(
      selectedOrganization: const OrganizationModel(
        id: 'org-1',
        name: 'Test Org',
        code: 'TO',
      ),
      activeRole: AppRole(
        roleName: 'Governor',
        hierarchyLevel: 10,
        scopeType: 'college',
        permissions: [],
      ),
      isInitialized: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workspaceFeesProvider.overrideWith((ref) => mockFees),
          workspaceStudentPaymentsProvider.overrideWith((ref) => mockSubmissions),
          userProfileProvider.overrideWith((ref) => mockUser),
          paymentReceiversProvider.overrideWith((ref) => mockReceivers),
          workspaceProvider.overrideWith((ref) => WorkspaceNotifierMock(mockWorkspaceState)),
        ],
        child: const MaterialApp(
          home: GovernorFinancePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify it rendered the Governor view
    expect(find.text('Finance & Collections'), findsOneWidget);
    
    // Verify it rendered our payment method filter default selection
    expect(find.text('All Methods'), findsOneWidget);
  });

  testWidgets('Test _StudentFinanceView with past due fee shows disabled submission', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final now = DateTime.now();
    final pastDue = now.subtract(const Duration(days: 2));

    final mockFees = [
      FeeModel(
        id: 'fee-1',
        name: 'Membership Fee',
        amount: 100.0,
        scopeType: 'college',
        scopeId: 'college-1',
        isMandatory: true,
        dueDate: pastDue,
        academicTermId: 'term-1',
      ),
    ];
    final mockSubmissions = <StudentPaymentModel>[];

    final mockUser = UserModel(
      id: 'user-1',
      authId: 'auth-1',
      email: 'student@test.com',
      firstName: 'John',
      lastName: 'Doe',
      role: 'student',
      schoolId: '2023-0001',
      createdAt: now,
    );

    final mockWorkspaceState = WorkspaceState(
      selectedOrganization: const OrganizationModel(
        id: 'org-1',
        name: 'Test Org',
        code: 'TO',
      ),
      activeRole: AppRole(
        roleName: 'Student',
        hierarchyLevel: 1,
        scopeType: 'college',
        permissions: [],
      ),
      isInitialized: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workspaceFeesProvider.overrideWith((ref) => mockFees),
          workspaceStudentPaymentsProvider.overrideWith((ref) => mockSubmissions),
          userProfileProvider.overrideWith((ref) => mockUser),
          paymentReceiversProvider.overrideWith((ref) => []),
          workspaceProvider.overrideWith((ref) => WorkspaceNotifierMock(mockWorkspaceState)),
        ],
        child: const MaterialApp(
          home: GovernorFinancePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify it rendered display status as PAST DUE
    expect(find.text('PAST DUE'), findsOneWidget);
    
    // Verify the Submit button is disabled or Submission Closed text is visible
    expect(find.text('Submission Closed'), findsOneWidget);
    expect(find.text('Submission is closed because this fee is past its due date.'), findsOneWidget);
  });

  testWidgets('Test _StudentFinanceView with due date as today allows submission', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final now = DateTime.now();

    final mockFees = [
      FeeModel(
        id: 'fee-1',
        name: 'Membership Fee',
        amount: 100.0,
        scopeType: 'college',
        scopeId: 'college-1',
        isMandatory: true,
        dueDate: now,
        academicTermId: 'term-1',
      ),
    ];
    final mockSubmissions = <StudentPaymentModel>[];

    final mockUser = UserModel(
      id: 'user-1',
      authId: 'auth-1',
      email: 'student@test.com',
      firstName: 'John',
      lastName: 'Doe',
      role: 'student',
      schoolId: '2023-0001',
      createdAt: now,
    );

    final mockWorkspaceState = WorkspaceState(
      selectedOrganization: const OrganizationModel(
        id: 'org-1',
        name: 'Test Org',
        code: 'TO',
      ),
      activeRole: AppRole(
        roleName: 'Student',
        hierarchyLevel: 1,
        scopeType: 'college',
        permissions: [],
      ),
      isInitialized: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workspaceFeesProvider.overrideWith((ref) => mockFees),
          workspaceStudentPaymentsProvider.overrideWith((ref) => mockSubmissions),
          userProfileProvider.overrideWith((ref) => mockUser),
          paymentReceiversProvider.overrideWith((ref) => []),
          workspaceProvider.overrideWith((ref) => WorkspaceNotifierMock(mockWorkspaceState)),
        ],
        child: const MaterialApp(
          home: GovernorFinancePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify it rendered display status as TO PAY
    expect(find.text('TO PAY'), findsOneWidget);
    
    // Verify the Submit button is enabled and has the correct text
    expect(find.text('Submit Proof of Payment'), findsOneWidget);
    expect(find.text('Submission is closed because this fee is past its due date.'), findsNothing);
  });
}

class WorkspaceNotifierMock extends StateNotifier<WorkspaceState> implements WorkspaceNotifier {
  WorkspaceNotifierMock(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
