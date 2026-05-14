import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/layouts/dashboard_layout.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return DashboardLayout(
      title: 'Dashboard',
      actions: [
        IconButton(
          onPressed: () {
            ref.read(authControllerProvider.notifier).signOut();
          },
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
        ),
      ],
      child: Center(
        child: userProfile.when(
          data: (profile) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome, ${profile?.fullName ?? 'User'}!',
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Role: ${profile?.role ?? 'N/A'}',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        ),
      ),
    );
  }
}
