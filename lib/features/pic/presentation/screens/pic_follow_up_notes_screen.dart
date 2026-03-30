import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../app/router/route_names.dart';
import '../providers/pic_follow_up_provider.dart';

class PicFollowUpNotesScreen extends ConsumerStatefulWidget {
  const PicFollowUpNotesScreen({super.key});

  @override
  ConsumerState<PicFollowUpNotesScreen> createState() => _PicFollowUpNotesScreenState();
}

class _PicFollowUpNotesScreenState extends ConsumerState<PicFollowUpNotesScreen> {
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesController.text = ref.read(picFollowUpFormProvider).notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Perbaikan (PIC)')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text('Langkah 2 dari 3', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
            ),
            Text(
              'Input Catatan Tindakan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Jelaskan secara detail tindakan apa yang telah dilakukan untuk menyelesaikan temuan.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            
            AppTextField(
              label: 'Keterangan Perbaikan',
              hint: 'Ketikan kronologi atau material yang diperbaiki...',
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
                    onPressed: () {
                      ref.read(picFollowUpFormProvider.notifier).setNotes(_notesController.text);
                      context.pop();
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    text: 'Lanjutkan',
                    onPressed: () {
                      if (_notesController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catatan tidak boleh kosong!')));
                        return;
                      }
                      ref.read(picFollowUpFormProvider.notifier).setNotes(_notesController.text.trim());
                      context.pushNamed(RouteNames.picFollowUpReview);
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
