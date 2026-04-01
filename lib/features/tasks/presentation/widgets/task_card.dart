import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';

class ReportCard extends StatelessWidget {
  final String title;
  final String area;
  final String date;
  final StatusBadge statusBadge;
  final VoidCallback onTap;

  const ReportCard({
    super.key,
    required this.title,
    required this.area,
    required this.date,
    required this.statusBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                statusBadge,
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedLocation01,
                  size: 16,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    area,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedCalendar01,
                  size: 16,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
