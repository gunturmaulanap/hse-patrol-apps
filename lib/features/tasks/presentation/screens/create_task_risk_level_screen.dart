import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/router/route_names.dart';
import '../providers/create_task_form_provider.dart';

class CreateTaskRiskLevelScreen extends ConsumerWidget {
  const CreateTaskRiskLevelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(createTaskFormProvider);

    void selectRisk(int riskLevel) {
      ref.read(createTaskFormProvider.notifier).setRiskLevel(riskLevel.toString());
      context.pushNamed(RouteNames.petugasCreateTaskPhotos);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tingkat Risiko')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'Langkah 3 dari 7',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Text(
              'Pilih Tingkat Risiko',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Seberapa bahaya temuan ini terhadap keselamatan kerja?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                children: [
                  _RiskCard(
                    title: 'Kurang dari 2 Jam',
                    color: AppColors.riskLevel4, // Merah
                    icon: HugeIcons.strokeRoundedTimer01,
                    isSelected: form.riskLevel == '1',
                    onTap: () => selectRisk(1),
                  ),
                  _RiskCard(
                    title: 'Kurang dari 24 Jam',
                    color: AppColors.riskLevel3, // Orange
                    icon: HugeIcons.strokeRoundedTime01,
                    isSelected: form.riskLevel == '2',
                    onTap: () => selectRisk(2),
                  ),
                  _RiskCard(
                    title: 'Kurang dari 3 Hari',
                    color: AppColors.riskLevel2, // Kuning
                    icon: HugeIcons.strokeRoundedCalendar03,
                    isSelected: form.riskLevel == '3',
                    onTap: () => selectRisk(3),
                  ),
                  _RiskCard(
                    title: 'Kurang dari 2 Minggu',
                    color: AppColors.riskLevel1, // Biru
                    icon: HugeIcons.strokeRoundedCalendar03,
                    isSelected: form.riskLevel == '4',
                    onTap: () => selectRisk(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  final String title;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  const _RiskCard({
    required this.title,
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isLightColor = color == AppColors.riskLevel2; // Kuning perlu text gelap

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              HugeIcon(
                icon: icon,
                size: 36,
                color: isSelected
                    ? (isLightColor ? Colors.black87 : AppColors.textInverted)
                    : color,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isSelected
                          ? (isLightColor ? Colors.black87 : AppColors.textInverted)
                          : color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
