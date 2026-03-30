import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/mock_api/mock_auth_service.dart';
import '../../../../core/mock_api/mock_database.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulasi loading API
    await Future.delayed(const Duration(seconds: 1));

    final authService = ref.read(mockAuthServiceProvider);
    final user = authService.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        ref.read(currentUserProvider.notifier).state = user;
        
        if (user.role == 'petugas') {
          context.goNamed(RouteNames.petugasHome);
        } else if (user.role == 'pic') {
          context.goNamed(RouteNames.picHome);
        }
      } else {
        setState(() {
          _errorMessage = 'Username atau password salah.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo or Icon Placeholder
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedLicense,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'HSE Aksamala',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                ),
                Text(
                  'Sistem Pelaporan Kerusakan Bangunan',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Login Form (Modern Dark Flow)
                Text(
                  'Masuk',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 28,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Gunakan akun Petugas atau PIC untuk melanjutkan.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xl),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.statusRejected.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.borderSm),
                      border: Border.all(color: AppColors.statusRejected),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.statusRejected, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                AppTextField(
                  label: 'Username',
                  hint: 'Masukkan username',
                  controller: _usernameController,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Password',
                  hint: 'Masukkan password',
                  controller: _passwordController,
                  obscureText: true,
                  maxLines: 1,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: 'Login',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Petunjuk Master User (Border only style)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.surfaceVariant),
                    borderRadius: BorderRadius.circular(AppRadius.borderMd),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AKUN SIMULASI:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.primary, letterSpacing: 1.5)),
                      SizedBox(height: 8),
                      Text('Petugas: petugas / 123', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                      Text('PIC: pic / 123', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
