import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/router/route_names.dart';
import '../../../areas/presentation/providers/area_provider.dart';
import '../providers/create_task_form_provider.dart';

class CreateTaskBuildingTypeScreen extends ConsumerStatefulWidget {
  const CreateTaskBuildingTypeScreen({super.key});

  @override
  ConsumerState<CreateTaskBuildingTypeScreen> createState() => _CreateTaskBuildingTypeScreenState();
}

class _CreateTaskBuildingTypeScreenState extends ConsumerState<CreateTaskBuildingTypeScreen> {
  bool _hasReset = false;

  @override
  Widget build(BuildContext context) {
    // Reset form state saat pertama kali membuka screen
    if (!_hasReset) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(createTaskFormProvider.notifier).reset();
        debugPrint('[CreateTaskBuildingTypeScreen] Form state reset');
      });
      _hasReset = true;
    }

    final form = ref.watch(createTaskFormProvider);
    final buildingTypesAsync = ref.watch(buildingTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Area Inspeksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'Langkah 1 dari 7',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Text(
              'Pilih Jenis Bangunan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                'ℹ️ Informasi: Pilihan jenis bangunan diambil dari server dan akan digunakan untuk memfilter daftar area pada langkah berikutnya.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: buildingTypesAsync.when(
                data: (types) {
                  if (types.isEmpty) {
                    return const Center(
                      child: Text('Jenis bangunan belum tersedia.'),
                    );
                  }

                  return ListView.separated(
                    itemCount: types.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final type = types[index];
                      final isAtas = type.toLowerCase().contains('atas');

                      return AppCard(
                        child: _BuildingTypeCard(
                          icon: isAtas
                              ? HugeIcons.strokeRoundedBuilding03
                              : HugeIcons.strokeRoundedBuilding04,
                          title: type,
                          description: isAtas
                              ? 'Fasilitas atau bangunan yang berlokasi di area atas.'
                              : 'Fasilitas atau bangunan yang berlokasi di area bawah.',
                          isSelected: form.buildingType == type,
                          onTap: () {
                            ref.read(createTaskFormProvider.notifier).setBuildingType(type);
                            context.pushNamed(RouteNames.petugasCreateTaskLocation);
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text('Gagal memuat jenis bangunan: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildingTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _BuildingTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: isSelected ? AppColors.secondary : Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(
                icon: icon,
                size: 64,
                color: isSelected ? AppColors.textInverted : AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isSelected ? AppColors.textInverted : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? AppColors.textInverted.withValues(alpha: 0.8)
                          : AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
