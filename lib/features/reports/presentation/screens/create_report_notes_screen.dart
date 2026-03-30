import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../app/router/route_names.dart';
import '../providers/create_report_form_provider.dart';

class CreateReportNotesScreen extends ConsumerStatefulWidget {
  const CreateReportNotesScreen({super.key});

  @override
  ConsumerState<CreateReportNotesScreen> createState() => _CreateReportNotesScreenState();
}

class _CreateReportNotesScreenState extends ConsumerState<CreateReportNotesScreen> {
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesController.text = ref.read(createReportFormProvider).notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keterangan Photo')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'Langkah 5 dari 7',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Text(
              'Deskripsikan Temuan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Catatan / Deskripsi',
              hint: 'Jelaskan apa yang Anda lihat dengan detail...',
              controller: _notesController,
              maxLines: 5,
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
                    text: 'Lanjutkan',
                    onPressed: () {
                      if (_notesController.text.trim().isNotEmpty) {
                        ref.read(createReportFormProvider.notifier).setNotes(_notesController.text.trim());
                        context.pushNamed(RouteNames.petugasCreateReportRootCause);
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
