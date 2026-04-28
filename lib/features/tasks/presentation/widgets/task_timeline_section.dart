import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../auth/domain/auth_role_helper.dart';
import '../../../auth/data/models/user_model.dart';

class TaskTimelineSection extends StatelessWidget {
  const TaskTimelineSection({
    super.key,
    required this.logs,
    required this.picUserMap,
    required this.currentUser,
  });

  final List<dynamic> logs;
  final Map<int, String> picUserMap;
  final UserModel? currentUser;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(logs.length, (index) {
        final log = logs[index] as Map<String, dynamic>;
        final isLast = index == logs.length - 1;
        final action = log['action']?.toString().toLowerCase();

        bool isPicLog = true;
        Color dotColor = AppColors.primary;
        String actionLabel = 'Respon PIC';

        if (action == 'approved' || action == 'completed') {
          isPicLog = false;
          dotColor = Colors.green;
          actionLabel = 'Review Petugas';
        } else if (action == 'rejected') {
          isPicLog = false;
          dotColor = Colors.redAccent;
          actionLabel = 'Review Petugas';
        } else if (action == 'canceled' || action == 'cancelled') {
          isPicLog = false;
          dotColor = Colors.redAccent;
          actionLabel = 'Laporan Dibatalkan';
        } else if (action == 'followed_up' || action == 'follow up done' || action == 'follow_up_done') {
          actionLabel = 'Respon PIC';
        }

        // Ambil user ID dari berbagai field yang mungkin
        final userIdRaw = log['user_id'] ??
                          log['userId'] ??
                          log['pic_id'] ??
                          log['picId'] ??
                          log['created_by'] ??
                          log['createdBy'];

        // Coba ambil nama dari picUserMap jika userId ada
        String? resolvedName;
        final roleName = _firstNonEmptyString([
          log['role_name'],
          log['roleName'],
          log['user_role_name'],
          log['userRoleName'],
        ]);

        if (userIdRaw != null) {
          final userId = int.tryParse(userIdRaw.toString());
          if (userId != null) {
            resolvedName = picUserMap[userId];
          }
        }

        String? displayName = resolvedName;

        final isReviewAction =
            action == 'approved' || action == 'rejected' || action == 'completed';
        final isCancelAction = action == 'canceled' || action == 'cancelled';

        if (displayName == null || displayName.isEmpty) {
          if (isReviewAction) {
            displayName = log['approval_by']?.toString() ??
                log['approvalBy']?.toString() ??
                log['reviewed_by']?.toString() ??
                log['reviewedBy']?.toString() ??
                log['user_name']?.toString() ??
                log['userName']?.toString() ??
                log['created_by']?.toString() ??
                log['createdBy']?.toString() ??
                log['name']?.toString() ??
                log['user']?.toString() ??
                log['staff_name']?.toString() ??
                log['staffName']?.toString();
          } else if (isCancelAction) {
            displayName = log['canceled_by_name']?.toString() ??
                log['cancelled_by_name']?.toString() ??
                log['canceledByName']?.toString() ??
                log['cancelledByName']?.toString() ??
                log['created_by']?.toString() ??
                log['createdBy']?.toString() ??
                log['user_name']?.toString() ??
                log['userName']?.toString() ??
                log['name']?.toString() ??
                log['user']?.toString() ??
                log['staff_name']?.toString() ??
                log['staffName']?.toString();
          } else {
            displayName = log['created_by']?.toString() ??
                log['createdBy']?.toString() ??
                log['pic_name']?.toString() ??
                log['picName']?.toString() ??
                log['user_name']?.toString() ??
                log['userName']?.toString() ??
                log['name']?.toString() ??
                log['user']?.toString() ??
                log['staff_name']?.toString() ??
                log['staffName']?.toString();
          }
        }

        // Jika masih kosong dan action bukan review, coba cari actor dari log sebelumnya.
        if ((displayName == null || displayName.isEmpty) && !isReviewAction) {
          for (int i = index - 1; i >= 0; i--) {
            final prevLog = logs[i] as Map<String, dynamic>;
            final prevPicName = prevLog['pic_name']?.toString() ??
                               prevLog['picName']?.toString() ??
                               prevLog['pic']?.toString() ??
                               prevLog['created_by']?.toString() ??
                               prevLog['createdBy']?.toString() ??
                               prevLog['user_name']?.toString() ??
                               prevLog['name']?.toString();
            if (prevPicName != null && prevPicName.isNotEmpty) {
              displayName = prevPicName;
              break;
            }
          }
        }

        // Fallback khusus review log: prioritaskan user login saat ini
        if ((displayName == null || displayName.isEmpty) &&
            (action == 'approved' || action == 'rejected' || action == 'completed')) {
          final reviewerName = currentUser?.name.trim();
          if (reviewerName != null && reviewerName.isNotEmpty) {
            displayName = reviewerName;
          }
        }

        // Fallback terakhir: gunakan userId jika ada
        if (displayName == null || displayName.isEmpty) {
          if (userIdRaw != null) {
            final userId = int.tryParse(userIdRaw.toString());
            if (userId != null) {
              displayName = 'User #$userId';
            }
          }
        }

        final picActorNameForLabel = _firstNonEmptyString([
          log['created_by'],
          log['createdBy'],
        ]);

        if (isPicLog && picActorNameForLabel.isNotEmpty) {
          actionLabel = 'Respon $picActorNameForLabel';
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (!isLast)
                const Positioned(
                  left: 7,
                  top: 16,
                  bottom: -24,
                  child: SizedBox(
                    width: 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.border),
                    ),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(width: 16),
                  Expanded(
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
                        actionLabel,
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: dotColor,
                        ),
                      ),
                      if (displayName != null && displayName.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
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
                                      displayName,
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
                            if (isEngineerRoleName(roleName) ||
                                isHrgaRoleName(roleName))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isEngineerRoleName(roleName)
                                          ? Icons.engineering_rounded
                                          : Icons.people_alt_rounded,
                                      size: 12,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isEngineerRoleName(roleName)
                                          ? 'Support Engineer'
                                          : 'Support HRGA',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
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
                      if (isReviewAction) ...[
                        if (log['notes_hse'] != null &&
                            log['notes_hse'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            log['notes_hse'].toString(),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        if ((log['notes_hse'] == null ||
                                log['notes_hse'].toString().isEmpty) &&
                            log['notes'] != null &&
                            log['notes'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            log['notes'].toString(),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        if (log['created_by'] != null ||
                            log['notes_pic'] != null ||
                            log['action'] != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      PhosphorIcons.arrowUUpLeft(
                                        PhosphorIconsStyle.thin,
                                      ),
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Tindakan Lanjut PIC',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (log['created_by'] != null) ...[
                                  Text(
                                    log['created_by'].toString(),
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                if (log['notes_pic'] != null &&
                                    log['notes_pic'].toString().isNotEmpty) ...[
                                  Text(
                                    log['notes_pic'].toString(),
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ] else if (isPicLog) ...[
                        if (log['notes_pic'] != null &&
                            log['notes_pic'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            log['notes_pic'].toString(),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                        if ((log['notes_pic'] == null ||
                                log['notes_pic'].toString().isEmpty) &&
                            log['notes'] != null &&
                            log['notes'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            log['notes'].toString(),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ] else ...[
                        if (log['notes'] != null &&
                            log['notes'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(log['notes'].toString(),
                              style: AppTypography.caption),
                        ],
                      ],
                          if (_extractPhotoUrls(log['photos']).isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildPhotoGrid(
                              context,
                              _extractPhotoUrls(log['photos']),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  static String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final date = DateTime.parse(raw);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return raw;
    }
  }

  static List<String> _extractPhotoUrls(dynamic photosRaw) {
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

  static String _firstNonEmptyString(List<dynamic> values,
      {String fallback = ''}) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        return text;
      }
    }

    return fallback;
  }

  static Widget _buildPhotoGrid(BuildContext context, List<String> paths) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: paths.length,
      itemBuilder: (ctx, index) {
        final url = paths[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _showImagePreview(context, url),
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

  static void _showImagePreview(BuildContext context, String url) {
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
}
