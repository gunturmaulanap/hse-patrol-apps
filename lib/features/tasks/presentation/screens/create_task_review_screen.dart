import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/share_helper.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/create_task_form_provider.dart';

class CreateTaskReviewScreen extends ConsumerStatefulWidget {
  const CreateTaskReviewScreen({super.key});

  @override
  ConsumerState<CreateTaskReviewScreen> createState() => _CreateTaskReviewScreenState();
}

class _CreateTaskReviewScreenState extends ConsumerState<CreateTaskReviewScreen> {
  bool _isSubmitting = false;

  String _locationTypeLabel(String? buildingType) {
    final value = (buildingType ?? '').toLowerCase().trim();
    if (value.isEmpty) return '-';
    if (value.contains('non') && value.contains('produksi')) return 'Non Produksi';
    if (value.contains('produksi')) return 'Produksi';
    return '-';
  }

  String _safeText(String? value, {String fallback = '-'}) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _riskLevelLabel(String? level) {
    switch (level?.trim()) {
      case '1':
        return 'Kurang dari 1 jam';
      case '2':
        return 'Kurang dari 24 jam';
      case '3':
        return 'Kurang dari 3 hari';
      case '4':
        return 'Kurang dari 2 minggu';
      default:
        return level?.trim().isNotEmpty == true ? 'Level ${level!.trim()}' : '-';
    }
  }

  String? _normalizePicToken(String? raw) {
    if (raw == null) return null;
    final value = raw.trim();
    if (value.isEmpty) return null;

    // Kasus 1: token polos
    if (!value.contains('://') && !value.contains('/')) {
      return value;
    }

    // Kasus 2: URL API legacy atau URL publik
    final uri = Uri.tryParse(value);
    if (uri != null) {
      final segments = uri.pathSegments;
      if (segments.length >= 2 && segments[0] == 'share' && segments[1] == 'report') {
        return segments.isNotEmpty ? segments.last : null;
      }

      if (segments.length >= 4 && segments[0] == 'api' && segments[1] == 'hse' && segments[2] == 'reports' && segments[3] == 'pic') {
        return segments.isNotEmpty ? segments.last : null;
      }
    }

    // Fallback aman: ambil segmen terakhir non-kosong
    final parts = value.split('/').where((e) => e.trim().isNotEmpty).toList();
    if (parts.isEmpty) return null;
    return parts.last.trim();
  }

  void _goToHomeByRole(BuildContext context) {
    final user = ref.read(currentUserProvider);
    final role = user?.role;

    if (role == UserRole.hseSupervisor) {
      context.goNamed(RouteNames.supervisorHome);
    } else if (role == UserRole.pic) {
      context.goNamed(RouteNames.picHome);
    } else {
      context.goNamed(RouteNames.petugasHome);
    }
  }

  void _submitData() async {
    final draft = ref.read(createTaskFormProvider);

    if (draft.buildingType == null || draft.area == null || draft.riskLevel == null ||
        draft.photos.isEmpty || draft.notes == null || draft.rootCause == null) {
      AppToast.warning(context, message: 'Harap lengkapi semua data laporan.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final createdTask = await ref.read(createTaskFormProvider.notifier).submitTask();

      if (createdTask != null && createdTask is! bool && mounted) {
        final picToken = _normalizePicToken(createdTask.picToken?.toString());
        final deepLinkUrl = (picToken != null && picToken.isNotEmpty)
            ? 'https://mes.aksamala.co.id/share/report/$picToken'
            : 'Link belum tersedia';
        debugPrint('[CreateTaskReviewScreen] share deep-link url: $deepLinkUrl');
        
        // Format Teks Caption WA
        final areaLabel = _safeText(draft.area);
        final waText = '''🚨 *LAPORAN TEMUAN HSE* 🚨

📍 *Area:* $areaLabel
🏭 *Tipe Lokasi:* ${_locationTypeLabel(draft.buildingType)}
⚠️ *Tingkat Risiko:* ${_riskLevelLabel(draft.riskLevel)}
📝 *Akar Masalah:* ${draft.rootCause}
💬 *Keterangan:* ${draft.notes}

Untuk proses tindak lanjut, silakan klik link berikut:
🔗 Buka Aplikasi: $deepLinkUrl''';

        if (!mounted) return;
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Laporan Terkirim!'),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(ctx).size.width * 0.8,
              child: Column(
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
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    text: 'Bagikan Laporan',
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedShare01,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: () async {
                      try {
                        // Menggunakan Share Helper untuk Local File
                        if (draft.photos.isNotEmpty) {
                          await ShareHelper.shareLocalImage(
                            imagePath: draft.photos.first,
                            caption: waText,
                          );
                        } else {
                          // Fallback jika anehnya tidak ada foto
                          await Share.share(waText);
                        }

                        // Setelah share system tray tertutup, kembalikan user ke home
                        if (mounted && ctx.mounted) {
                          ctx.pop(); 
                          _goToHomeByRole(context); 
                        }
                      } catch (e) {
                        debugPrint('Gagal membagikan: $e');
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Terjadi kesalahan saat membagikan laporan.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 8),
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
            ],
          ),
        );
      }
    } catch (e) {
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
              child: Text(e.toString()),
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
                  _buildRow('Tingkat Risiko', _riskLevelLabel(draft.riskLevel)),
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
