import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../organizations/providers/workspace_provider.dart';
import '../../../core/permissions/app_permissions.dart';
import 'workspace_sanctions_page.dart';
import 'my_sanctions_page.dart';

class SanctionRedirector extends ConsumerWidget {
  const SanctionRedirector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRole = ref.watch(workspaceProvider).activeRole;
    
    final canManage = activeRole?.hasAnyPermission([
      AppPermissions.createSanctionRules,
      AppPermissions.receiveSanctionItems,
    ]) ?? false;

    if (canManage) {
      return const WorkspaceSanctionsPage();
    } else {
      return const MySanctionsPage();
    }
  }
}
