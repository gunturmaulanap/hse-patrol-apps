import 'package:flutter/material.dart';
import '../base_shimmer.dart';
import '../shimmer_box.dart';
import '../shimmer_circle.dart';
import '../shimmer_config.dart';

class ListTileShimmer extends StatelessWidget {
  const ListTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: ShimmerConfig.surfaceColor,
          border: Border.all(color: ShimmerConfig.borderColor),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(12),
        child: const Row(
          children: [
            ShimmerCircle(size: 40),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: double.infinity, height: 16),
                  SizedBox(height: 8),
                  ShimmerBox(width: 150, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
