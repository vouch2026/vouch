import 'package:flutter/material.dart';
import 'comselec_dev_placeholder_page.dart';

class ComselecPositionsPage extends StatelessWidget {
  const ComselecPositionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComselecDevPlaceholderPage(
      title: 'Position Management',
      subtitle: 'Configure available seats, voting types, and eligibility criteria for election positions.',
      icon: Icons.badge_outlined,
      phaseNumber: 2,
      features: [
        'Configurable seat counts, limits, and display ordering per scope (Campus, Faculty, Program).',
        'Voting method options: Single Choice, Multiple Choice, Rank Choice, and Abstain configuration.',
        'Separation of Position Eligibility and Candidate Eligibility rules.',
        'Real-time validation against election scope and candidate filing limits.',
      ],
    );
  }
}
