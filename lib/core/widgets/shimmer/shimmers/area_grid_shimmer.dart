import 'package:flutter/material.dart';
import '../base_shimmer.dart';
import '../shimmer_box.dart';
import '../shimmer_config.dart';

class AreaGridShimmer extends StatelessWidget {
  const AreaGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return BaseShimmer(
          child: Container(
            decoration: BoxDecoration(
              color: ShimmerConfig.surfaceColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ShimmerConfig.borderColor),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 40, height: 40),
                const SizedBox(height: 12),
                const ShimmerBox(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                const ShimmerBox(width: 80, height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
