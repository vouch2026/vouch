import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Organization logo with a guaranteed fallback.
///
/// - `null` / empty / whitespace URLs render the fallback icon immediately.
/// - Load failures (404, 403, offline, bad URL) render the fallback icon
///   via [CachedNetworkImage.errorWidget] instead of a blank box/circle.
/// - While loading, the background color shows (no layout shift).
///
/// Replaces the scattered `CircleAvatar(backgroundImage:)`,
/// `DecorationImage`, and raw `NetworkImage` copies that had no error
/// handling in the workspace selector, dashboard, and settings surfaces.
class OrgLogoAvatar extends StatelessWidget {
  final String? logoUrl;
  final double size;
  final double borderRadius;
  final bool circle;
  final IconData fallbackIcon;
  final Color backgroundColor;
  final Color iconColor;

  const OrgLogoAvatar({
    super.key,
    required this.logoUrl,
    this.size = 40,
    this.borderRadius = 12,
    this.circle = false,
    this.fallbackIcon = Icons.corporate_fare_rounded,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.iconColor = const Color(0xFF9E9E9E),
  });

  @override
  Widget build(BuildContext context) {
    final url = logoUrl?.trim() ?? '';
    final iconSize = size * 0.5;

    Widget fallback({bool transparent = false}) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: transparent ? Colors.transparent : backgroundColor,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius:
              circle ? null : BorderRadius.circular(borderRadius),
        ),
        child: Icon(fallbackIcon, size: iconSize, color: iconColor),
      );
    }

    if (url.isEmpty) return fallback();

    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (_, __) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius:
              circle ? null : BorderRadius.circular(borderRadius),
        ),
      ),
      errorWidget: (_, _, _) => fallback(),
      imageBuilder: (context, provider) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius:
              circle ? null : BorderRadius.circular(borderRadius),
          image: DecorationImage(image: provider, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
