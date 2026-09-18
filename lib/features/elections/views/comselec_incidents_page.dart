import 'package:flutter/material.dart';
import 'comselec_dev_placeholder_page.dart';

class ComselecIncidentsPage extends StatelessWidget {
  const ComselecIncidentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComselecDevPlaceholderPage(
      title: 'Incident & Complaints Log',
      subtitle: 'Track candidate disputes, station concerns, and election reconciliation issues.',
      icon: Icons.report_problem_outlined,
      phaseNumber: 9,
      features: [
        'Categorized incident filing (Filing Disputes, Station Failures, Discrepancies).',
        'Commissioner review assignment and resolution tracking.',
        'Auditable incident trail linked to election certification.',
      ],
    );
  }
}
