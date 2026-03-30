import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';

class PicShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PicShellScreen({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Konten Utama
          Positioned.fill(
            child: navigationShell,
          ),

          // Floating Bottom Navigation
          Positioned(
            bottom: 30,
            left: 40,
            right: 40,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    icon: HugeIcons.strokeRoundedHome01,
                    activeIcon: HugeIcons.strokeRoundedHome02,
                    index: 0,
                    label: 'Home',
                  ),
                  _buildNavItem(
                    icon: HugeIcons.strokeRoundedNote01,
                    activeIcon: HugeIcons.strokeRoundedNote,
                    index: 1,
                    label: 'Finding',
                  ),
                  _buildNavItem(
                    icon: HugeIcons.strokeRoundedUser02,
                    activeIcon: HugeIcons.strokeRoundedUser,
                    index: 2,
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required int index,
    required String label,
  }) {
    final isActive = navigationShell.currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _goBranch(index),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          height: 65,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
