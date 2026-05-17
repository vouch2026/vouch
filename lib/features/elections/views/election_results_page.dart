import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/layouts/dashboard_layout.dart';

class ElectionResultsPage extends StatelessWidget {
  const ElectionResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DashboardLayout(
      title: 'Election Results',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Election Results & Certification', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                    Text('Finalize, certify, and publish official university election results', 
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[600])),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.verified_rounded, size: 18),
                  label: const Text('Certify Results'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _WinnerCard(
              electionName: 'SSC General Election 2026',
              winners: const [
                _WinnerInfo(name: 'Juan Dela Cruz', position: 'President', votes: 4520, margin: '52.4%'),
                _WinnerInfo(name: 'Maria Clara', position: 'Vice President', votes: 4100, margin: '48.1%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WinnerCard extends StatelessWidget {
  final String electionName;
  final List<_WinnerInfo> winners;

  const _WinnerCard({required this.electionName, required this.winners});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(electionName, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                const Icon(Icons.emoji_events_rounded, color: Colors.amber),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            ...winners.map((w) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person_rounded, color: Colors.white)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(w.name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                        Text(w.position, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${w.votes} Votes', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      Text(w.margin, style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _WinnerInfo {
  final String name;
  final String position;
  final int votes;
  final String margin;

  const _WinnerInfo({required this.name, required this.position, required this.votes, required this.margin});
}
