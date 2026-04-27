import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/shimmer/shimmers/task_detail_shimmer.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/share_helper.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/auth_role_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/entities/risk_level.dart';
import '../controllers/task_detail_controller.dart';
import '../providers/task_provider.dart';
import '../widgets/task_detail_hero_card.dart';
import '../widgets/task_detail_bottom_actions.dart';
import '../widgets/task_timeline_section.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;
  final String? picToken;
  const TaskDetailScreen({super.key, required this.taskId, this.picToken});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen>
    with AutomaticKeepAliveClientMixin {
  TaskDetailControllerArgs get _controllerArgs => TaskDetailControllerArgs(
        taskId: widget.taskId,
        isPicToken: _isPicToken,
      );

  @override
  bool get wantKeepAlive => true;

  bool get _isPicToken {
    final idNum = int.tryParse(widget.taskId);
    return idNum == null;
  }




  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final user = ref.watch(currentUserProvider);
    final picUserMap = ref.watch(picUserMapProvider);
    final controller = ref.read(taskDetailControllerProvider(_controllerArgs).notifier);
    final isSubmitting = ref.watch(taskDetailSubmittingProvider(_controllerArgs));

    debugPrint('[TaskDetailScreen] Building screen...');
    debugPrint('[TaskDetailScreen] User: ${user?.name} (${user?.role})');
    debugPrint('[TaskDetailScreen] Task ID: ${widget.taskId}, isPicToken: $_isPicToken');

    ref.listen<TaskDetailUiEvent?>(
      taskDetailUiEventProvider(_controllerArgs),
      (previous, next) {
        if (next == null || !mounted) return;

        debugPrint(
          '[TaskDetailScreen] UI event type=${next.type.name} message=${next.message}',
        );

        switch (next.type) {
          case TaskDetailUiEventType.success:
            AppToast.success(context, message: next.message);
            break;
          case TaskDetailUiEventType.warning:
            AppToast.warning(context, message: next.message);
            break;
          case TaskDetailUiEventType.error:
            AppToast.error(context, message: next.message);
            break;
          case TaskDetailUiEventType.redirect:
            AppToast.success(context, message: next.message);
            final redirectTaskId = (next.redirectTaskId ?? widget.taskId).trim();
            debugPrint(
              '[TaskDetailScreen] redirect after cancel to detail id=$redirectTaskId',
            );
            context.goNamed(
              RouteNames.taskDetail,
              pathParameters: {'id': redirectTaskId},
            );
            break;
        }

        controller.clearUiEvent();
      },
    );

    final detailAsync = ref.watch(taskDetailControllerProvider(_controllerArgs));

    debugPrint('[TaskDetailScreen] Provider state: isLoading=${detailAsync.isLoading} hasValue=${detailAsync.hasValue} hasError=${detailAsync.hasError}');

    if (detailAsync.hasError) {
      debugPrint('[TaskDetailScreen] Provider error: ${detailAsync.error}');
    }

    if (detailAsync.isLoading && !detailAsync.hasValue) {
      debugPrint('[TaskDetailScreen] Showing loading shimmer');
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: TaskDetailShimmer(),
      );
    }

    if (detailAsync.hasError) {
      final error = detailAsync.error;
      debugPrint('[TaskDetailScreen] Error loading task detail: $error');
      debugPrint('[TaskDetailScreen] User: ${user?.name} (${user?.role})');
      debugPrint('[TaskDetailScreen] Task ID: ${widget.taskId}, isPicToken: $_isPicToken');

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textPrimary, size: 20),
            onPressed: () {
              debugPrint('[TaskDetailScreen] Back button pressed on error screen');
              _handleBackPressed(context, user);
            },
          ),
          title: Text('Detail', style: AppTypography.h3),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat detail laporan',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Task ID: ${widget.taskId}',
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Error: ${error.toString()}',
                  style: AppTypography.caption.copyWith(
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    debugPrint('[TaskDetailScreen] Retry button pressed');
                    controller.refresh();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    debugPrint('[TaskDetailScreen] Back to home button pressed');
                    _navigateToHome(user);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Kembali ke Beranda'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final task = detailAsync.valueOrNull;

    if (task == null) {
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

    final isPic = user != null && isPicScopedRole(user.role);
    final rpt = task.raw;
    final rawStatusLower = task.status.rawValue;
    final canCancel = controller.canCancelTask(task, user);
    final canReviewFollowUp = controller.canReviewFollowUp(task, user);
    final canStartPicFollowUp = controller.canStartPicFollowUp(task, user);
    final isWaitingPicResponse = controller.isWaitingPicResponse(task, user);
    final logs = task.timeline.map((entry) => entry.raw).toList(growable: false);

    debugPrint(
      '[TaskDetailScreen] action-gating '
      'role=${user?.role.name} '
      'status=$rawStatusLower '
      'ownerId=${task.ownerId} '
      'currentUserId=${user?.id} '
      'latestFollowUpAction=${task.latestFollowUpAction} '
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
              final reportIdText =
                  (_resolveTaskId(rpt)?.toString() ?? widget.taskId).trim();
              final deepLinkUrl = reportIdText.isNotEmpty
                  ? 'https://mes.aksamala.co.id/share/report/$reportIdText'
                  : 'Link belum tersedia';
              debugPrint('[TaskDetailScreen] share deep-link url: $deepLinkUrl');

              final areaLabel = task.area;
              final reporterName =
                  (rpt['user_name']?.toString().trim().isNotEmpty == true)
                      ? rpt['user_name'].toString().trim()
                      : (rpt['userName']?.toString().trim().isNotEmpty == true)
                          ? rpt['userName'].toString().trim()
                          : (rpt['staff_name']?.toString().trim().isNotEmpty == true)
                              ? rpt['staff_name'].toString().trim()
                              : (rpt['staffName']?.toString().trim().isNotEmpty == true)
                                  ? rpt['staffName'].toString().trim()
                                  : (user?.name.trim().isNotEmpty == true)
                                      ? user!.name.trim()
                                      : '-';

              final supportLabel = task.toDepartmentValue == 1
                  ? 'Butuh Support HRGA'
                  : task.toDepartmentValue == 2
                      ? 'Butuh Support Engineer'
                      : 'Tidak Membutuhkan Support dari Department lain';

              final waText = '''*LAPORAN TEMUAN HSE*

👤 *Pelapor:* $reporterName
📍 *Area:* $areaLabel
⚠️ *Tingkat Risiko:* ${task.riskLevel.label}
📝 *Akar Masalah:* ${rpt['rootCause'] ?? '-'}
💬 *Keterangan:* ${rpt['notes'] ?? '-'}
🛠️ *Dukungan:* $supportLabel

Untuk proses tindak lanjut, silakan klik link berikut:
🔗 Buka Aplikasi: $deepLinkUrl''';

              final photos = _extractPhotoUrls(rpt['photos']);
              final plainText = waText.replaceAllMapped(
                RegExp(r'IconData\([^\)]*\)'),
                (_) => '',
              );
              if (photos.isNotEmpty) {
                ShareHelper.shareNetworkImage(
                  context: context,
                  imageUrl: photos.first,
                  caption: plainText,
                );
              } else {
                SharePlus.instance.share(
                  ShareParams(text: plainText),
                );
              }
            },
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: controller.refresh,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 140),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TaskDetailHeroCard(task: task),
                    const SizedBox(height: 24),
                    Text("Informasi Laporan", style: AppTypography.h3),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: _buildInfoCard(PhosphorIcons.mapPin(),
                                'Lokasi',
                                (rpt['area_name']?.toString().trim().isNotEmpty ==
                                            true)
                                        ? rpt['area_name'].toString().trim()
                                        : (rpt['areaName']
                                                    ?.toString()
                                                    .trim()
                                                    .isNotEmpty ==
                                                true)
                                            ? rpt['areaName'].toString().trim()
                                            : task.area)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildRiskLevelCard(task.riskLevel),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(PhosphorIcons.clock(), 'Waktu Dilaporkan',
                        _formatDate(task.date)),
                    const SizedBox(height: 24),
                    _buildSectionBox(
                        'Catatan Temuan',
                        task.notes,
                        PhosphorIcons.notePencil()),
                    const SizedBox(height: 16),
                    _buildSectionBox(
                        'Akar Masalah (Root Cause)',
                        task.rootCause,
                        PhosphorIcons.treeStructure()),
                    if (task.status == TaskStatus.canceled &&
                        ((rpt['cancel_notes']?.toString().trim().isNotEmpty ==
                                true) ||
                            (rpt['cancelNotes']
                                    ?.toString()
                                    .trim()
                                    .isNotEmpty ==
                                true))) ...[
                      const SizedBox(height: 16),
                      _buildSectionBox(
                        'Catatan Pembatalan',
                        (rpt['cancel_notes']?.toString().trim().isNotEmpty ==
                                true)
                            ? rpt['cancel_notes'].toString().trim()
                            : rpt['cancelNotes'].toString().trim(),
                        PhosphorIcons.xCircle(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (task.photos.isNotEmpty) ...[
                      Text("Lampiran Bukti", style: AppTypography.h3),
                      const SizedBox(height: 12),
                      _buildPhotoGrid(task.photos),
                    ],
                    const SizedBox(height: 32),
                    if (logs.isNotEmpty) ...[
                      Text("Riwayat Tindak Lanjut", style: AppTypography.h3),
                      const SizedBox(height: 16),
                      TaskTimelineSection(
                        logs: logs,
                        picUserMap: picUserMap,
                        currentUser: user,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            TaskDetailBottomActions(
              task: task,
              controller: controller,
              isPic: isPic,
              canCancel: canCancel,
              canReviewFollowUp: canReviewFollowUp,
              canStartPicFollowUp: canStartPicFollowUp,
              isWaitingPicResponse: isWaitingPicResponse,
              isSubmitting: isSubmitting,
              rawStatusLower: rawStatusLower,
              taskId: widget.taskId,
              ref: ref,
              onShowReasonSheet: _showReasonSheet,
              onShowApproveDialog: _showApproveDialog,
            )
          ],
        ),
      ),
    );
  }



  Future<String?> _showReasonSheet({required bool isCancel}) async {
    final controller = TextEditingController();

    return showModalBottomSheet<String>(
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
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
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
                              style: AppTypography.body1.copyWith(
                                color: AppColors.textSecondary,
                              ),
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
  }

  Future<bool> _showApproveDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
            title: Text('Terima Perbaikan?', style: AppTypography.h3),
            content: Text(
              'Apakah Anda yakin tindak lanjut sudah sesuai standar?',
              style: AppTypography.body1
                  .copyWith(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Batal',
                  style: AppTypography.body1
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Ya, Terima',
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textInverted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
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


  Widget _buildRiskLevelCard(RiskLevel riskLevel) {
    final label = riskLevel.label;
    final Color color;
    final IconData iconData;

    switch (riskLevel) {
      case RiskLevel.immediate:
        color = AppColors.riskLevel4;
        iconData = HugeIcons.strokeRoundedTimer01;
      case RiskLevel.within24Hours:
        color = AppColors.riskLevel3;
        iconData = HugeIcons.strokeRoundedTime01;
      case RiskLevel.within3Days:
        color = AppColors.riskLevel2;
        iconData = HugeIcons.strokeRoundedCalendar03;
      case RiskLevel.within2Weeks:
        color = AppColors.riskLevel1;
        iconData = HugeIcons.strokeRoundedCalendar03;
      case RiskLevel.unknown:
        color = AppColors.textSecondary;
        iconData = HugeIcons.strokeRoundedAlert02;
    }

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
          Text(
            'Tingkat Risiko',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
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

  Widget _buildPhotoGrid(List<String> paths) {
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

  // Timeline UI extracted to TaskTimelineSection widget
  // Photo grid and image preview kept for main body photo section








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
    debugPrint('[TaskDetailScreen] Back pressed, user: ${user?.name} (${user?.role})');

    // Coba pop dulu untuk normal flow (masuk dari list screen)
    if (Navigator.of(context).canPop()) {
      debugPrint('[TaskDetailScreen] Popping navigator');
      context.pop();
    } else {
      // Jika tidak bisa pop (akses via deeplink), redirect ke home sesuai role
      debugPrint('[TaskDetailScreen] Cannot pop, navigating to home');
      _navigateToHome(user);
    }
  }

  void _navigateToHome(UserModel? user) {
    final homeRouteName =
        resolveHomeRouteName(user?.role ?? UserRole.petugasHse);

    debugPrint(
      '[TaskDetailScreen] Navigating to home routeName=$homeRouteName (role: ${user?.role})',
    );

    try {
      if (mounted) {
        context.goNamed(homeRouteName);
      }
    } catch (e) {
      debugPrint('[TaskDetailScreen] Error navigating to home: $e');
      if (mounted) {
        try {
          context.pushReplacementNamed(homeRouteName);
        } catch (e2) {
          debugPrint('[TaskDetailScreen] Error with pushReplacement: $e2');
          if (mounted) {
            context.pushNamed(homeRouteName);
          }
        }
      }
    }
  }
}
