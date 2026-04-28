import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';

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
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                height: 62,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Kiri: Home Icon (HugeIcons)
                    _buildHomeNavItem(
                      index: 0,
                    ),
                    const SizedBox(width: 16),
                    // Tengah: Add Button
                    GestureDetector(
                      onTap: () => context.pushNamed(RouteNames.picCreateTask),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          // Warna button berubah berdasarkan active tab
                          color: navigationShell.currentIndex == 1
                              ? AppColors.primary // Kuning ketika di Tasks
                              : AppColors.secondary, // Ungu ketika di Home
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: AppColors.textInverted.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'lib/assets/add_bold.svg',
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                            colorFilter: const ColorFilter.mode(
                              AppColors.textInverse,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Kanan: Tasks Icon (SVG)
                    _buildNavItem(
                      iconPath: 'lib/assets/tasks.svg',
                      index: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String iconPath,
    required int index,
  }) {
    final isActive = navigationShell.currentIndex == index;

    return InkWell(
      onTap: () => _goBranch(index),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: SizedBox(
        width: 50,
        height: 54,
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 32,
            height: 32,
            colorFilter: ColorFilter.mode(
              isActive ? AppColors.textPrimary : AppColors.textSecondary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeNavItem({
    required int index,
  }) {
    final isActive = navigationShell.currentIndex == index;

    return InkWell(
      onTap: () => _goBranch(index),
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: SizedBox(
        width: 50,
        height: 54,
        child: Center(
          child: SvgPicture.asset(
            'lib/assets/home.svg',
            width: 32,
            height: 32,
            colorFilter: ColorFilter.mode(
              isActive ? AppColors.secondary : AppColors.textSecondary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
