import 'package:flutter/material.dart';
import 'shimmer_config.dart';

class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: ShimmerConfig.surfaceColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
