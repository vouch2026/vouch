import 'package:flutter/material.dart';
import 'comselec_dev_placeholder_page.dart';

class ComselecVotersPage extends StatelessWidget {
  const ComselecVotersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComselecDevPlaceholderPage(
      title: 'Voter Eligibility Management',
      subtitle: 'Manage scope-based voter rosters, verification statuses, and manual reviews.',
      icon: Icons.verified_user_outlined,
      phaseNumber: 5,
      features: [
        'Automated roster generation per election scope (Campus, Faculty, Program).',
        'Voter eligibility status tracking: PENDING, ELIGIBLE, INELIGIBLE, MANUAL_REVIEW, SUSPENDED.',
        'Manual override controls with mandatory commissioner audit justification.',
        'Secret voter submission ledger separation to protect vote choice privacy.',
      ],
    );
  }
}
