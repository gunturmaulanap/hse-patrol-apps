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

class CreateReportRiskLevelScreen extends ConsumerWidget {
  const CreateReportRiskLevelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(createReportFormProvider);

    void selectRisk(String riskName) {
      ref.read(createReportFormProvider.notifier).setRiskLevel(riskName);
      context.pushNamed(RouteNames.petugasCreateReportPhotos);
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
                    title: 'Kritis (1)',
                    color: AppColors.riskCritical,
                    isSelected: form.riskLevel == 'Kritis',
                    onTap: () => selectRisk('Kritis'),
                  ),
                  _RiskCard(
                    title: 'Berat (2)',
                    color: AppColors.riskHigh,
                    isSelected: form.riskLevel == 'Berat',
                    onTap: () => selectRisk('Berat'),
                  ),
                  _RiskCard(
                    title: 'Sedang (3)',
                    color: AppColors.riskMedium,
                    isSelected: form.riskLevel == 'Sedang',
                    onTap: () => selectRisk('Sedang'),
                  ),
                  _RiskCard(
                    title: 'Ringan (4)',
                    color: AppColors.riskLow,
                    isSelected: form.riskLevel == 'Ringan',
                    onTap: () => selectRisk('Ringan'),
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

  const _RiskCard({
    required this.title,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedDanger,
                size: 48,
                color: isSelected ? AppColors.textInverted : color,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected ? AppColors.textInverted : color,
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
