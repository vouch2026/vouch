import 'package:flutter/material.dart';

/// Interactive 1-5 star input. Pass [onChanged] null for read-only display.
class StarRatingInput extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onChanged;
  final double size;
  final Color color;

  const StarRatingInput({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 32,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final star = index + 1;
        final filled = star <= rating;
        final icon = Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          color: color,
          size: size,
        );
        if (onChanged == null) return icon;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged!(star),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: icon,
          ),
        );
      }),
    );
  }
}
