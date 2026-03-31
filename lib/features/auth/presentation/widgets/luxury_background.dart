import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class LuxuryBackground extends StatelessWidget {
  const LuxuryBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F1419), // Dark charcoal - lebih light
            Color(0xFF1A1D2E), // Dark navy
            Color(0xFF0D1117), // Deep dark
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Top left glow
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.08),
              ),
            ),
          ),
          // Bottom right glow
          Positioned(
            bottom: -120,
            right: -120,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
