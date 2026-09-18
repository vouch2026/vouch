import 'package:flutter/material.dart';
import 'comselec_dev_placeholder_page.dart';

class ComselecMyStatusPage extends StatelessWidget {
  const ComselecMyStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComselecDevPlaceholderPage(
      title: 'My Voting Status & Receipts',
      subtitle: 'Track your submitted ballot receipts and voting participation records.',
      icon: Icons.receipt_long_rounded,
      phaseNumber: 6,
      features: [
        'Secure receipt hash lookup confirming your vote was recorded by the server.',
        'Online and offline synchronization status verification.',
        'Strict secret ballot protection: ballot choice privacy is guaranteed.',
      ],
    );
  }
}
