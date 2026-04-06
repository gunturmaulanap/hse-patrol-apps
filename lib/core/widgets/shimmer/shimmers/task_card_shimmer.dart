import 'package:flutter/material.dart';
import '../base_shimmer.dart';
import '../shimmer_box.dart';
import '../shimmer_config.dart';

class TaskCardShimmer extends StatelessWidget {
  const TaskCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: ShimmerConfig.surfaceColor,
          border: Border.all(color: ShimmerConfig.borderColor),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            const ShimmerBox(width: 80, height: 24),
            const SizedBox(height: 12),
            // Title
            const ShimmerBox(width: double.infinity, height: 20),
            const SizedBox(height: 8),
            // Area
            const ShimmerBox(width: 150, height: 16),
            const SizedBox(height: 12),
            // Metadata row
            const Row(
              children: [
                ShimmerBox(width: 60, height: 14),
                Spacer(),
                ShimmerBox(width: 60, height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
