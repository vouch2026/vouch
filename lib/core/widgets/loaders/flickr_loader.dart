import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class FlickrLoader extends StatefulWidget {
  final double size;
  final double distance;
  final Duration duration;

  const FlickrLoader({
    super.key,
    this.size = 10.0,
    this.distance = 12.0,
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  State<FlickrLoader> createState() => _FlickrLoaderState();
}

class _FlickrLoaderState extends State<FlickrLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double theta = _controller.value * 2 * math.pi;
        final double xBlue = math.sin(theta) * widget.distance;
        final double xGold = -math.sin(theta) * widget.distance;
        
        final double cosVal = math.cos(theta);
        final double scaleBlue = 1.0 + 0.25 * cosVal;
        final double scaleGold = 1.0 - 0.25 * cosVal;

        // If cosVal >= 0, blue is in front of gold. Else, gold is in front.
        final bool blueInFront = cosVal >= 0;

        final Widget blueBall = Transform.translate(
          offset: Offset(xBlue, 0),
          child: Transform.scale(
            scale: scaleBlue,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );

        final Widget goldBall = Transform.translate(
          offset: Offset(xGold, 0),
          child: Transform.scale(
            scale: scaleGold,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );

        return SizedBox(
          width: (widget.distance + widget.size) * 2.5,
          height: widget.size * 1.5,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: blueInFront 
                ? [goldBall, blueBall] 
                : [blueBall, goldBall],
          ),
        );
      },
    );
  }
}
