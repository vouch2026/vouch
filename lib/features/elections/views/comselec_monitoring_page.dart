import 'package:flutter/material.dart';
import 'comselec_dev_placeholder_page.dart';

class ComselecMonitoringPage extends StatelessWidget {
  const ComselecMonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComselecDevPlaceholderPage(
      title: 'Voting Monitoring Dashboard',
      subtitle: 'Real-time operational turnout metrics, online vs offline counts, and station activity.',
      icon: Icons.monitor_heart_outlined,
      phaseNumber: 8,
      features: [
        'Live participation rate tracking across campus, faculty, and program scopes.',
        'Online vs Offline ballot breakdown with real-time sync progress.',
        'Anomalous activity alerts without exposing secret ballot candidate choices.',
      ],
    );
  }
}
