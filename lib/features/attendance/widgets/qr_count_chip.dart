import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QrCountChip extends StatelessWidget {
  const QrCountChip({super.key, required this.label, required this.count});

  final String label;
  final int count;

  static const Color primaryColor = Color(0xFF003DA5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
      ),
      child: Text(
        '$count $label',
        style: GoogleFonts.poppins(
          color: primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
