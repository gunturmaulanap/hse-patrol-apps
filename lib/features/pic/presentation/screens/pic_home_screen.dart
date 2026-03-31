import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/mock_api/mock_database.dart';
import '../providers/active_area_filter_provider.dart';
import '../widgets/area_card.dart';

class PicHomeScreen extends ConsumerWidget {
  const PicHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final db = ref.watch(mockDatabaseProvider);

    // Ambil daftar area yang bisa diakses oleh PIC
    final areas = user?.areaAccess ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
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
                      color: AppColors.textSecondary.withOpacity(0.8),
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
                  final tasksInArea = db.reports.where((r) => r['area'] == area).toList();
                  
                  // 1. Task Pending (Termasuk Rejected yang revert ke Pending) membutuhkan aksi PIC
                  final pendingCount = tasksInArea.where((r) => r['status'] == 'Pending').length;
                  
                  // 2. Task Follow Up Done yang sedang menunggu respon/approval Petugas
                  final waitingCount = tasksInArea.where((r) => r['status'] == 'Follow Up Done').length;
                  
                  final totalTasks = tasksInArea.where((r) => r['status'] != 'Canceled').length; // Abaikan yang dicancel petugas

                  return AreaCard(
                    areaName: area,
                    pendingCount: pendingCount,
                    waitingResponseCount: waitingCount, // Pass data waiting
                    totalTasks: totalTasks, 
                    index: index, 
                    onTap: () {
                      ref.read(activeAreaFilterProvider.notifier).state = area;
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
    );
  }
}