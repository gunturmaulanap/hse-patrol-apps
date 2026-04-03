import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hugeicons/hugeicons.dart';
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
    // PERBAIKAN: Kompresi gambar agar tidak ditolak oleh server (PHP upload max limit)
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 60, // Kompresi kualitas menjadi 60%
      maxWidth: 1200,   // Batasi resolusi maksimal 1200px
      maxHeight: 1200,  // Batasi resolusi maksimal 1200px
    );

    if (photo == null) return;

    if (mounted) setState(() => _isProcessing = true);

    ref.read(picFollowUpFormProvider.notifier).addPhoto(photo.path);

    // Terapkan ML Kit Text Recognition
    try {
      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      final String extractedText = recognizedText.text.trim();

      if (extractedText.isNotEmpty) {
        final currentNotes = ref.read(picFollowUpFormProvider).notes ?? '';
        final newNotes = currentNotes.isEmpty
            ? extractedText
            : '$currentNotes\n\n[Auto-Deteksi Teks ML Kit]:\n$extractedText';

        ref.read(picFollowUpFormProvider.notifier).setNotes(newNotes);
      }

      textRecognizer.close();
    } catch (e) {
      debugPrint('ML Kit Text Recognition Error: $e');
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _retakePhoto(int index) async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (photo == null) return;

    if (mounted) setState(() => _isProcessing = true);

    // Hapus foto lama dan tambahkan foto baru di index yang sama
    ref.read(picFollowUpFormProvider.notifier).removePhoto(index);
    ref.read(picFollowUpFormProvider.notifier).addPhoto(photo.path);

    // Terapkan ML Kit Text Recognition
    try {
      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      final String extractedText = recognizedText.text.trim();

      if (extractedText.isNotEmpty) {
        final currentNotes = ref.read(picFollowUpFormProvider).notes ?? '';
        final newNotes = currentNotes.isEmpty
            ? extractedText
            : '$currentNotes\n\n[Auto-Deteksi Teks ML Kit]:\n$extractedText';

        ref.read(picFollowUpFormProvider.notifier).setNotes(newNotes);
      }

      textRecognizer.close();
    } catch (e) {
      debugPrint('ML Kit Text Recognition Error: $e');
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  void _removePhoto(int index) {
    ref.read(picFollowUpFormProvider.notifier).removePhoto(index);
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
                  'Ambil Foto Perbaikan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Minimal 1 foto wajib diambil langsung dari kamera untuk bukti riil. Jika terdapat tulisan pada foto, sistem akan mengekstrak otomatis.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),

                // 3 kolom horizontal - Layout asli dengan simple container
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
      onTap: () => hasPhoto ? _retakePhoto(index) : _takePhoto(index),
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!hasPhoto)
              const Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCameraAdd01,
                  color: AppColors.textHint,
                  size: 36,
                ),
              )
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(draft.photos[index]),
                  fit: BoxFit.cover,
                ),
              ),
            // Tombol delete jika ada foto
            if (hasPhoto)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removePhoto(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
