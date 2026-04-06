import 'package:flutter/material.dart';
import '../base_shimmer.dart';
import '../shimmer_box.dart';
import '../shimmer_circle.dart';
import '../shimmer_config.dart';

class TaskDetailShimmer extends StatelessWidget {
  const TaskDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Hero Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BaseShimmer(
              child: _HeroCardShimmer(),
            ),
          ),
        ),
        // Info Cards Grid
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: BaseShimmer(
              child: Column(
                children: const [
                  Row(
                    children: [
                      Expanded(child: _InfoCardShimmer()),
                      SizedBox(width: 12),
                      Expanded(child: _InfoCardShimmer()),
                    ],
                  ),
                  SizedBox(height: 12),
                  _InfoCardShimmer(isWide: true),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        // Section Box
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: BaseShimmer(
              child: _SectionBoxShimmer(),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        // Photo Grid
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: BaseShimmer(
              child: _PhotoGridShimmer(),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ShimmerConfig.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ShimmerConfig.borderColor),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 100, height: 28),
          const SizedBox(height: 16),
          const ShimmerBox(width: double.infinity, height: 24),
          const SizedBox(height: 8),
          const ShimmerBox(width: 200, height: 16),
        ],
      ),
    );
  }
}

class _InfoCardShimmer extends StatelessWidget {
  final bool isWide;

  const _InfoCardShimmer({this.isWide = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ShimmerConfig.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ShimmerConfig.borderColor),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerCircle(size: 32),
          const SizedBox(height: 8),
          const ShimmerBox(width: double.infinity, height: 12),
          const SizedBox(height: 4),
          ShimmerBox(width: isWide ? 120 : 50, height: 10),
        ],
      ),
    );
  }
}

class _SectionBoxShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ShimmerConfig.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ShimmerConfig.borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 80, height: 20),
          const SizedBox(height: 12),
          const ShimmerBox(width: double.infinity, height: 16),
          const SizedBox(height: 8),
          const ShimmerBox(width: double.infinity, height: 16),
          const SizedBox(height: 8),
          const ShimmerBox(width: 150, height: 16),
        ],
      ),
    );
  }
}

class _PhotoGridShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: ShimmerConfig.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ShimmerConfig.borderColor),
          ),
          child: const Center(
            child: ShimmerCircle(size: 40),
          ),
        );
      },
    );
  }
}
