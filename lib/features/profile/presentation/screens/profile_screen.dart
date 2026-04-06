import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Controller untuk form password
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State untuk toggle hide/show password
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isUpdatingPassword = false;

  String _cleanErrorMessage(Object error) {
    final raw = error.toString();
    if (raw.startsWith('Exception: ')) {
      return raw.replaceFirst('Exception: ', '').trim();
    }
    return raw;
  }

  Future<void> _submitChangePassword() async {
    if (_isUpdatingPassword) return;

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      AppSnackBar.warning(
        context,
        message: 'Semua field password wajib diisi.',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      AppSnackBar.warning(
        context,
        message: 'Konfirmasi password baru tidak cocok.',
      );
      return;
    }

    setState(() {
      _isUpdatingPassword = true;
    });

    try {
      debugPrint('[ProfileScreen] before call changePassword()');

      final authRepository = ref.read(authRepositoryProvider);
      final message = await authRepository.changePassword(
        currentPassword,
        newPassword,
        confirmPassword,
      );

      if (!mounted) return;

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      FocusScope.of(context).unfocus();

      AppSnackBar.success(
        context,
        message: message,
      );
    } catch (e) {
      if (!mounted) return;

      AppSnackBar.error(
        context,
        message: _cleanErrorMessage(e),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingPassword = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data user yang sedang aktif
    final user = ref.watch(currentUserProvider);

    // Redirect ke login jika user null (setelah hot restart)
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

    final isPetugas = user.role == UserRole.petugasHse;
    final isSupervisor = user.role == UserRole.hseSupervisor;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }

            if (isPetugas) {
              context.goNamed(RouteNames.petugasHome);
              return;
            }

            if (isSupervisor) {
              context.goNamed(RouteNames.supervisorHome);
              return;
            }

            context.goNamed(RouteNames.picHome);
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
              // --- 1. SECTION: ICON USER & INFO ---
              const SizedBox(height: 16),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Warna background disesuaikan dengan role
                  color: isPetugas ? const Color(0xFFFAFF9F) : const Color(0xFFC1F0D0),
                  border: Border.all(color: AppColors.surface, width: 4),
                ),
                child: Center(
                  child: Icon(
                    PhosphorIcons.user(PhosphorIconsStyle.bold), 
                    color: const Color(0xFF1E1E1E), 
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Nama User
              Text(
                user.name.toUpperCase(),
                style: AppTypography.h1.copyWith(fontSize: 26, letterSpacing: -0.5),
              ),
              const SizedBox(height: 12),

              // Badge Role
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isPetugas ? const Color(0xFFFAFF9F) : const Color(0xFFC1F0D0),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: const Color(0xFF1E1E1E), width: 1.5),
                ),
                child: Text(
                  user.role.name.toUpperCase(),
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFF1E1E1E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // --- 2. SECTION: CHANGE PASSWORD FORM ---
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Change Password',
                  style: AppTypography.h3.copyWith(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),

              _buildPasswordField(
                label: 'Current Password',
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                onToggleVisibility: () {
                  setState(() => _obscureCurrent = !_obscureCurrent);
                },
              ),
              const SizedBox(height: 16),
              
              _buildPasswordField(
                label: 'New Password',
                controller: _newPasswordController,
                obscureText: _obscureNew,
                onToggleVisibility: () {
                  setState(() => _obscureNew = !_obscureNew);
                },
              ),
              const SizedBox(height: 16),
              
              _buildPasswordField(
                label: 'Confirm New Password',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                onToggleVisibility: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
              ),
              const SizedBox(height: 28),

              // Tombol Update Password
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E1E), // Bisa diganti AppColors.primary
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  onPressed: () {
                    _submitChangePassword();
                  },
                  child: _isUpdatingPassword
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Update Password',
                          style: AppTypography.body1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // --- 3. SECTION: LOGOUT BUTTON ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      side: const BorderSide(color: Colors.redAccent, width: 1.5),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final authNotifier = ref.read(authNotifierProvider.notifier);
                      await authNotifier.logout();

                      if (!context.mounted) return;
                      context.goNamed(RouteNames.login);
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Logout dilakukan secara lokal. Error: ${e.toString()}'),
                          backgroundColor: AppColors.statusRejected,
                        ),
                      );
                      context.goNamed(RouteNames.login);
                    }
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

  // Helper Widget untuk Form Password
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: AppTypography.body1.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: AppTypography.body1.copyWith(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF1E1E1E), width: 1.5),
            ),
            prefixIcon: Icon(PhosphorIcons.lock(PhosphorIconsStyle.regular), color: AppColors.textSecondary, size: 22),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText 
                  ? PhosphorIcons.eyeClosed(PhosphorIconsStyle.regular) 
                  : PhosphorIcons.eye(PhosphorIconsStyle.regular),
                color: AppColors.textSecondary,
                size: 22,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }
}
