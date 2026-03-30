import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

enum BadgeType { status, risk }

class StatusBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final BadgeType type;

  const StatusBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    this.textColor = AppColors.textInverse,
    this.type = BadgeType.status,
  });

  factory StatusBadge.pending() {
    return const StatusBadge(
      text: 'Pending',
      backgroundColor: AppColors.statusPending,
    );
  }

  factory StatusBadge.approved() {
    return const StatusBadge(
      text: 'Approved',
      backgroundColor: AppColors.statusApproved,
    );
  }

  factory StatusBadge.rejected() {
    return const StatusBadge(
      text: 'Rejected',
      backgroundColor: AppColors.statusRejected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.borderCircular),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
