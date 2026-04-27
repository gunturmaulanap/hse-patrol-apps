import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/theme/app_typography.dart';

class AreaCard extends StatelessWidget {
  final String areaName;
  final String? areaDescription;
  final int pendingCount;
  final int waitingResponseCount;
  final int totalTasks;
  final int index;
  final VoidCallback onTap;

  const AreaCard({
    super.key,
    required this.areaName,
    this.areaDescription,
    required this.pendingCount,
    required this.waitingResponseCount,
    required this.totalTasks,
    required this.index,
    required this.onTap,
  });

  Color _getColorByIndex(int index) {
    final colors = [
      const Color(0xFFD4D8FF), // Soft Purple
      const Color(0xFFFAFF9F), // Soft Yellow
      const Color(0xFFC1F0D0), // Soft Mint Green
      const Color(0xFFFFD4D4), // Soft Pink
      const Color(0xFFD4F0FF), // Soft Blue
      const Color(0xFFFFE4B5), // Soft Peach
      const Color(0xFFE5E5E5), // Soft Gray
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getColorByIndex(index);
    final stripeColor = Colors.black.withValues(alpha: 0.05);
    final textColor = const Color(0xFF1E1E1E);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF1E1E1E), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _AreaCardStripedPainter(color: stripeColor),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(PhosphorIcons.buildings(PhosphorIconsStyle.fill), size: 20, color: textColor),
                      ),
                        Icon(PhosphorIcons.arrowUpRight(PhosphorIconsStyle.bold), size: 20, color: textColor.withValues(alpha: 0.5)),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  Text(
                    areaDescription != null && areaDescription!.trim().isNotEmpty
                        ? areaDescription!.trim()
                        : areaName,
                    style: AppTypography.h2.copyWith(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$totalTasks Total Inspections',
                    style: AppTypography.caption.copyWith(
                      color: textColor.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Kumpulan Badge Status
                  _buildStatusBadges(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi khusus untuk merender kombinasi badge
  Widget _buildStatusBadges() {
    debugPrint(
      '[AreaCard] area=$areaName pending=$pendingCount waiting=$waitingResponseCount total=$totalTasks',
    );

    if (pendingCount == 0 && waitingResponseCount == 0) {
      // Kondisi ALL CLEAR
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: Colors.green[700], size: 14),
              const SizedBox(width: 4),
              Text(
                'All Clear',
                style: AppTypography.caption.copyWith(
                  color: const Color(0xFF1E1E1E),
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Kondisi memiliki Pending atau Waiting atau keduanya
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge Action Needed
        if (pendingCount > 0)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), color: Colors.redAccent, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$pendingCount Action Needed',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFF1E1E1E),
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Badge Waiting Response
        if (waitingResponseCount > 0)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(PhosphorIcons.clock(PhosphorIconsStyle.fill), color: Colors.orange, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$waitingResponseCount Waiting...',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFF1E1E1E),
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _AreaCardStripedPainter extends CustomPainter {
  final Color color;
  _AreaCardStripedPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    const double space = 8.0;
    for (double i = -size.height; i < size.width; i += space) {
      canvas.drawLine(Offset(i, size.height), Offset(i + size.height, 0), paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
