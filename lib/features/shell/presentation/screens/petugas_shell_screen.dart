import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';

class PetugasShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PetugasShellScreen({
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
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0), // Full extend ke bawah
              child: navigationShell,
            ),
          ),

          Positioned(
            bottom: 24,
            // PERUBAHAN: Dibuat 0 kiri dan kanan agar bisa centering otomatis
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                height: 62,
                padding: const EdgeInsets.symmetric(horizontal: 16), // Padding diperlebar agar seimbang
                decoration: BoxDecoration(
                  color: AppColors.surface, // Single background layer
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3), // Shadow elevation
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  // PERUBAHAN: Memastikan Row tidak membentang penuh (shrink-wrap)
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  _buildNavItem(
                      iconPath: 'lib/assets/tasks.svg',
                      index: 1,
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => context.pushNamed(RouteNames.petugasCreateTask),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          // Warna button berubah berdasarkan active tab
                          color: navigationShell.currentIndex == 0
                              ? AppColors.primary // Kuning ketika di Calendar
                              : AppColors.secondary, // Ungu ketika di Tasks
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
                    _buildNavItem(
                      iconPath: 'lib/assets/calendar.svg',
                      index: 0,
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
}