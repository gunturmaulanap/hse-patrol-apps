import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'shimmer_config.dart';

class BaseShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const BaseShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          baseColor ?? ShimmerConfig.baseColor,
          highlightColor ?? ShimmerConfig.highlightColor,
          baseColor ?? ShimmerConfig.baseColor,
        ],
        stops: const <double>[0.15, 0.5, 0.85],
      ),
      period: ShimmerConfig.animationDuration,
      child: child,
    );
  }
}
