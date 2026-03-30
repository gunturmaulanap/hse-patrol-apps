import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../reports/presentation/widgets/report_card.dart';
import '../../../../core/mock_api/mock_database.dart';
import '../providers/active_area_filter_provider.dart';

class PicFindingScreen extends ConsumerWidget {
  const PicFindingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final db = ref.watch(mockDatabaseProvider);
    final activeFilter = ref.watch(activeAreaFilterProvider);

    final areaList = user?.areaAccess ?? [];
    
    // Filter list laporan berdasarkan otorisasi area PIC (Menampilkan SEMUA riwayat status)
    final findings = db.reports.where((rpt) {
      final inArea = areaList.contains(rpt['area']);
      final matchesFilter = activeFilter == null || rpt['area'] == activeFilter;
      return inArea && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(activeFilter == null ? 'Daftar Temuan Aktif' : 'Temuan $activeFilter'),
        actions: [
          if (activeFilter != null)
            IconButton(
              tooltip: 'Hapus Filter Area',
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () {
                ref.read(activeAreaFilterProvider.notifier).state = null;
              },
            )
        ],
      ),
      body: findings.isEmpty
          ? const Center(child: Text('Tidak ada temuan aktif di area Anda.'))
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: findings.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final rpt = findings[index];
                final dateStr = rpt['date'] as String;
                final date = DateTime.tryParse(dateStr);
                final formattedDate = date != null ? '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}' : '-';

                final formalTitle = 'Inspeksi ${rpt['area'] ?? '-'} - Masalah: ${rpt['rootCause'] ?? '-'}';

                return ReportCard(
                  title: formalTitle,
                  area: rpt['area'] ?? '-',
                  date: formattedDate,
                  statusBadge: StatusBadge(
                    text: rpt['status'] ?? 'Pending',
                    backgroundColor: AppColors.statusPending,
                  ),
                  onTap: () {
                    context.pushNamed(
                      'report_detail',
                      pathParameters: {'id': rpt['id'].toString()},
                    );
                  },
                );
              },
            ),
    );
  }
}
