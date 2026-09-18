import 'package:flutter/material.dart';
import 'comselec_dev_placeholder_page.dart';

class ComselecGuidelinesPage extends StatelessWidget {
  const ComselecGuidelinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComselecDevPlaceholderPage(
      title: 'Election Guidelines & Rules',
      subtitle: 'Official election regulations, candidate codes of conduct, and voting procedures.',
      icon: Icons.description_outlined,
      phaseNumber: 9,
      features: [
        'Version-controlled election guidelines associated with academic terms.',
        'Downloadable institutional election code documents and candidate policy guides.',
        'Public accessibility for all voters, candidates, and observers.',
      ],
    );
  }
}
