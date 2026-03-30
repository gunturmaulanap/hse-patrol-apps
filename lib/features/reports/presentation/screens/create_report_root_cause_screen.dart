import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../app/router/route_names.dart';
import '../providers/create_report_form_provider.dart';

class CreateReportRootCauseScreen extends ConsumerStatefulWidget {
  const CreateReportRootCauseScreen({super.key});

  @override
  ConsumerState<CreateReportRootCauseScreen> createState() => _CreateReportRootCauseScreenState();
}

class _CreateReportRootCauseScreenState extends ConsumerState<CreateReportRootCauseScreen> {
  final _rootCauseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rootCauseController.text = ref.read(createReportFormProvider).rootCause ?? '';
  }

  @override
  void dispose() {
    _rootCauseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akar Masalah')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'Langkah 6 dari 7',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Text(
              'Analisa Akar Masalah',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Menurut Anda, mengapa hal ini terjadi?',
              hint: 'Contoh: Pekerja shift malam lupa mengunci gudang...',
              controller: _rootCauseController,
              maxLines: 4,
            ),
            
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Kembali',
                    type: AppButtonType.outlined,
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    text: 'Review',
                    onPressed: () {
                      if (_rootCauseController.text.trim().isNotEmpty) {
                        ref.read(createReportFormProvider.notifier).setRootCause(_rootCauseController.text.trim());
                        context.pushNamed(RouteNames.petugasCreateReportReview);
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
