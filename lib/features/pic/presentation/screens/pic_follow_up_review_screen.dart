import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../app/router/route_names.dart';
import '../providers/pic_follow_up_provider.dart';
import '../../../../core/mock_api/mock_database.dart';

class PicFollowUpReviewScreen extends ConsumerStatefulWidget {
  const PicFollowUpReviewScreen({super.key});

  @override
  ConsumerState<PicFollowUpReviewScreen> createState() => _PicFollowUpReviewScreenState();
}

class _PicFollowUpReviewScreenState extends ConsumerState<PicFollowUpReviewScreen> {
  bool _isSaving = false;

  void _submitFollowUp() async {
    setState(() => _isSaving = true);
    
    // Simulate loading
    await Future.delayed(const Duration(seconds: 2));

    final draft = ref.read(picFollowUpFormProvider);
    final db = ref.read(mockDatabaseProvider);

    if (draft.reportId != null) {
      db.updateReportStatus(
        draft.reportId!, 
        'Follow Up Done', 
        picNotes: draft.notes,
        picPhotos: draft.photos,
      );
    }
    
    if (mounted) {
      setState(() => _isSaving = false);
      
      // Clear draft
      ref.read(picFollowUpFormProvider.notifier).reset();

      // Return to PIC Home explicitly (popping off the wizard + detail screen)
      context.goNamed(RouteNames.picHome);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tindak Lanjut Anda berhasil disubmit untuk direview oleh Petugas.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(picFollowUpFormProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Review (PIC)')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text('Langkah 3 dari 3', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
                ),
                Text(
                  'Review Tindak Lanjut',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Pastikan foto dan catatan sudah benar sebelum diserahkan kembali kepada Petugas Patroli.', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xl),
                
                // Content Recap
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Foto Bukti Perbaikan:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.sm),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: draft.photos.map((p) => 
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(File(p), width: 100, height: 100, fit: BoxFit.cover),
                                ),
                              )
                            ).toList(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text('Catatan Perbaikan:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(draft.notes ?? '-'),
                        ),
                      ],
                    ),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Kembali',
                        type: AppButtonType.outlined,
                        onPressed: _isSaving ? null : () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton(
                        text: 'Submit Follow Up',
                        onPressed: _isSaving ? null : _submitFollowUp,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          if (_isSaving) Container(color: Colors.black.withValues(alpha: 0.3), child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}
