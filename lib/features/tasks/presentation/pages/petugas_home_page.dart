import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_card.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../providers/task_provider.dart';

class PetugasHomePage extends ConsumerWidget {
  const PetugasHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(tasksFutureProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Histori Laporan Saya', style: AppTypography.h3),
        elevation: 0,
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            color: AppColors.textPrimary,
            onPressed: () {},
          ),
        ],
      ),
      body: reportsAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return Center(
              child: Text(
                'Belum ada histori patroli.',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: reports.length,
            separatorBuilder: (c, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final report = reports[index];
              return AppCard(
                padding: EdgeInsets.zero,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: () {
                    // Navigasi ke detail Action Status PIC
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: const Icon(
                                Icons.assignment_outlined,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report.name ?? report.code,
                                    style: AppTypography.body1,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    report.notes,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.divider,
                          ),
                        ),
                        Row(
                          children: [
                            _buildStatusBadge(report.status),
                            const Spacer(),
                            Text(
                              'Detail & Action',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: AppColors.primary,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: AppTypography.caption.copyWith(color: AppColors.statusRejected),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = AppColors.statusPending;
        textColor = AppColors.textInverse;
        break;
      case 'rejected':
        bgColor = AppColors.statusRejected;
        textColor = AppColors.textInverse;
        break;
      case 'approved':
        bgColor = AppColors.statusApproved;
        textColor = AppColors.textInverse;
        break;
      default:
        bgColor = AppColors.surfaceVariant;
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
