import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/mock_api/mock_database.dart';
import '../../../../app/router/route_names.dart';
import '../../../pic/presentation/providers/pic_follow_up_provider.dart';
import '../../../follow_up/presentation/providers/follow_up_provider.dart';
import '../providers/task_provider.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  bool _isSubmitting = false;

  // Modal Penolakan Modern / Pembatalan / Persetujuan
  void _handlePetugasReview(Map<String, dynamic> rpt, String action) async {
    if (_isSubmitting) return;

    String? reason;
    bool isConfirm = false;

    if (action == 'Rejected' || action == 'Canceled') {
      final isCancel = action == 'Canceled';
      final controller = TextEditingController();
      reason = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
          title: Text(isCancel ? 'Batalkan Laporan' : 'Tolak Perbaikan', style: AppTypography.h3),
          content: TextField(
            controller: controller,
            style: AppTypography.body1,
            decoration: InputDecoration(
              hintText: isCancel ? 'Tuliskan alasan spesifik pembatalan...' : 'Misal: Pagar pembatas tidak dilas permanen...',
              hintStyle: AppTypography.caption,
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.medium), borderSide: BorderSide.none),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Kembali', style: AppTypography.body1.copyWith(color: AppColors.textSecondary))),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCancel ? Colors.redAccent : Colors.orangeAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                ),
                onPressed: () {
                  if (controller.text.trim().isEmpty) {
                    AppSnackBar.warning(ctx, message: 'Alasan wajib diisi!');
                    return;
                  }
                  Navigator.pop(ctx, controller.text.trim());
                },
                child: Text(isCancel ? 'Konfirmasi Batal' : 'Tolak', style: AppTypography.body1.copyWith(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
      );
      if (reason == null) return;
    } else if (action == 'Approved') {
      isConfirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
          title: Text('Terima Perbaikan?', style: AppTypography.h3),
          content: Text('Apakah Anda yakin tindak lanjut sudah sesuai standar?', style: AppTypography.body1.copyWith(color: AppColors.textSecondary)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Batal', style: AppTypography.body1.copyWith(color: AppColors.textSecondary))),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill))),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Ya, Terima', style: AppTypography.body1.copyWith(color: AppColors.textInverted, fontWeight: FontWeight.bold))),
          ],
        ),
      ) ?? false;
      if (!isConfirm) return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final followUps = rpt['followUps'] as List<dynamic>? ?? [];

      if (followUps.isNotEmpty && (action == 'Approved' || action == 'Rejected')) {
        // Get the latest follow-up
        final latestFollowUp = followUps.last as Map<String, dynamic>;
        final followUpId = latestFollowUp['id'] as int?;

        if (followUpId != null) {
          // Call backend API for approval/rejection
          final followUpRepo = ref.read(followUpRepositoryProvider);
          final approval = action.toLowerCase(); // 'approved' or 'rejected'

          await followUpRepo.approveFollowUp(
            int.parse(widget.taskId),
            followUpId,
            approval,
            action == 'Rejected' ? reason : null,
          );
        }
      } else if (action == 'Canceled') {
        final taskRepo = ref.read(taskRepositoryProvider);
        await taskRepo.cancelTask(int.parse(widget.taskId));
      } else {
        // No-op: no follow-up to process.
      }

      ref.invalidate(taskDetailMapProvider(widget.taskId));
      ref.invalidate(tasksFutureProvider);
      ref.invalidate(petugasTaskMapsProvider);
      ref.invalidate(supervisorOwnTaskMapsProvider);
      ref.invalidate(supervisorStaffTaskMapsProvider);
      ref.invalidate(supervisorAllVisibleTaskMapsProvider);

      if (!mounted) return;
      setState(() {});

      final snackBarMsg = action == 'Approved' ? 'Tugas Selesai!' : (action == 'Rejected' ? 'Perbaikan ditolak!' : 'Laporan Dibatalkan!');

      if (action == 'Approved') {
        AppSnackBar.success(context, message: snackBarMsg);
      } else if (action == 'Rejected') {
        AppSnackBar.error(context, message: snackBarMsg);
      } else {
        AppSnackBar.warning(context, message: snackBarMsg);
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, message: 'Gagal memproses aksi: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(taskDetailMapProvider(widget.taskId));
    final user = ref.watch(currentUserProvider);

    if (detailAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (detailAsync.hasError) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text('Detail', style: AppTypography.h3.copyWith(color: Colors.white)),
        ),
        body: Center(
          child: Text(
            'Gagal memuat detail laporan.',
            style: AppTypography.body1.copyWith(color: Colors.white),
          ),
        ),
      );
    }

    final rpt = detailAsync.valueOrNull;

    if (rpt == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => context.pop()),
          title: Text('Detail', style: AppTypography.h3.copyWith(color: Colors.white)),
        ),
        body: Center(child: Text('Laporan tidak ditemukan.', style: AppTypography.body1.copyWith(color: Colors.white))),
      );
    }

    final isPic = user?.role == 'pic';
    final isPetugas = user?.role == 'petugas';
    final isSupervisor = user?.role == 'supervisor';
    final isSupervisorOwner = _isSupervisorTaskOwner(rpt, user);
    final status = rpt['status']?.toString() ?? 'Pending';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20), onPressed: () => context.pop()),
        title: Text('Task Detail', style: AppTypography.h3),
        centerTitle: true,
        // ACTION Dihapus: Tombol cancel tidak lagi di App Bar
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 140), // Ruang lega untuk action area
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeroCard(rpt, status),
                  const SizedBox(height: 24),
                  Text("Informasi Laporan", style: AppTypography.h3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildInfoCard(PhosphorIcons.mapPin(), 'Lokasi', rpt['area']?.toString() ?? '-')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildInfoCard(PhosphorIcons.warningCircle(), 'Risiko', rpt['riskLevel']?.toString() ?? '-', iconColor: rpt['riskLevel']?.toString() == 'Kritis' ? Colors.redAccent : AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(PhosphorIcons.clock(), 'Waktu Dilaporkan', _formatDate(rpt['date']?.toString())),
                  const SizedBox(height: 24),
                  _buildSectionBox('Catatan Temuan', rpt['notes']?.toString() ?? '-', PhosphorIcons.notePencil()),
                  const SizedBox(height: 16),
                  _buildSectionBox('Akar Masalah (Root Cause)', rpt['rootCause']?.toString() ?? '-', PhosphorIcons.treeStructure()),
                  const SizedBox(height: 24),

                  if (rpt['photos'] != null && (rpt['photos'] as List).isNotEmpty) ...[
                    Text("Lampiran Bukti", style: AppTypography.h3),
                    const SizedBox(height: 12),
                    _buildPhotoGrid(List<String>.from(rpt['photos'])),
                    const SizedBox(height: 32),
                  ],

                  Builder(builder: (context) {
                    final followUps = rpt['followUps'] as List<dynamic>? ?? [];
                    if (followUps.isEmpty) return const SizedBox();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Riwayat Tindak Lanjut", style: AppTypography.h3),
                        const SizedBox(height: 16),
                        ...followUps.asMap().entries.map((entry) {
                          final isLast = entry.key == followUps.length - 1;
                          return _buildTimelineItem(entry.value as Map<String, dynamic>, isLast);
                        }),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),

                  // UX IMPROVEMENT: Danger Zone untuk membatalkan Task (Bawah Halaman)
                  if ((isPetugas || (isSupervisor && isSupervisorOwner)) &&
                      (status == 'Pending' || status == 'Follow Up Done'))
                    _buildDangerZone(rpt),
                ],
              ),
            ),
            _buildFloatingActionArea(isPic, isPetugas, isSupervisor, isSupervisorOwner, status, rpt),
          ],
        ),
      ),
    );
  }

  // Helper Custom Card Danger Zone Pembatalan (User Friendly UX)
  Widget _buildDangerZone(Map<String, dynamic> rpt) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), color: Colors.redAccent, size: 24),
              const SizedBox(width: 8),
              Text('Batalkan Laporan', style: AppTypography.h3.copyWith(color: Colors.redAccent)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Laporan hanya dapat dibatalkan jika laporan ternyata merupakan duplikat, tidak valid, atau masalah telah terselesaikan oleh tim lain tanpa memerlukan tindak lanjut PIC.',
            style: AppTypography.caption.copyWith(color: AppColors.textPrimary, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
              ),
              onPressed: () {
                _handlePetugasReview(rpt, 'Canceled');
              },
              child: Text(
                'Batalkan Laporan Ini',
                style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(Map<String, dynamic> rpt, String status) {
    // Sinkronisasi logika warna persis dengan helper list card
    Color bgColor;
    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = const Color(0xFFD4D8FF); // Soft Purple
        break;
      case 'follow up done':
        bgColor = const Color(0xFFFAFF9F); // Soft Yellow
        break;
      case 'completed':
        bgColor = const Color(0xFFC1F0D0); // Soft Mint Green
        break;
      case 'canceled':
        bgColor = const Color(0xFFE5E5E5); // Soft Gray
        break;
      default:
        bgColor = const Color(0xFFFFFFFF);
    }
    
    Color textColor = const Color(0xFF1E1E1E);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF1E1E1E), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: AppTypography.caption.copyWith(color: textColor, fontWeight: FontWeight.bold),
                ),
              ),
              PhosphorIcon(PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill), color: textColor, size: 28),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Inspeksi ${rpt['area'] ?? '-'}',
            style: AppTypography.caption.copyWith(color: textColor.withValues(alpha: 0.7), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            rpt['rootCause']?.toString() ?? 'Inspeksi Area',
            style: AppTypography.h1.copyWith(color: textColor, height: 1.1),
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(PhosphorIconData icon, String title, String value, {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.medium)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: PhosphorIcon(icon, color: iconColor ?? AppColors.secondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.caption),
                const SizedBox(height: 4),
                Text(value, style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionBox(String title, String content, PhosphorIconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.medium)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.body1.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: AppTypography.body1.copyWith(height: 1.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> log, bool isLast) {
    final isPicLog = log['type']?.toString() == 'PIC_FOLLOW_UP';
    final action = log['action']?.toString();

    Color dotColor = AppColors.secondary;
    if (action == 'Rejected') dotColor = Colors.redAccent;
    if (action == 'Approved') dotColor = AppColors.primary;
    if (action == 'Canceled') dotColor = Colors.orangeAccent;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(width: 16, height: 16, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle, border: Border.all(color: AppColors.background, width: 3))),
                if (!isLast) Expanded(child: Container(width: 2, color: AppColors.surfaceLight))
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.medium)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPicLog ? 'Tindak Lanjut PIC' : 'Review Petugas (${action ?? "Unknown"})',
                      style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold, color: dotColor),
                    ),
                    if (log['notes'] != null && log['notes'].toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(log['notes'].toString(), style: AppTypography.caption),
                    ],
                    if (isPicLog && log['photos'] != null && (log['photos'] as List).isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildPhotoGrid(List<String>.from(log['photos'] as List), height: 60),
                    ]
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(List<String> paths, {double height = 80}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: paths.map((p) {
          final isNetwork = p.toString().startsWith('http');
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () => _showImagePopup(p),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: isNetwork
                    ? Image.network(p.toString(), width: height, height: height, fit: BoxFit.cover, errorBuilder: (ctx, err, stk) => _errorImage(height))
                    : Image.file(File(p.toString()), width: height, height: height, fit: BoxFit.cover, errorBuilder: (ctx, err, stk) => _errorImage(height)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _errorImage(double height) {
    return Container(width: height, height: height, color: AppColors.surface, child: Icon(Icons.broken_image, color: AppColors.textSecondary));
  }

  void _showImagePopup(String imagePath) {
    final isNetwork = imagePath.startsWith('http');

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: isNetwork
                    ? Image.network(
                        imagePath,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.background,
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image, size: 64, color: AppColors.textSecondary),
                                  SizedBox(height: 16),
                                  Text('Gagal memuat gambar', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Image.file(
                        File(imagePath),
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.background,
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image, size: 64, color: AppColors.textSecondary),
                                  SizedBox(height: 16),
                                  Text('Gagal memuat gambar', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildFloatingActionArea(
    bool isPic,
    bool isPetugas,
    bool isSupervisor,
    bool isSupervisorOwner,
    String status,
    Map<String, dynamic> rpt,
  ) {
    Widget? actionWidget;

    if (isPic && (status == 'Pending')) {
      actionWidget = AppButton(
        text: 'Mulai Tindak Lanjut',
        onPressed: () {
          ref.read(picFollowUpFormProvider.notifier).setReportId(widget.taskId);
          context.pushNamed(RouteNames.picFollowUpPhotos);
        },
      );
    } else if ((isPetugas || (isSupervisor && isSupervisorOwner)) && status == 'Follow Up Done') {
      actionWidget = Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Tolak',
              type: AppButtonType.outlined,
              onPressed: () => _handlePetugasReview(rpt, 'Rejected'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppButton(
              text: 'Selesai',
              onPressed: () => _handlePetugasReview(rpt, 'Approved'),
            ),
          ),
        ],
      );
    }

    if (actionWidget == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 24, left: 24, right: 24,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surfaceLight.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: actionWidget,
      ),
    );
  }

  bool _isSupervisorTaskOwner(Map<String, dynamic> report, dynamic user) {
    final userIdText = user?.id?.toString() ?? '';
    if (userIdText.isEmpty) return false;

    final ownerCandidates = <String?>[
      report['user_id']?.toString(),
      report['userId']?.toString(),
      report['created_by_id']?.toString(),
      report['createdById']?.toString(),
      report['owner_id']?.toString(),
      report['ownerId']?.toString(),
    ];

    return ownerCandidates.any((candidate) => candidate != null && candidate == userIdText);
  }
}
