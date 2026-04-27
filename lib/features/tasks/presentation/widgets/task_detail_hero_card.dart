import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../domain/entities/task_detail.dart';
import '../../domain/entities/task_status.dart';

class TaskDetailHeroCard extends StatelessWidget {
  const TaskDetailHeroCard({super.key, required this.task});

  final TaskDetail task;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    final rawStatus = task.status.rawValue;
    final needsOtherDepartmentSupport = task.hasOtherDepartmentSupport;

    switch (rawStatus) {
      case 'pending':
        bgColor = const Color(0xFFD4D8FF);
        break;
      case 'follow up done':
        bgColor = const Color(0xFFFAFF9F);
        break;
      case 'pending rejected':
        bgColor = const Color(0xFFFFCDD2);
        break;
      case 'completed':
        bgColor = const Color(0xFFC1F0D0);
        break;
      case 'canceled':
        bgColor = const Color(0xFF1E1E1E);
        break;
      default:
        bgColor = const Color(0xFFFFFFFF);
    }

    final bool isDark = rawStatus == 'canceled';
    Color textColor = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF1E1E1E), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  rawStatus == 'canceled'
                      ? 'DIBATALKAN'
                      : rawStatus == 'pending rejected'
                          ? 'PENDING REJECTED'
                          : rawStatus.toUpperCase(),
                  style: AppTypography.caption
                      .copyWith(color: textColor, fontWeight: FontWeight.bold),
                ),
              ),
              PhosphorIcon(
                  rawStatus == 'canceled'
                      ? PhosphorIcons.xCircle(PhosphorIconsStyle.fill)
                      : PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
                  color: textColor,
                  size: 32),
            ],
          ),
          const SizedBox(height: 24),
          Text(task.title,
              style: AppTypography.h2.copyWith(color: textColor, height: 1.2)),
          const SizedBox(height: 12),
          Text(
              'Dilaporkan oleh: ${task.reporterName}',
              style: AppTypography.body1
                  .copyWith(color: textColor.withValues(alpha: 0.7))),
          if (needsOtherDepartmentSupport) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.18)
                      : const Color(0xFF1E1E1E).withValues(alpha: 0.10),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : const Color(0xFF1E1E1E).withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      task.isToEngineerTask ? Icons.engineering_rounded : Icons.people_alt_rounded,
                      color: textColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.supportDepartmentTitle,
                          style: AppTypography.body1.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.supportDepartmentDescription,
                          style: AppTypography.caption.copyWith(
                            color: textColor.withValues(alpha: 0.78),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
