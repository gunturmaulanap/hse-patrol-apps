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
    // Validasi data sebelum submit
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
            content: const Text(
              'Mohon lengkapi semua data sebelum mengirim laporan:\n'
              '• Jenis Bangunan\n'
              '• Lokasi Area\n'
              '• Tingkat Risiko\n'
              '• Minimal 1 Foto\n'
              '• Keterangan\n'
              '• Akar Masalah',
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

    setState(() => _isSubmitting = true);

    try {
      final success = await ref.read(createTaskFormProvider.notifier).submitTask();

      if (success && mounted) {
        // Form sudah di-reset di provider setelah submit berhasil

        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Berhasil!'),
              ],
            ),
            content: const Text('Laporan Patroli berhasil dikirim.'),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              AppButton(
                text: 'Bagikan via WhatsApp',
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedShare01,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () async {
                  final url = Uri.parse("whatsapp://send?text=Laporan Patroli Baru telah dibuat di aplikasi HSE Aksamala.");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                  if (!mounted || !ctx.mounted) return;
                  ctx.pop();
                  _goToHomeByRole(context);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                text: 'Selesai',
                type: AppButtonType.outlined,
                onPressed: () {
                  ctx.pop();
                  _goToHomeByRole(context);
                },
              ),
            ],
          ),
        );
      } else {
        // Submit gagal
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Gagal Mengirim'),
                ],
              ),
              content: const Text(
                'Laporan gagal dikirim. Silakan periksa koneksi internet dan coba lagi. '
                'Jika masalah berlanjut, hubungi administrator.',
              ),
              actions: [
                TextButton(
                  onPressed: () => ctx.pop(),
                  child: const Text('OK', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      // Exception tidak tertangkap di provider
      debugPrint('[CreateTaskReviewScreen] Submit error: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Terjadi Kesalahan'),
              ],
            ),
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => ctx.pop(),
                child: const Text('OK', style: TextStyle(color: Colors.red)),
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
