import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/shimmer/shimmers/task_detail_shimmer.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/share_helper.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../pic/presentation/providers/pic_follow_up_provider.dart';
import '../../../follow_up/presentation/providers/follow_up_provider.dart';
import '../providers/task_provider.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;
  final String? picToken;
  const TaskDetailScreen({super.key, required this.taskId, this.picToken});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen>
    with AutomaticKeepAliveClientMixin {
  bool _isSubmitting = false;

  @override
  bool get wantKeepAlive => true;

  bool get _isPicToken {
    final idNum = int.tryParse(widget.taskId);
    return idNum == null;
  }

  int? _getTaskId() {
    if (_isPicToken) return null;
    return int.tryParse(widget.taskId);
  }

  String? _normalizePicToken(String? raw) {
    if (raw == null) return null;
    final value = raw.trim();
    if (value.isEmpty) return null;

    if (!value.contains('://') && !value.contains('/')) {
      return value;
    }

    final uri = Uri.tryParse(value);
    if (uri != null) {
      final segments = uri.pathSegments;
      if (segments.length >= 2 &&
          segments[0] == 'share' &&
          segments[1] == 'report') {
        return segments.last;
      }
      if (segments.length >= 4 &&
          segments[0] == 'api' &&
          segments[1] == 'hse' &&
          segments[2] == 'reports' &&
          segments[3] == 'pic') {
        return segments.last;
      }
    }

    final parts = value.split('/').where((e) => e.trim().isNotEmpty).toList();
    if (parts.isEmpty) return null;
    return parts.last.trim();
  }

  // Helper untuk menentukan status sebenarnya dari report (sama seperti di all tasks screen)
  String _getActualStatus(Map<String, dynamic> report) {
    final followUps = report['followUps'] as List<dynamic>? ??
        report['follow_ups'] as List<dynamic>? ??
        [];

    if (followUps.isNotEmpty) {
      final lastFollowUp = followUps.last as Map<String, dynamic>;
      final lastStatus = lastFollowUp['status']?.toString().toLowerCase();

      // Jika follow-up terakhir rejected, maka status report adalah "Pending Rejected"
      if (lastStatus == 'rejected') {
        return 'Pending Rejected';
      }
    }

    // Default ke status report
    return report['status']?.toString() ?? 'Pending';
  }

  bool _canCancelTask(Map<String, dynamic> rpt, dynamic user) {
    if (user == null || rpt.isEmpty) return false;

    final status = (rpt['status']?.toString() ?? '').toLowerCase();
    if (status != 'pending') return false;

    final int currentUserId = user.id;
    final reportOwnerId = int.tryParse(rpt['userId']?.toString() ?? '');

    // Tombol batal hanya untuk user yang membuat laporan
    return reportOwnerId != null && currentUserId == reportOwnerId;
  }

  int? _ownerId(Map<String, dynamic> rpt) {
    final raw = rpt['created_by'] ??
        rpt['createdBy'] ??
        rpt['user_id'] ??
        rpt['userId'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '');
  }

  String _normalizeStatus(dynamic raw) {
    return raw?.toString().trim().toLowerCase() ?? '';
  }

  String _getRiskLevelLabel(String? riskLevel) {
    if (riskLevel == null || riskLevel.isEmpty) return '-';

    // Konversi angka ke deskripsi yang lebih mudah dipahami
    switch (riskLevel.trim()) {
      case '1':
        return 'Kurang dari 1 jam';
      case '2':
        return 'Kurang dari 24 jam';
      case '3':
        return 'Kurang dari 3 hari';
      case '4':
        return 'Kurang dari 2 minggu';
      default:
        // Fallback ke angka asli jika tidak dikenali
        return 'Level $riskLevel';
    }
  }

  IconData _getRiskLevelIcon(String? riskLevel) {
    if (riskLevel == null || riskLevel!.trim().isEmpty) {
      return Icons.warning_amber;
    }

    // Gunakan Icons dari material design yang mirip dengan HugeIcons
    final normalizedLevel = riskLevel!.trim();
    switch (normalizedLevel) {
      case '1':
        return Icons.access_time; // < 1 jam (timer icon)
      case '2':
        return Icons.schedule; // < 24 jam (clock icon)
      case '3':
        return Icons.calendar_today; // < 3 hari
      case '4':
        return Icons.event; // < 2 minggu (calendar icon)
      default:
        return Icons.warning_amber; // Unknown
    }
  }

  Color _getRiskLevelColor(String? riskLevel) {
    if (riskLevel == null || riskLevel.isEmpty) return AppColors.textSecondary;

    // Mapping sesuai dengan create_task_risk_level_screen:
    // Level 1 "Kurang dari 1 Jam" → riskLevel4 (Merah) - Paling cepat, paling bahaya
    // Level 2 "Kurang dari 24 Jam" → riskLevel3 (Orange) - Bahaya
    // Level 3 "Kurang dari 3 Hari" → riskLevel2 (Kuning) - Sedang
    // Level 4 "Kurang dari 2 Minggu" → riskLevel1 (Biru) - Paling lama, paling aman
    switch (riskLevel.trim()) {
      case '1':
        return AppColors.riskLevel4; // Merah - < 1 jam (paling bahaya)
      case '2':
        return AppColors.riskLevel3; // Orange - < 24 jam
      case '3':
        return AppColors.riskLevel2; // Kuning - < 3 hari
      case '4':
        return AppColors.riskLevel1; // Biru - < 2 minggu (paling aman)
      default:
        return AppColors.textSecondary;
    }
  }

  String _latestFollowUpAction(Map<String, dynamic> rpt) {
    final followUps = rpt['followUps'];
    if (followUps is! List || followUps.isEmpty) return '';

    final last = followUps.last;
    if (last is! Map) return '';

    final map = Map<String, dynamic>.from(last);
    return _normalizeStatus(map['action']);
  }

  // Helper untuk mendapatkan status follow-up terakhir (approved/rejected/pending)
  String? _latestFollowUpStatus(Map<String, dynamic> rpt) {
    final followUps = rpt['followUps'];
    if (followUps is! List || followUps.isEmpty) return null;

    final last = followUps.last;
    if (last is! Map) return null;

    final map = Map<String, dynamic>.from(last);
    return _normalizeStatus(map['status']);
  }

  bool _canReviewFollowUp(Map<String, dynamic> rpt, dynamic user) {
    if (user == null || rpt.isEmpty) return false;

    final role = user.role;
    if (role != UserRole.petugasHse && role != UserRole.hseSupervisor) {
      return false;
    }

    final currentUserId = user.id;
    final reportOwnerId = _ownerId(rpt);
    if (reportOwnerId == null || reportOwnerId != currentUserId) {
      return false;
    }

    // Gunakan actual status untuk konsistensi dengan _getActualStatus()
    final actualStatus = _getActualStatus(rpt);
    if (actualStatus.toLowerCase() != 'follow up done') {
      return false;
    }

    // Cek follow-up terakhir: harus ada dan status-nya bukan 'rejected'
    final latestFollowUpStatus = _latestFollowUpStatus(rpt);
    if (latestFollowUpStatus == null || latestFollowUpStatus == 'rejected') {
      return false;
    }

    return true;
  }

  void _handlePetugasReview(Map<String, dynamic> rpt, String action) async {
    if (_isSubmitting) return;

    String? reason;
    bool isConfirm = false;

    if (action == 'Rejected' || action == 'Canceled') {
      final isCancel = action == 'Canceled';
      final controller = TextEditingController();

      reason = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) {
          final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
          return AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: bottomInset),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCancel ? 'Batalkan Laporan?' : 'Tolak Perbaikan',
                        style: AppTypography.h3,
                      ),
                      const SizedBox(height: 12),
                      if (isCancel)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Apakah Anda yakin ingin membatalkan laporan ini? Laporan yang dibatalkan tidak dapat dikembalikan.',
                            style: AppTypography.body1
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      Row(
                        children: [
                          Text(
                            isCancel ? 'Alasan Pembatalan' : 'Alasan Penolakan',
                            style: AppTypography.body1
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Text(
                            ' *',
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller,
                        style: AppTypography.body1,
                        decoration: InputDecoration(
                          hintText: isCancel
                              ? 'Wajib diisi. Tuliskan alasan pembatalan...'
                              : 'Misal: Pagar pembatas tidak dilas permanen...',
                          hintStyle: AppTypography.caption,
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.medium),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        minLines: 3,
                        maxLines: 5,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(
                                'Kembali',
                                style: AppTypography.body1
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCancel
                                    ? Colors.redAccent
                                    : Colors.orangeAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pill),
                                ),
                              ),
                              onPressed: () {
                                if (controller.text.trim().isEmpty) {
                                  AppToast.warning(
                                    ctx,
                                    message: isCancel
                                        ? 'Alasan pembatalan wajib diisi!'
                                        : 'Alasan penolakan wajib diisi!',
                                  );
                                  return;
                                }

                                Navigator.pop(ctx, controller.text.trim());
                              },
                              child: Text(
                                isCancel ? 'Ya, Batalkan' : 'Tolak',
                                style: AppTypography.body1.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

      if (reason == null || reason!.trim().isEmpty) return;
    } else if (action == 'Approved') {
      isConfirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.large)),
              title: Text('Terima Perbaikan?', style: AppTypography.h3),
              content: Text(
                  'Apakah Anda yakin tindak lanjut sudah sesuai standar?',
                  style: AppTypography.body1
                      .copyWith(color: AppColors.textSecondary)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text('Batal',
                        style: AppTypography.body1
                            .copyWith(color: AppColors.textSecondary))),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill))),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text('Ya, Terima',
                        style: AppTypography.body1.copyWith(
                            color: AppColors.textInverted,
                            fontWeight: FontWeight.bold))),
              ],
            ),
          ) ??
          false;
      if (!isConfirm) return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final followUps = rpt['followUps'] as List<dynamic>? ?? [];

      if (followUps.isNotEmpty &&
          (action == 'Approved' || action == 'Rejected')) {
        final latestFollowUp = followUps.last as Map<String, dynamic>;
        final followUpId = latestFollowUp['id'] as int?;

        if (followUpId != null) {
          final followUpRepo = ref.read(followUpRepositoryProvider);
          final approval = action.toLowerCase();

          final taskId = _resolveTaskId(rpt);
          if (taskId == null) {
            throw Exception('Task ID tidak ditemukan dalam response API');
          }

          await followUpRepo.approveFollowUp(
            taskId,
            followUpId,
            approval,
            action == 'Rejected' ? reason : null,
          );
        }
      } else if (action == 'Canceled') {
        final taskRepo = ref.read(taskRepositoryProvider);
        final taskId = _resolveTaskId(rpt);
        if (taskId == null) {
          throw Exception('Task ID tidak ditemukan dalam response API');
        }
        await taskRepo.cancelTask(taskId);
      }

      if (_isPicToken) {
        ref.invalidate(taskDetailByPicTokenProvider(widget.taskId));
      } else {
        ref.invalidate(taskDetailMapProvider(widget.taskId));
      }
      ref.invalidate(tasksFutureProvider);
      ref.invalidate(petugasTaskMapsProvider);
      ref.invalidate(supervisorOwnTaskMapsProvider);
      ref.invalidate(supervisorStaffTaskMapsProvider);
      ref.invalidate(supervisorAllVisibleTaskMapsProvider);

      if (!mounted) return;

      final toastMsg = action == 'Approved'
          ? 'Tugas Selesai!'
          : (action == 'Rejected'
              ? 'Perbaikan ditolak!'
              : 'Laporan berhasil dibatalkan!');

      if (action == 'Approved') {
        AppToast.success(context, message: toastMsg);
      } else if (action == 'Rejected') {
        AppToast.error(context, message: toastMsg);
      } else {
        AppToast.success(context, message: toastMsg);
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.error(context, message: 'Gagal memproses aksi: ${e.toString()}');
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
    final user = ref.watch(currentUserProvider);

    final detailAsync = _isPicToken
        ? ref.watch(taskDetailByPicTokenProvider(widget.taskId))
        : ref.watch(taskDetailMapProvider(widget.taskId));

    if (detailAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: TaskDetailShimmer(),
      );
    }

    if (detailAsync.hasError) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textPrimary, size: 20),
            onPressed: () => _handleBackPressed(context, user),
          ),
          title: Text('Detail', style: AppTypography.h3),
        ),
        body: Center(
          child: Text(
            'Gagal memuat detail laporan.',
            style: AppTypography.body1,
          ),
        ),
      );
    }

    final rpt = detailAsync.valueOrNull;

    if (rpt == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary, size: 20),
              onPressed: () => _handleBackPressed(context, user)),
          title: Text('Detail', style: AppTypography.h3),
        ),
        body: Center(
            child:
                Text('Laporan tidak ditemukan.', style: AppTypography.body1)),
      );
    }

    final isPic = user?.role == UserRole.pic;
    final isSupervisor = user?.role == UserRole.hseSupervisor;
    final isPetugas = user?.role == UserRole.petugasHse;

    // Gunakan actual status yang mengecek follow-up terakhir
    final actualStatus = _getActualStatus(rpt);
    final rawStatusLower = actualStatus.toLowerCase();
    final latestFollowUpAction = _latestFollowUpAction(rpt);

    final canCancel = _canCancelTask(rpt, user);
    final canReviewFollowUp = _canReviewFollowUp(rpt, user);
    final isTaskOwner = user != null && _ownerId(rpt) == user.id;
    final latestFollowUpStatus = _latestFollowUpStatus(rpt);

    // Menunggu respon PIC jika follow-up terakhir di-reject dan status actual-nya "Pending Rejected"
    final isWaitingPicResponse = (isPetugas || isSupervisor) &&
        isTaskOwner &&
        latestFollowUpStatus == 'rejected' &&
        rawStatusLower == 'pending rejected';

    debugPrint(
      '[TaskDetailScreen] action-gating '
      'role=${user?.role.name} '
      'status=$rawStatusLower '
      'ownerId=${_ownerId(rpt)} '
      'currentUserId=${user?.id} '
      'latestFollowUpAction=$latestFollowUpAction '
      'canReviewFollowUp=$canReviewFollowUp '
      'canCancel=$canCancel',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textPrimary, size: 20),
            onPressed: () => _handleBackPressed(context, user)),
        title: Text('Task Detail', style: AppTypography.h3),
        centerTitle: true,
        actions: [
          // TOMBOL SHARE IMPLEMENTASI BARU
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.primary),
            onPressed: () {
              final resolvedPicToken = _normalizePicToken(widget.picToken) ??
                  _normalizePicToken(rpt['picToken']?.toString());

              if (resolvedPicToken == null) {
                debugPrint(
                  '[TaskDetailScreen] picToken tidak tersedia, fallback ke taskId untuk share: ${widget.taskId}',
                );
              }

              final waText = '''🚨 *DETAIL TEMUAN HSE* 🚨

📍 *Area:* ${rpt['area'] ?? '-'}
⚠️ *Tingkat Risiko:* ${_getRiskLevelLabel(rpt['riskLevel']?.toString())} ${_getRiskLevelIcon(rpt['riskLevel']?.toString())}
💬 *Catatan:* ${rpt['notes'] ?? '-'}

🔗 Buka di Aplikasi: https://mes.aksamala.co.id/share/report/${resolvedPicToken ?? widget.taskId}''';

              final photos = _extractPhotoUrls(rpt['photos']);
              if (photos.isNotEmpty) {
                // Share menggunakan network helper untuk gambar dari backend API
                ShareHelper.shareNetworkImage(
                  context: context,
                  imageUrl: photos.first,
                  caption: waText,
                );
              } else {
                // Jika laporan tidak memiliki gambar, share text biasa
                Share.share(waText);
              }
            },
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 140),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeroCard(rpt, actualStatus),
                  const SizedBox(height: 24),
                  Text("Informasi Laporan", style: AppTypography.h3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildInfoCard(PhosphorIcons.mapPin(),
                              'Lokasi', rpt['area']?.toString() ?? '-')),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildRiskLevelCard(rpt['riskLevel']?.toString()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(PhosphorIcons.clock(), 'Waktu Dilaporkan',
                      _formatDate(rpt['date']?.toString())),
                  const SizedBox(height: 24),
                  _buildSectionBox(
                      'Catatan Temuan',
                      rpt['notes']?.toString() ?? '-',
                      PhosphorIcons.notePencil()),
                  const SizedBox(height: 16),
                  _buildSectionBox(
                      'Akar Masalah (Root Cause)',
                      rpt['rootCause']?.toString() ?? '-',
                      PhosphorIcons.treeStructure()),
                  const SizedBox(height: 24),
                  if (_extractPhotoUrls(rpt['photos']).isNotEmpty) ...[
                    Text("Lampiran Bukti", style: AppTypography.h3),
                    const SizedBox(height: 12),
                    _buildPhotoGrid(_extractPhotoUrls(rpt['photos'])),
                  ],
                  const SizedBox(height: 32),
                  if (rpt['followUps'] != null &&
                      (rpt['followUps'] as List).isNotEmpty) ...[
                    Text("Riwayat Tindak Lanjut", style: AppTypography.h3),
                    const SizedBox(height: 16),
                    _buildLogTimeline(rpt['followUps'] as List<dynamic>),
                  ],
                ],
              ),
            ),

            // ACTION BUTTON AREA
            if (rawStatusLower != 'canceled')
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4))
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (canCancel)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(
                                    color: Colors.redAccent, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pill),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 24),
                              ),
                              onPressed: _isSubmitting
                                  ? null
                                  : () => _handlePetugasReview(rpt, 'Canceled'),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.redAccent),
                                      ),
                                    )
                                  : Text(
                                      'Batalkan Laporan',
                                      style: AppTypography.body1.copyWith(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      if (isPic &&
                          (rawStatusLower == 'pending' ||
                              rawStatusLower == 'pending rejected'))
                        AppButton(
                          text: 'Mulai Tindak Lanjut',
                          isLoading: _isSubmitting,
                          onPressed: () {
                            ref
                                .read(picFollowUpFormProvider.notifier)
                                .setReportId(widget.taskId);
                            context.pushNamed(RouteNames.picFollowUpPhotos);
                          },
                        )
                      else if (canReviewFollowUp)
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                text: 'Tolak',
                                type: AppButtonType.outlined,
                                isLoading: _isSubmitting,
                                onPressed: () =>
                                    _handlePetugasReview(rpt, 'Rejected'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppButton(
                                text: 'Terima',
                                isLoading: _isSubmitting,
                                onPressed: () =>
                                    _handlePetugasReview(rpt, 'Approved'),
                              ),
                            ),
                          ],
                        )
                      else if (!canCancel)
                        AppButton(
                          text: isWaitingPicResponse
                              ? 'Menunggu Respon PIC'
                              : (rawStatusLower == 'completed'
                                  ? 'Laporan Selesai'
                                  : 'Menunggu Respon'),
                          type: AppButtonType.outlined,
                          onPressed: null,
                        ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(Map<String, dynamic> rpt, String status) {
    Color bgColor;
    final rawStatus = status.toLowerCase();

    switch (rawStatus) {
      case 'pending':
        bgColor = const Color(0xFFD4D8FF);
        break;
      case 'follow up done':
        bgColor = const Color(0xFFFAFF9F);
        break;
      case 'pending rejected':
        bgColor = const Color(0xFFFFCDD2);
        break; // Merah muda untuk rejected
      case 'completed':
        bgColor = const Color(0xFFC1F0D0);
        break;
      case 'canceled':
        bgColor = const Color(0xFF1E1E1E);
        break;
      default:
        bgColor = const Color(0xFFFFFFFF);
    }

    final bool isDark = rawStatus == 'canceled';
    Color textColor = isDark ? Colors.white : const Color(0xFF1E1E1E);

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  rawStatus == 'canceled'
                      ? 'DIBATALKAN'
                      : rawStatus == 'pending rejected'
                          ? 'PENDING REJECTED'
                          : status.toUpperCase(),
                  style: AppTypography.caption
                      .copyWith(color: textColor, fontWeight: FontWeight.bold),
                ),
              ),
              PhosphorIcon(
                  rawStatus == 'canceled'
                      ? PhosphorIcons.xCircle(PhosphorIconsStyle.fill)
                      : PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill),
                  color: textColor,
                  size: 32),
            ],
          ),
          const SizedBox(height: 24),
          Text(rpt['title']?.toString() ?? 'Inspeksi Rutin',
              style: AppTypography.h2.copyWith(color: textColor, height: 1.2)),
          const SizedBox(height: 12),
          Text(
              'Dilaporkan oleh: ${rpt['staffName']?.toString() ?? 'HSE Officer'}',
              style: AppTypography.body1
                  .copyWith(color: textColor.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value,
      {Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                shape: BoxShape.circle),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
              style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRiskLevelCard(String? riskLevel) {
    final label = _getRiskLevelLabel(riskLevel);
    final iconData = _getRiskLevelIcon(riskLevel);
    final color = _getRiskLevelColor(riskLevel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PhosphorIcon di atas dengan background warna - mirip dengan create_task_risk_level_screen
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              size: 28,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          // Label "Tingkat Risiko" di tengah
          Text(
            'Tingkat Risiko',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          // Keterangan risk level di bawah
          Text(
            label,
            style: AppTypography.body1.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionBox(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(title,
                  style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: AppTypography.body1.copyWith(height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(List<String> paths, {double height = 100}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: paths.length,
      itemBuilder: (context, index) {
        final url = paths[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _showImagePreview(url),
            child: url.startsWith('http')
                ? Image.network(url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child:
                            const Icon(Icons.broken_image, color: Colors.grey)))
                : Image.file(File(url),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image,
                            color: Colors.grey))),
          ),
        );
      },
    );
  }

  void _showImagePreview(String url) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: url.startsWith('http')
                      ? Image.network(url, fit: BoxFit.contain)
                      : Image.file(File(url), fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogTimeline(List<dynamic> logs) {
    return Column(
      children: List.generate(logs.length, (index) {
        final log = logs[index] as Map<String, dynamic>;
        final isLast = index == logs.length - 1;
        final action = log['action']?.toString().toLowerCase();

        bool isPicLog = true;
        Color dotColor = AppColors.primary;

        if (action == 'approved' || action == 'completed') {
          isPicLog = false;
          dotColor = Colors.green;
        } else if (action == 'rejected') {
          isPicLog = false;
          dotColor = Colors.redAccent;
        }

        final picName = log['pic_name']?.toString() ??
            log['pic']?.toString() ??
            log['user']?.toString() ??
            log['created_by']?.toString() ??
            log['staff_name']?.toString();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
                if (!isLast)
                  Container(width: 2, height: 72, color: AppColors.border),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(
                          log['date']?.toString() ??
                              log['created_at']?.toString() ??
                              log['updated_at']?.toString(),
                        ),
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPicLog ? 'Respon PIC' : 'Review Petugas',
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: dotColor,
                        ),
                      ),
                      // Nama user di baris terpisah untuk menghindari overflow
                      if (picName != null && picName.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: (isPicLog ? AppColors.primary : dotColor)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPicLog
                                    ? PhosphorIcons.user(
                                        PhosphorIconsStyle.fill)
                                    : PhosphorIcons.shieldCheck(
                                        PhosphorIconsStyle.fill),
                                size: 12,
                                color: isPicLog ? AppColors.primary : dotColor,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  picName,
                                  style: AppTypography.caption.copyWith(
                                    color:
                                        isPicLog ? AppColors.primary : dotColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (action != null && action.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${action.toUpperCase()}',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                      if (log['notes'] != null &&
                          log['notes'].toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(log['notes'].toString(),
                            style: AppTypography.caption),
                      ],
                      if (_extractPhotoUrls(log['photos']).isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildPhotoGrid(_extractPhotoUrls(log['photos']),
                            height: 60),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final date = DateTime.parse(raw);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return raw;
    }
  }

  int? _resolveTaskId(Map<String, dynamic> rpt) {
    final raw = rpt['taskId'] ?? rpt['id'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '');
  }

  List<String> _extractPhotoUrls(dynamic photosRaw) {
    if (photosRaw is Map) {
      return photosRaw.values
          .map((value) => value?.toString() ?? '')
          .where((value) => value.isNotEmpty)
          .toList();
    }

    if (photosRaw is List) {
      return photosRaw
          .map((value) => value?.toString() ?? '')
          .where((value) => value.isNotEmpty)
          .toList();
    }

    return <String>[];
  }

  void _handleBackPressed(BuildContext context, UserModel? user) {
    // Coba pop dulu untuk normal flow (masuk dari list screen)
    if (Navigator.of(context).canPop()) {
      context.pop();
    } else {
      // Jika tidak bisa pop (akses via deeplink), redirect ke home sesuai role
      final homeRoute = switch (user?.role) {
        UserRole.petugasHse => '/petugas/home',
        UserRole.hseSupervisor => '/supervisor/home',
        UserRole.pic => '/pic/home',
        _ => '/petugas/home',
      };
      debugPrint('[TaskDetailScreen] Cannot pop, redirecting to home: $homeRoute');
      context.go(homeRoute);
    }
  }
}
