import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logos/vouch.png',
                    width: 60,
                    height: 60,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.displaySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Vou',
                        ),
                        TextSpan(
                          text: 'ch',
                          style: TextStyle(color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            path: RoutePaths.dashboard,
          ),
          _SidebarItem(
            icon: Icons.corporate_fare_outlined,
            label: 'Organizations',
            path: RoutePaths.organizations,
          ),
          _SidebarItem(
            icon: Icons.event_outlined,
            label: 'Events',
            path: RoutePaths.events,
          ),
          _SidebarItem(
            icon: Icons.how_to_reg_outlined,
            label: 'Attendance',
            path: RoutePaths.attendance,
          ),
          _SidebarItem(
            icon: Icons.how_to_vote_outlined,
            label: 'Elections',
            path: RoutePaths.elections,
          ),
          _SidebarItem(
            icon: Icons.payments_outlined,
            label: 'Finance',
            path: RoutePaths.finance,
          ),
          const Spacer(),
          const Divider(),
          _SidebarItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            path: RoutePaths.settings,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String path;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = GoRouterState.of(context).matchedLocation == path;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textGrey,
      ),
      title: Text(
        label,
        style: AppTextStyles.titleMedium.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textDark,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        context.go(path);
        Navigator.pop(context); // Close drawer
      },
    );
  }
}
