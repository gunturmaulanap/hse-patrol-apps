import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../app/router/route_names.dart';
import '../providers/pic_follow_up_provider.dart';

class PicFollowUpPhotosScreen extends ConsumerStatefulWidget {
  const PicFollowUpPhotosScreen({super.key});

  @override
  ConsumerState<PicFollowUpPhotosScreen> createState() => _PicFollowUpPhotosScreenState();
}

class _PicFollowUpPhotosScreenState extends ConsumerState<PicFollowUpPhotosScreen> {
  bool _isProcessing = false;

  Future<void> _takePhoto(int index) async {
    final draft = ref.read(picFollowUpFormProvider);
    final hasPhoto = index < draft.photos.length;
    
    if (hasPhoto) return; 

    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    
    if (photo == null) return;

    if (mounted) setState(() => _isProcessing = true);
    
    ref.read(picFollowUpFormProvider.notifier).addPhoto(photo.path);
    
    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(picFollowUpFormProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Foto Perbaikan (PIC)')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text('Langkah 1 dari 3', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
                ),
                Text(
                  'Ambil Foto Tindak Lanjut',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Wajib melampirkan minimal 1 foto langsung dari kamera untuk membuktikan bahwa perbaikan telah dilakukan di lapangan.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPhotoSlot(draft, 0),
                    _buildPhotoSlot(draft, 1),
                    _buildPhotoSlot(draft, 2),
                  ],
                ),
                
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Batal',
                        type: AppButtonType.outlined,
                        onPressed: _isProcessing ? null : () {
                          ref.read(picFollowUpFormProvider.notifier).reset();
                          context.pop();
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton(
                        text: 'Lanjutkan',
                        onPressed: draft.photos.isNotEmpty && !_isProcessing
                            ? () => context.pushNamed(RouteNames.picFollowUpNotes)
                            : null,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          if (_isProcessing) Container(color: Colors.black.withValues(alpha: 0.3), child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _buildPhotoSlot(PicFollowUpDraft draft, int index) {
    final hasPhoto = index < draft.photos.length;

    return GestureDetector(
      onTap: () => _takePhoto(index),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: hasPhoto ? AppColors.primaryLight.withValues(alpha: 0.3) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasPhoto ? AppColors.primary : AppColors.border,
            width: 2,
            style: hasPhoto ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: hasPhoto
            ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(draft.photos[index]), fit: BoxFit.cover))
            : const Icon(Icons.add_a_photo, color: AppColors.textHint, size: 36),
      ),
    );
  }
}
