import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class VouchEduBrandTitle extends StatelessWidget {
  final double fontSize;
  final FontWeight fontWeight;
  final MainAxisAlignment mainAxisAlignment;

  const VouchEduBrandTitle({
    super.key,
    this.fontSize = 24,
    this.fontWeight = FontWeight.w700,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        children: const [
          TextSpan(
            text: 'Vouch',
            style: TextStyle(color: AppColors.primary),
          ),
          TextSpan(
            text: 'EDU',
            style: TextStyle(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}
