import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/mock_api/mock_database.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mengambil data user yang sedang aktif
    final user = ref.watch(currentUserProvider);

    // FIX: Redirect ke login jika user null (setelah hot restart)
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.goNamed(RouteNames.login);
        }
      });
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isPetugas = user.role == 'petugas';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () {
            // Kembali ke home yang sesuai dengan role
            context.goNamed(isPetugas ? RouteNames.petugasHome : RouteNames.picHome);
          },
        ),
        title: Text('My Profile', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- 1. SECTION: AVATAR & INFO ---
              const SizedBox(height: 24),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD4D8FF), // Pastel Purple
                      border: Border.all(color: AppColors.surface, width: 4),
                      image: DecorationImage(
                        image: NetworkImage(
                          isPetugas 
                              ? 'https://i.pravatar.cc/150?img=11' 
                              : 'https://i.pravatar.cc/150?img=12'
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Icon Pensil kecil (Edit Photo)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.bold), color: Colors.white, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Nama User
              Text(
                user.username.toUpperCase(),
                style: AppTypography.h1.copyWith(fontSize: 26, letterSpacing: -0.5),
              ),
              const SizedBox(height: 12),

              // Badge Role (Warna berbeda untuk PIC dan Petugas)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isPetugas ? const Color(0xFFFAFF9F) : const Color(0xFFC1F0D0),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: const Color(0xFF1E1E1E), width: 1.5),
                ),
                child: Text(
                  user.role.toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFF1E1E1E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // --- 2. SECTION: MENU OPTIONS ---
              _buildMenuItem(
                icon: PhosphorIcons.userCircle(),
                title: 'Personal Details',
                subtitle: 'Update your personal info',
                color: const Color(0xFFD4D8FF), // Soft Purple
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                icon: PhosphorIcons.bellRinging(),
                title: 'Notifications',
                subtitle: 'Manage your alerts',
                color: const Color(0xFFFAFF9F), // Soft Yellow
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                icon: PhosphorIcons.shieldCheck(),
                title: 'Privacy & Security',
                subtitle: 'Password and access',
                color: const Color(0xFFC1F0D0), // Soft Mint
                onTap: () {},
              ),
              
              const SizedBox(height: 48),
              
              // --- 3. SECTION: LOGOUT BUTTON ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD4D4), // Pastel Red Background
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    ),
                  ),
                  onPressed: () async {
                    // Membersihkan state user saat logout
                    ref.read(currentUserProvider.notifier).state = null;

                    // Membersihkan secure storage
                    // Note: Untuk mock API, kita hanya clear in-memory
                    // Di production, gunakan: await SessionManager().clearToken();

                    // Kembali ke halaman Login dengan mengganti stack
                    context.goNamed(RouteNames.login);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(PhosphorIcons.signOut(PhosphorIconsStyle.bold), color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sign Out',
                        style: AppTypography.body1.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Custom Widget untuk List Menu
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surfaceLight, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFF1E1E1E), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(PhosphorIcons.caretRight(PhosphorIconsStyle.bold), color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}