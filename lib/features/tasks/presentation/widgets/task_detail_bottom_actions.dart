import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../app/router/route_names.dart';
import '../../../pic/presentation/providers/pic_follow_up_provider.dart';
import '../../domain/entities/task_detail.dart';
import '../controllers/task_detail_controller.dart';

class TaskDetailBottomActions extends StatelessWidget {
  const TaskDetailBottomActions({
    super.key,
    required this.task,
    required this.controller,
    required this.isPic,
    required this.canCancel,
    required this.canReviewFollowUp,
    required this.canStartPicFollowUp,
    required this.isWaitingPicResponse,
    required this.isSubmitting,
    required this.rawStatusLower,
    required this.taskId,
    required this.ref,
    required this.onShowReasonSheet,
    required this.onShowApproveDialog,
  });

  final TaskDetail task;
  final TaskDetailController controller;
  final bool isPic;
  final bool canCancel;
  final bool canReviewFollowUp;
  final bool canStartPicFollowUp;
  final bool isWaitingPicResponse;
  final bool isSubmitting;
  final String rawStatusLower;
  final String taskId;
  final WidgetRef ref;
  final Future<String?> Function({required bool isCancel}) onShowReasonSheet;
  final Future<bool> Function() onShowApproveDialog;

  @override
  Widget build(BuildContext context) {
    if (rawStatusLower == 'canceled') return const SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canCancel)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(
                          color: Colors.redAccent, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.pill),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                    ),
                     onPressed: isSubmitting
                         ? null
                         : () async {
                             final reason = await onShowReasonSheet(
                               isCancel: true,
                             );
                             if (reason == null || reason.trim().isEmpty) {
                               return;
                             }
                             await controller.cancel(
                               task,
                               reason: reason,
                             );
                           },
                     child: isSubmitting
                         ? const SizedBox(
                             width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      Colors.redAccent),
                            ),
                          )
                        : Text(
                            'Batalkan Laporan',
                            style: AppTypography.body1.copyWith(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            if (isPic && canStartPicFollowUp)
              AppButton(
                text: 'Mulai Tindak Lanjut',
                isLoading: isSubmitting,
                onPressed: () {
                  final resolvedReportId =
                      (task.taskId?.toString() ?? taskId)
                          .trim();
                  ref
                      .read(picFollowUpFormProvider.notifier)
                      .setReportId(resolvedReportId);
                  context.pushNamed(RouteNames.picFollowUpPhotos);
                },
              )
            else if (canReviewFollowUp)
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Tolak',
                      type: AppButtonType.outlined,
                      isLoading: isSubmitting,
                      onPressed: () async {
                        final reason = await onShowReasonSheet(
                          isCancel: false,
                        );
                        if (reason == null || reason.trim().isEmpty) {
                          return;
                        }
                        await controller.reject(
                          task,
                          reason: reason,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: 'Terima',
                      isLoading: isSubmitting,
                      onPressed: () async {
                        final confirmed = await onShowApproveDialog();
                        if (!confirmed) return;
                        await controller.approve(task);
                      },
                    ),
                  ),
                ],
              )
            else if (!canCancel)
              AppButton(
                text: isWaitingPicResponse
                    ? 'Menunggu Respon PIC'
                    : (rawStatusLower == 'completed'
                        ? 'Laporan Selesai'
                        : 'Menunggu Respon'),
                type: AppButtonType.outlined,
                onPressed: null,
              ),
          ],
        ),
      ),
    );
  }
}
