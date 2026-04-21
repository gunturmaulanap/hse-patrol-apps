import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../areas/presentation/providers/area_provider.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../providers/active_area_filter_provider.dart';
import '../widgets/area_card.dart';

class PicHomeScreen extends ConsumerWidget {
  const PicHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final areasAsync = ref.watch(areaByUserProvider);
    final reportsAsync = ref.watch(petugasTaskMapsProvider);

    Future<void> onRefresh() async {
      debugPrint('[PicHomeScreen] pull-to-refresh triggered');
      ref.invalidate(tasksFutureProvider);
      ref.invalidate(areaByUserProvider);
      ref.invalidate(petugasTaskMapsProvider);
      final results = await Future.wait([
        ref.read(tasksFutureProvider.future),
        ref.read(areaByUserProvider.future),
        ref.read(petugasTaskMapsProvider.future),
      ]);

      final totalTasks = (results[0] as List).length;
      final totalAreas = (results[1] as List).length;
      final totalTaskMaps = (results[2] as List).length;
      debugPrint(
        '[PicHomeScreen] refresh complete -> tasks=$totalTasks areas=$totalAreas maps=$totalTaskMaps',
      );
    }

    final areas = areasAsync.valueOrNull ?? const [];
    final reports = reportsAsync.valueOrNull ?? <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
          // HEADER: Good Morning & Profile 
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good Morning,', style: AppTypography.h2),
                          Text(
                            '${user?.username ?? 'PIC'}!',
                            style: AppTypography.h1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => context.pushNamed(RouteNames.petugasProfile),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: AppColors.surface, width: 2),
                        ),
                        child: Icon(
                          PhosphorIcons.user(),
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // SUB-HEADER: Keterangan
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Work Areas',
                    style: AppTypography.h1.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select an area to view and follow up tasks',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // GRID AREA: Menampilkan 2 kolom grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,           
                crossAxisSpacing: 16,        
                mainAxisSpacing: 16,         
                childAspectRatio: 0.70, // Disesuaikan agar muat 2 badge vertikal jika perlu
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final area = areas[index];
                   
                  // Hitung jumlah task Pending dan Follow Up Done secara terpisah
                  final tasksInArea = reports.where((r) {
                    final sameArea =
                        (r['area']?.toString().trim().toLowerCase() ?? '') ==
                        area.name.trim().toLowerCase();
                    final isNotCanceled = _getPicStatusTag(r) != 'Canceled';
                    return sameArea && isNotCanceled;
                  }).toList();
                    
                  // 1. Task Pending (Termasuk Rejected yang revert ke Pending) membutuhkan aksi PIC
                  final pendingCount = tasksInArea
                      .where((r) {
                        final tag = _getPicStatusTag(r);
                        return tag == 'Pending' || tag == 'Pending Rejected';
                      })
                      .length;
                    
                  // 2. Task Follow Up Done yang sedang menunggu respon/approval Petugas
                  final waitingCount = tasksInArea
                      .where((r) => _getPicStatusTag(r) == 'Follow Up Done')
                      .length;
                    
                  final totalTasks = tasksInArea.length;

                  debugPrint(
                    '[PicHomeScreen] area=${area.name} total=$totalTasks pending=$pendingCount waiting=$waitingCount',
                  );

                  return AreaCard(
                    key: ValueKey(
                      '${area.id}-$pendingCount-$waitingCount-$totalTasks',
                    ),
                    areaName: area.name,
                    pendingCount: pendingCount,
                    waitingResponseCount: waitingCount, // Pass data waiting
                    totalTasks: totalTasks, 
                    index: index, 
                    onTap: () {
                      ref.read(activeAreaFilterProvider.notifier).state = area.name;
                      context.pushNamed(RouteNames.picFinding);
                    },
                  );
                },
                childCount: areas.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  String _canonicalStatus(dynamic raw) {
    final value = raw?.toString().trim().toLowerCase() ?? '';
    return value.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String _getActualStatus(Map<String, dynamic> report) {
    final followUps = report['followUps'] as List<dynamic>? ??
        report['follow_ups'] as List<dynamic>? ??
        [];

    if (followUps.isNotEmpty) {
      final lastFollowUp = followUps.last as Map<String, dynamic>;
      final lastStatus = _canonicalStatus(lastFollowUp['status']);
      if (lastStatus == 'rejected') {
        return 'Pending Rejected';
      }
    }

    final rawStatus = report['status'];
    final status = _canonicalStatus(rawStatus);
    if (status == 'pending') return 'Pending';
    if (status == 'followupdone' || status == 'followedup' || status == 'followup') {
      return 'Follow Up Done';
    }
    if (status == 'completed' || status == 'approved' || status == 'done') {
      return 'Completed';
    }
    if (status == 'canceled' || status == 'cancelled') {
      return 'Canceled';
    }

    return report['status']?.toString() ?? 'Pending';
  }

  String _getPicStatusTag(Map<String, dynamic> report) {
    final actualStatus = _getActualStatus(report);
    final normalized = _canonicalStatus(actualStatus);

    if (normalized == 'pendingrejected') return 'Pending Rejected';
    if (normalized == 'completed' || normalized == 'approved') return 'Approved';
    if (normalized == 'followupdone' || normalized == 'followedup' || normalized == 'followup') {
      return 'Follow Up Done';
    }
    if (normalized == 'pending') return 'Pending';
    if (normalized == 'canceled' || normalized == 'cancelled') return 'Canceled';

    return actualStatus;
  }
}
