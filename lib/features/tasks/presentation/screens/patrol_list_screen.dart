import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../providers/task_provider.dart';

class PatrolListScreen extends ConsumerStatefulWidget {
  const PatrolListScreen({super.key});

  @override
  ConsumerState<PatrolListScreen> createState() => _PatrolListScreenState();
}

class _PatrolListScreenState extends ConsumerState<PatrolListScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final reportsAsync = ref.watch(petugasTaskMapsProvider);

    // Redirect ke login jika user null atau bukan petugas
    if (user == null || user.role != 'petugas') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.goNamed('login');
        }
      });
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final reports = reportsAsync.valueOrNull ?? <Map<String, dynamic>>[];

    if (reportsAsync.isLoading && reports.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (reportsAsync.hasError && reports.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Gagal memuat data patroli dari backend.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Riwayat Patroli'),
      ),
      body: reports.isEmpty
          ? const Center(child: Text('Belum ada laporan patroli.'))
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: reports.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final rpt = reports[index];
                final dateStr = rpt['date']?.toString();
                final date = DateTime.tryParse(dateStr ?? '');
                final formattedDate = date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : '-';

                final area = rpt['area']?.toString() ?? '-';
                final riskLevel = rpt['riskLevel']?.toString() ?? '-';
                final status = rpt['status']?.toString() ?? 'Pending';

                return AppCard(
                  onTap: () {
                    context.pushNamed(
                      'task_detail',
                      pathParameters: {'id': rpt['id'].toString()},
                    );
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: NetworkImage('https://via.placeholder.com/150'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              area,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              formattedDate,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusBadge(
                            text: status,
                            backgroundColor: _getStatusColor(status),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          StatusBadge(
                            text: riskLevel,
                            backgroundColor: _getRiskLevelColor(riskLevel),
                            type: BadgeType.risk,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'approved':
        return AppColors.statusApproved;
      case 'rejected':
        return AppColors.statusRejected;
      case 'follow up done':
        return const Color(0xFFFAFF9F);
      case 'canceled':
        return AppColors.statusRejected;
      case 'pending':
      default:
        return AppColors.statusPending;
    }
  }

  Color _getRiskLevelColor(String level) {
    final value = level.toLowerCase();

    if (value.contains('ringan') || value == '1') return AppColors.riskLow;
    if (value.contains('menengah') || value == 'sedang' || value == '2') return AppColors.riskMedium;
    if (value.contains('berat') || value == '3') return AppColors.riskHigh;
    if (value.contains('kritis') || value == '4') return AppColors.riskCritical;

    return AppColors.riskLow;
  }
}
