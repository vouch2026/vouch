import 'package:flutter/material.dart';
import 'comselec_dev_placeholder_page.dart';

class ComselecMyEligibilityPage extends StatelessWidget {
  const ComselecMyEligibilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComselecDevPlaceholderPage(
      title: 'My Voting Eligibility',
      subtitle: 'View your institutional voting eligibility status for upcoming and active elections.',
      icon: Icons.fact_check_outlined,
      phaseNumber: 5,
      features: [
        'Real-time verification of campus, faculty, and program enrollment eligibility.',
        'Clear breakdown of active election scopes you are registered to vote in.',
        'Direct inquiry and request for manual eligibility review if flagged.',
      ],
    );
  }
}
