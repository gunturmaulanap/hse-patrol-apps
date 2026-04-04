import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/mock_api/mock_database.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/share_helper.dart';
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

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> with AutomaticKeepAliveClientMixin {
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

  bool _canCancelTask(Map<String, dynamic> rpt, dynamic user) {
    if (user == null || rpt.isEmpty) return false;
    
    final status = (rpt['status']?.toString() ?? '').toLowerCase();
    if (status != 'pending') return false;

    final role = user.role;
    final currentUserId = int.tryParse(user.id ?? '');
    final reportOwnerId = int.tryParse(rpt['userId']?.toString() ?? '');

    if (role == 'supervisor') return true;
    if (role == 'petugas' && currentUserId == reportOwnerId) return true;

    return false;
  }

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
          title: Text(isCancel ? 'Batalkan Laporan?' : 'Tolak Perbaikan', style: AppTypography.h3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCancel)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Apakah Anda yakin ingin membatalkan laporan ini? Laporan yang dibatalkan tidak dapat dikembalikan.',
                    style: AppTypography.body1.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              // Label dengan indikator wajib
              if (isCancel)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(
                        'Alasan Pembatalan',
                        style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        ' *',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Alasan Penolakan',
                    style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
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
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Kembali', style: AppTypography.body1.copyWith(color: AppColors.textSecondary))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCancel ? Colors.redAccent : Colors.orangeAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
              ),
              onPressed: () {
                // Validasi: Notes wajib diisi untuk CANCEL dan REJECT
                if (controller.text.trim().isEmpty) {
                  AppToast.warning(
                    ctx,
                    message: isCancel
                        ? 'Alasan pembatalan wajib diisi!'
                        : 'Alasan penolakan wajib diisi!',
                  );
                  return;
                }

                // Konfirmasi tambahan untuk cancel
                if (isCancel) {
                  Navigator.pop(ctx, controller.text.trim());
                } else {
                  Navigator.pop(ctx, controller.text.trim());
                }
              },
              child: Text(isCancel ? 'Ya, Batalkan' : 'Tolak', style: AppTypography.body1.copyWith(color: Colors.white, fontWeight: FontWeight.bold))
            ),
          ],
        ),
      );

      if (reason == null || reason!.trim().isEmpty) return;
      
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
        final latestFollowUp = followUps.last as Map<String, dynamic>;
        final followUpId = latestFollowUp['id'] as int?;

        if (followUpId != null) {
          final followUpRepo = ref.read(followUpRepositoryProvider);
          final approval = action.toLowerCase();

          final taskId = rpt['id'] as int?;
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
        final taskId = rpt['id'] as int?;
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
          : (action == 'Rejected' ? 'Perbaikan ditolak!' : 'Laporan berhasil dibatalkan!');

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
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
            onPressed: () => context.pop(),
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
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20), onPressed: () => context.pop()),
          title: Text('Detail', style: AppTypography.h3),
        ),
        body: Center(child: Text('Laporan tidak ditemukan.', style: AppTypography.body1)),
      );
    }

    final isPic = user?.role == 'pic';
    final isSupervisor = user?.role == 'supervisor';
    final isPetugas = user?.role == 'petugas';
    
    final status = rpt['status']?.toString() ?? 'Pending';
    final rawStatusLower = status.toLowerCase();
    
    final canCancel = _canCancelTask(rpt, user);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20), onPressed: () => context.pop()),
        title: Text('Task Detail', style: AppTypography.h3),
        centerTitle: true,
        actions: [
          // TOMBOL SHARE IMPLEMENTASI BARU
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.primary),
            onPressed: () {
              final waText = '''🚨 *DETAIL TEMUAN HSE* 🚨
📍 *Area:* ${rpt['area'] ?? '-'}
⚠️ *Tingkat Risiko:* ${rpt['riskLevel'] ?? '-'}
💬 *Catatan:* ${rpt['notes'] ?? '-'}

🔗 Buka di Aplikasi: https://mes.aksamala.co.id/share/report/${widget.picToken ?? widget.taskId}''';

              final photos = rpt['photos'] as List?;
              if (photos != null && photos.isNotEmpty) {
                // Share menggunakan network helper untuk gambar dari backend API
                ShareHelper.shareNetworkImage(
                  context: context,
                  imageUrl: photos.first.toString(), 
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
                    _buildPhotoGrid(List<String>.from(rpt['photos'] as List)),
                  ],

                  const SizedBox(height: 32),
                  if (rpt['followUps'] != null && (rpt['followUps'] as List).isNotEmpty) ...[
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
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (canCancel)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppButton(
                            text: 'Batalkan Laporan',
                            isLoading: _isSubmitting,
                            type: AppButtonType.outlined,
                            onPressed: () => _handlePetugasReview(rpt, 'Canceled'),
                          ),
                        ),

                      if (isPic && (rawStatusLower == 'pending' || rawStatusLower == 'rejected'))
                        AppButton(
                          text: 'Mulai Tindak Lanjut',
                          isLoading: _isSubmitting,
                          onPressed: () {
                            ref.read(picFollowUpFormProvider.notifier).setReportId(widget.taskId);
                            context.pushNamed(RouteNames.picFollowUpPhotos);
                          },
                        )
                      
                      else if ((isPetugas || isSupervisor) && rawStatusLower == 'follow up done')
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                text: 'Tolak',
                                type: AppButtonType.outlined,
                                isLoading: _isSubmitting,
                                onPressed: () => _handlePetugasReview(rpt, 'Rejected'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppButton(
                                text: 'Terima',
                                isLoading: _isSubmitting,
                                onPressed: () => _handlePetugasReview(rpt, 'Approved'),
                              ),
                            ),
                          ],
                        )
                        
                      else if (!canCancel)
                        AppButton(
                          text: rawStatusLower == 'completed' ? 'Laporan Selesai' : 'Menunggu Respon',
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
      case 'pending': bgColor = const Color(0xFFD4D8FF); break;
      case 'follow up done': bgColor = const Color(0xFFFAFF9F); break;
      case 'pending rejected': bgColor = const Color(0xFFFFCDD2); break;
      case 'completed': bgColor = const Color(0xFFC1F0D0); break;
      case 'canceled': bgColor = const Color(0xFF1E1E1E); break;
      default: bgColor = const Color(0xFFFFFFFF);
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  rawStatus == 'canceled' ? 'DIBATALKAN' : status.toUpperCase(), 
                  style: AppTypography.caption.copyWith(color: textColor, fontWeight: FontWeight.bold),
                ),
              ),
              PhosphorIcon(
                rawStatus == 'canceled' ? PhosphorIcons.xCircle(PhosphorIconsStyle.fill) : PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill), 
                color: textColor, 
                size: 32
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(rpt['title']?.toString() ?? 'Inspeksi Rutin', style: AppTypography.h2.copyWith(color: textColor, height: 1.2)),
          const SizedBox(height: 12),
          Text('Dilaporkan oleh: ${rpt['staffName']?.toString() ?? 'HSE Officer'}', style: AppTypography.body1.copyWith(color: textColor.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, {Color? iconColor}) {
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
            decoration: BoxDecoration(color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionBox(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.body1.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: paths.length,
      itemBuilder: (context, index) {
        final url = paths[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: url.startsWith('http')
              ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image, color: Colors.grey)))
              : Image.file(File(url), fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image, color: Colors.grey))),
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
                if (!isLast) Container(width: 2, height: 72, color: AppColors.border),
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
                        _formatDate(log['date']?.toString()),
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            isPicLog ? 'Respon PIC' : 'Review Petugas',
                            style: AppTypography.body1.copyWith(
                              fontWeight: FontWeight.bold,
                              color: dotColor,
                            ),
                          ),
                          if (isPicLog && picName != null && picName.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                picName,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (action != null && action.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${action.toUpperCase()}',
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                      if (log['notes'] != null && log['notes'].toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(log['notes'].toString(), style: AppTypography.caption),
                      ],
                      if (isPicLog && log['photos'] != null && (log['photos'] as List).isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildPhotoGrid(List<String>.from(log['photos'] as List), height: 60),
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
}