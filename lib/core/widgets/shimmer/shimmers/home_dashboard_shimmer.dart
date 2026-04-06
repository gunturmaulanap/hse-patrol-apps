import 'package:flutter/material.dart';
import '../base_shimmer.dart';
import '../shimmer_box.dart';
import '../shimmer_circle.dart';
import '../shimmer_config.dart';
import 'task_card_shimmer.dart';

class HomeDashboardShimmer extends StatelessWidget {
  const HomeDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: BaseShimmer(
              child: Row(
                children: [
                  const Expanded(child: ShimmerBox(height: 24, width: 200)),
                  ShimmerCircle(size: 48),
                ],
              ),
            ),
          ),
        ),
        // Productivity Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: BaseShimmer(
              child: _ProductivityCardShimmer(),
            ),
          ),
        ),
        // Task List
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: TaskCardShimmer(),
              ),
              childCount: 4,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductivityCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ShimmerConfig.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ShimmerConfig.borderColor),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 120, height: 16),
          const SizedBox(height: 16),
          const ShimmerBox(width: double.infinity, height: 32),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(child: ShimmerBox(height: 8)),
              const SizedBox(width: 8),
              Expanded(child: ShimmerBox(height: 8)),
              const SizedBox(width: 8),
              Expanded(child: ShimmerBox(height: 8)),
            ],
          ),
        ],
      ),
    );
  }
}
