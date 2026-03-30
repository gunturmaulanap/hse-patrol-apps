import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/mock_api/mock_database.dart';

class PatrolListScreen extends ConsumerStatefulWidget {
  const PatrolListScreen({super.key});

  @override
  ConsumerState<PatrolListScreen> createState() => _PatrolListScreenState();
}

class _PatrolListScreenState extends ConsumerState<PatrolListScreen> {
  @override
  Widget build(BuildContext context) {
    final mockDb = ref.watch(mockDatabaseProvider);
    final reports = mockDb.reports;

    return Scaffold(
      appBar: AppBar(
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
                final dateStr = rpt['date'] as String;
                final date = DateTime.tryParse(dateStr);
                final formattedDate = date != null ? '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}' : '-';

                final formalTitle = 'Inspeksi ${rpt['area'] ?? '-'} - Peringatan: ${rpt['riskLevel'] ?? '-'}';

                return AppCard(
                  onTap: () {
                    context.pushNamed(
                      'report_detail',
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
                              rpt['area'] ?? '-',
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
                            text: rpt['status'] ?? 'Pending',
                            backgroundColor: _getStatusColor(rpt['status'] ?? 'Pending'),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          StatusBadge(
                            text: rpt['riskLevel'] ?? 'Ringan',
                            backgroundColor: _getRiskLevelColor(rpt['riskLevel'] ?? 'Ringan'),
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
      case 'approved':
        return AppColors.statusApproved;
      case 'rejected':
        return AppColors.statusRejected;
      case 'pending':
      default:
        return AppColors.statusPending;
    }
  }

  Color _getRiskLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'kritis':
        return AppColors.riskCritical;
      case 'berat':
        return AppColors.riskHigh;
      case 'sedang':
        return AppColors.riskMedium;
      case 'ringan':
      default:
        return AppColors.riskLow;
    }
  }
}
