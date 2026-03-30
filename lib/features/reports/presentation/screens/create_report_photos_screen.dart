import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../app/router/route_names.dart';
import '../providers/create_report_form_provider.dart';

class CreateReportPhotosScreen extends ConsumerStatefulWidget {
  const CreateReportPhotosScreen({super.key});

  @override
  ConsumerState<CreateReportPhotosScreen> createState() => _CreateReportPhotosScreenState();
}

class _CreateReportPhotosScreenState extends ConsumerState<CreateReportPhotosScreen> {
  bool _isProcessing = false;

  Future<void> _takePhoto(int index) async {
    final draft = ref.read(createReportFormProvider);
    final hasPhoto = index < draft.photos.length;
    
    if (hasPhoto) return; // Prevent overwriting existing slot

    final picker = ImagePicker();
    // Dipaksa hanya menggunakan kamera asli:
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    
    if (photo == null) return;

    if (mounted) setState(() => _isProcessing = true);
    
    // Simpan foto ke provider
    ref.read(createReportFormProvider.notifier).addPhoto(photo.path);
    
    // Terapkan ML Kit Text Recognition
    try {
      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      final String extractedText = recognizedText.text.trim();
      
      if (extractedText.isNotEmpty) {
        final currentNotes = ref.read(createReportFormProvider).notes ?? '';
        final newNotes = currentNotes.isEmpty 
            ? extractedText 
            : '$currentNotes\n\n[Auto-Deteksi Teks ML Kit]:\n$extractedText';
            
        ref.read(createReportFormProvider.notifier).setNotes(newNotes);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Teks pada foto berhasil dideteksi dan dimasukkan ke Catatan!'),
              backgroundColor: AppColors.statusApproved,
            ),
          );
        }
      }
      
      textRecognizer.close();
    } catch (e) {
      debugPrint('ML Kit Text Recognition Error: $e');
    }
    
    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(createReportFormProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Foto Temuan')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    'Langkah 4 dari 7',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                Text(
                  'Ambil Foto Bukti',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Minimal 1 foto wajib diambil langsung dari kamera untuk bukti riil. Jika terdapat tulisan pada foto, sistem akan mengekstrak otomatis.',
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
                        text: 'Kembali',
                        type: AppButtonType.outlined,
                        onPressed: _isProcessing ? null : () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppButton(
                        text: 'Lanjutkan',
                        onPressed: draft.photos.isNotEmpty && !_isProcessing
                            ? () => context.pushNamed(RouteNames.petugasCreateReportNotes)
                            : null,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoSlot(CreateReportDraft draft, int index) {
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
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(draft.photos[index]), 
                  fit: BoxFit.cover,
                ),
              )
            : const HugeIcon(
                icon: HugeIcons.strokeRoundedCameraAdd01,
                color: AppColors.textHint,
                size: 36,
              ),
      ),
    );
  }
}
