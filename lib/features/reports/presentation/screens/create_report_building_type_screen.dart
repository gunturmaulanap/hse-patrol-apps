import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../app/router/route_names.dart';
import '../providers/create_report_form_provider.dart';

class CreateReportBuildingTypeScreen extends ConsumerWidget {
  const CreateReportBuildingTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(createReportFormProvider);

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
              'Pilih Jenis Fasilitas/Bangunan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: _BuildingTypeCard(
                icon: HugeIcons.strokeRoundedFactory,
                title: 'Fasilitas Produksi',
                description: 'Area pabrik, gudang bahan baku, dll',
                isSelected: form.buildingType == 'Fasilitas Produksi',
                onTap: () {
                  ref.read(createReportFormProvider.notifier).setBuildingType('Fasilitas Produksi');
                  context.pushNamed(RouteNames.petugasCreateReportLocation);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _BuildingTypeCard(
                icon: HugeIcons.strokeRoundedTree02,
                title: 'Fasilitas Non-Produksi',
                description: 'Kantor umum, area parkir, kantin, dll',
                isSelected: form.buildingType == 'Fasilitas Non-Produksi',
                onTap: () {
                  ref.read(createReportFormProvider.notifier).setBuildingType('Fasilitas Non-Produksi');
                  context.pushNamed(RouteNames.petugasCreateReportLocation);
                },
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
            color: isSelected ? AppColors.secondary : Colors.white.withOpacity(0.05),
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
                          ? AppColors.textInverted.withOpacity(0.8)
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
