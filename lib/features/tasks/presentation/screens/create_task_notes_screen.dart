import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../app/router/route_names.dart';
import '../providers/create_task_form_provider.dart';

class CreateTaskNotesScreen extends ConsumerStatefulWidget {
  const CreateTaskNotesScreen({super.key});

  @override
  ConsumerState<CreateTaskNotesScreen> createState() => _CreateTaskNotesScreenState();
}

class _CreateTaskNotesScreenState extends ConsumerState<CreateTaskNotesScreen> {
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ambil notes dari provider
    final rawNotes = ref.read(createTaskFormProvider).notes;

    // Filter Sanitasi: Cegah teks random / log error masuk ke textfield
    if (rawNotes != null && rawNotes.isNotEmpty) {
      final isGarbageData = rawNotes.contains('.dart') || 
                            rawNotes.contains('Exception') || 
                            rawNotes.contains('lib\\') ||
                            rawNotes.contains('datasource') ||
                            rawNotes.contains('MXtask');
                            
      if (isGarbageData) {
        _notesController.text = ''; // Kosongkan jika terdeteksi teks random
      } else {
        _notesController.text = rawNotes; // Tampilkan jika teks normal dari user
      }
    } else {
      _notesController.text = '';
    }
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
                        ref.read(createTaskFormProvider.notifier).setNotes(_notesController.text.trim());
                        context.pushNamed(RouteNames.petugasCreateTaskRootCause);
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