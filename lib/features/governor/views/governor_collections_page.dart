import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'governor_created_fees_page.dart';

class GovernorCollectionsPage extends ConsumerWidget {
  const GovernorCollectionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const GovernorCreatedFeesPage(
      title: 'Collection Management',
      subtitle: 'Track and manage fee collections and financial inflows',
      showBackButton: false,
      isTopLevel: true,
    );
  }
}
