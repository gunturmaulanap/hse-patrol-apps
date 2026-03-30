import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../widgets/area_card.dart';
import '../../../../core/mock_api/mock_database.dart';
import '../providers/active_area_filter_provider.dart';

class PicHomeScreen extends ConsumerWidget {
  const PicHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final db = ref.watch(mockDatabaseProvider);

    final areaList = user?.areaAccess ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home PIC'),
        actions: [
          IconButton(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedNotification01,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${user?.username.toUpperCase() ?? "PIC"}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Berikut adalah daftar area di bawah pengawasan Anda.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (areaList.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.md), child: Text('Belum ada area ditugaskan.')))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.9,
                ),
                itemCount: areaList.length,
                itemBuilder: (context, index) {
                  final areaName = areaList[index];
                  
                  // Hitung temuan yang butuh aksi PIC (Pending dan Rejected)
                  final pendingCount = db.reports.where(
                    (r) => r['area'] == areaName && (r['status'] == 'Pending' || r['status'] == 'Rejected')
                  ).length;
                  
                  return AreaCard(
                    title: areaName,
                    subtitle: 'Pemantauan Aktif',
                    count: pendingCount,
                    onTap: () {
                      // Set filter state
                      ref.read(activeAreaFilterProvider.notifier).state = areaName;
                      // Move to second tab branch
                      StatefulNavigationShell.of(context).goBranch(1);
                    },
                  );
                },
              ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
