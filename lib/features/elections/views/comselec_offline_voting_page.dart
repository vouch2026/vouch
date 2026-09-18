import 'package:flutter/material.dart';
import 'comselec_dev_placeholder_page.dart';

class ComselecOfflineVotingPage extends StatelessWidget {
  const ComselecOfflineVotingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComselecDevPlaceholderPage(
      title: 'Offline Voting Sessions & Stations',
      subtitle: 'Manage authorized physical voting station devices, encrypted queues, and server sync.',
      icon: Icons.edgesensor_high_outlined,
      phaseNumber: 7,
      features: [
        'Device registration with public/private key station authorization.',
        'Hive encrypted offline queue management with SHA-256 HMAC payload verification.',
        'Batch reconciliation engine supporting offline queue recovery and conflict flags.',
      ],
    );
  }
}
