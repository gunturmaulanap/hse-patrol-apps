import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/mock_api/mock_database.dart';
import '../providers/create_task_form_provider.dart';

class CreateTaskReviewScreen extends ConsumerStatefulWidget {
  const CreateTaskReviewScreen({super.key});

  @override
  ConsumerState<CreateTaskReviewScreen> createState() => _CreateTaskReviewScreenState();
}

class _CreateTaskReviewScreenState extends ConsumerState<CreateTaskReviewScreen> {
  bool _isSubmitting = false;

  void _goToHomeByRole(BuildContext context) {
    final user = ref.read(currentUserProvider);
    final role = user?.role;

    if (role == 'supervisor') {
      context.goNamed(RouteNames.supervisorHome);
    } else if (role == 'pic') {
      context.goNamed(RouteNames.picHome);
    } else {
      context.goNamed(RouteNames.petugasHome);
    }
  }

  void _submitData() async {
    final draft = ref.read(createTaskFormProvider);

    if (draft.buildingType == null || draft.area == null || draft.riskLevel == null ||
        draft.photos.isEmpty || draft.notes == null || draft.rootCause == null) {
      // (Validasi Form seperti biasa)
      AppSnackBar.warning(context, message: 'Harap lengkapi semua data laporan.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final createdTask = await ref.read(createTaskFormProvider.notifier).submitTask();

      if (createdTask != null && createdTask is! bool && mounted) {
        
        // 1. Ambil URL FOTO ONLINE dari backend (Bukan dari path memori lokal)
        // URL ini harus disisipkan di teks agar WhatsApp bisa membuat Thumbnail Image Preview
        String onlinePhotoUrl = '';
        if (createdTask.photos != null && createdTask.photos!.isNotEmpty) {
          onlinePhotoUrl = createdTask.photos!.first;
        }

        // 2. Format WA Text: Letakkan foto online di atas agar dibaca WA bot
        final waText = '''🚨 *LAPORAN TEMUAN HSE BARU* 🚨
${onlinePhotoUrl.isNotEmpty ? '\n🖼️ *Preview Foto:*\n$onlinePhotoUrl\n' : ''}
📍 *Area:* ${draft.area}
🏢 *Bangunan:* ${draft.buildingType}
⚠️ *Tingkat Risiko:* Level ${draft.riskLevel}
📝 *Akar Masalah:* ${draft.rootCause}
💬 *Keterangan:* ${draft.notes}

Untuk proses tindak lanjut, silakan klik link khusus (Deep Link) berikut untuk membuka aplikasi:
🔗 ${createdTask.picToken ?? 'Link belum tersedia'}''';

        if (!mounted) return;
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Laporan Terkirim!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (draft.photos.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(draft.photos.first),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Laporan patroli berhasil dikirim ke server. Silakan bagikan ke WhatsApp PIC terkait.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Bagikan',
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedShare01,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: () async {
                        final encodedText = Uri.encodeComponent(waText);
                        final url = Uri.parse("https://wa.me/?text=$encodedText");

                        // 3. Eksekusi peluncuran WhatsApp terlebih dahulu
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                        
                        // 4. Delay sebentar agar WhatsApp menimpa layar sepenuhnya, 
                        // lalu baru redirect ke Home di background (mencegah glitch visual)
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted && ctx.mounted) {
                            ctx.pop(); // Tutup pop-up
                            _goToHomeByRole(context); // Redirect background
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppButton(
                      text: 'Selesai',
                      type: AppButtonType.outlined,
                      onPressed: () {
                        ctx.pop();
                        _goToHomeByRole(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Error handling...
      setState(() => _isSubmitting = false);
    }
  }

  // (Kode build dan _buildRow sisanya tidak diubah, tetap biarkan bawaannya)
  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(createTaskFormProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Review Laporan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'Langkah 7 dari 7',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tinjauan Laporan', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(height: 32),
                  _buildRow('Jenis Bangunan', draft.buildingType ?? '-'),
                  _buildRow('Lokasi Area', draft.area ?? '-'),
                  _buildRow('Tingkat Risiko', draft.riskLevel ?? '-'),
                  _buildRow('Total Foto', '${draft.photos.length} Foto'),
                  _buildRow('Keterangan', draft.notes ?? '-'),
                  _buildRow('Akar Masalah', draft.rootCause ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              text: 'Kirim Laporan',
              isLoading: _isSubmitting,
              onPressed: _submitData,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              text: 'Kembali Edit',
              type: AppButtonType.outlined,
              onPressed: _isSubmitting ? null : () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}