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
      return;
    }

    if (role == 'pic') {
      context.goNamed(RouteNames.picHome);
      return;
    }

    context.goNamed(RouteNames.petugasHome);
  }

  void _submitData() async {
    final draft = ref.read(createTaskFormProvider);

    if (draft.buildingType == null ||
        draft.buildingType!.isEmpty ||
        draft.area == null ||
        draft.area!.isEmpty ||
        draft.riskLevel == null ||
        draft.riskLevel!.isEmpty ||
        draft.photos.isEmpty ||
        draft.notes == null ||
        draft.notes!.isEmpty ||
        draft.rootCause == null ||
        draft.rootCause!.isEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('Data Belum Lengkap'),
              ],
            ),
            content: Text(
              'Mohon lengkapi semua data sebelum mengirim laporan:\n'
              '• Jenis Bangunan: ${draft.buildingType ?? "BELUM DIPILIH"}\n'
              '• Lokasi Area: ${draft.area ?? "BELUM DIPILIH"}\n'
              '• Area ID: ${draft.areaId ?? "NULL"}\n'
              '• Tingkat Risiko: ${draft.riskLevel ?? "BELUM DIPILIH"}\n'
              '• Foto: ${draft.photos.length} foto (minimal 1)\n'
              '• Keterangan: ${(draft.notes?.isEmpty ?? true) ? "BELUM DIISI" : draft.notes}\n'
              '• Akar Masalah: ${(draft.rootCause?.isEmpty ?? true) ? "BELUM DIISI" : draft.rootCause}',
            ),
            actions: [
              TextButton(
                onPressed: () => ctx.pop(),
                child: const Text('OK', style: TextStyle(color: Colors.orange)),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (draft.areaId == null) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Error: Area ID Null'),
              ],
            ),
            content: Text('Area ID belum diset. Silakan pilih area kembali.\nArea: ${draft.area}\nArea ID: ${draft.areaId}'),
            actions: [
              TextButton(
                onPressed: () => ctx.pop(),
                child: const Text('OK', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // createdTask sekarang akan berisi data HseTaskModel (karena Provider sudah diedit)
      final createdTask = await ref.read(createTaskFormProvider.notifier).submitTask();

      // Pastikan response tidak null dan bukan boolean (hanya untuk pengaman)
      if (createdTask != null && createdTask is! bool && mounted) {
        
        // Buat format pesan WhatsApp
        final waText = '''🚨 *LAPORAN TEMUAN HSE BARU* 🚨

📍 *Area:* ${draft.area}
🏢 *Bangunan:* ${draft.buildingType}
⚠️ *Tingkat Risiko:* Level ${draft.riskLevel}
📝 *Akar Masalah:* ${draft.rootCause}
💬 *Keterangan:* ${draft.notes}

Terdapat temuan HSE di area Anda. Klik link di bawah ini untuk melihat detail foto dan melakukan *Follow Up*:
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
                Text('Berhasil!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // === POPUP IMAGE PERTAMA DITAMPILKAN DI SINI ===
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
                        // Ubah teks menjadi format URL yang valid
                        final encodedText = Uri.encodeComponent(waText);
                        final url = Uri.parse("whatsapp://send?text=$encodedText");

                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          debugPrint('Aplikasi WhatsApp tidak ditemukan.');
                        }
                        if (!mounted || !ctx.mounted) return;
                        ctx.pop();
                        _goToHomeByRole(context);
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
      String errorMessage = 'Terjadi kesalahan:\n\n${e.toString()}\n\n';

      if (e.toString().contains('Title cannot be empty')) {
        errorMessage += '💡 Solusi: Pastikan title terisi dengan benar.';
      } else if (e.toString().contains('area_id tidak valid')) {
        errorMessage += '💡 Solusi: Pilih area terlebih dahulu di langkah 2.';
      } else if (e.toString().contains('Risk level tidak boleh kosong')) {
        errorMessage += '💡 Solusi: Pilih tingkat risiko di langkah 3.';
      } else if (e.toString().contains('Root cause tidak boleh kosong')) {
        errorMessage += '💡 Solusi: Isi akar masalah di langkah 6.';
      } else if (e.toString().contains('Notes tidak boleh kosong')) {
        errorMessage += '💡 Solusi: Isi keterangan di langkah 5.';
      } else if (e.toString().contains('Invalid risk_level')) {
        errorMessage += '💡 Solusi: Pilih ulang tingkat risiko (1-4).';
      } else if (e.toString().contains('422')) {
        errorMessage += '💡 Validasi backend gagal. Cek:\n• Area sudah dipilih?\n• Foto sudah diambil?\n• Semua form terisi?';
      } else if (e.toString().contains('DioException')) {
        errorMessage += '💡 Koneksi error. Periksa internet Anda.';
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Submit Gagal'),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(errorMessage),
            ),
            actions: [
              TextButton(
                onPressed: () => ctx.pop(),
                child: const Text('OK', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

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