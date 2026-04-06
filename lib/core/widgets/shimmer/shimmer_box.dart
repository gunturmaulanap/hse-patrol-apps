import 'package:flutter/material.dart';
import 'shimmer_config.dart';

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 16,
      decoration: BoxDecoration(
        color: ShimmerConfig.surfaceColor,
        borderRadius: borderRadius ?? BorderRadius.circular(10),
      ),
    );
  }
}
