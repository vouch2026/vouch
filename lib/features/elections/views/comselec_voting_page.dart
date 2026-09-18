import 'package:flutter/material.dart';
import 'comselec_dev_placeholder_page.dart';

class ComselecVotingPage extends StatelessWidget {
  const ComselecVotingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComselecDevPlaceholderPage(
      title: 'Online Voting Portal',
      subtitle: 'Cast your ballot securely for open elections in your scope.',
      icon: Icons.how_to_vote_rounded,
      phaseNumber: 6,
      features: [
        'Dynamic digital ballot generation matching configured seat limits and candidates.',
        'Interactive candidate profile preview and platform statement review.',
        'Review ballot screen with double-confirmation prompt before submission.',
        'Atomic PostgreSQL RPC execution generating verifiable transaction receipt hashes.',
      ],
    );
  }
}
