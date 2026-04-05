import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../shared/enums/user_role.dart';
import '../providers/auth_provider.dart';
import '../../../../core/mock_api/mock_database.dart';
import '../../data/models/user_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  // State untuk toggle hide/show password
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _errorMessage = null;
    });

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email dan password harus diisi.';
      });
      return;
    }

    try {
      debugPrint('[LoginScreen] submit login for email: $email');
      final success = await authNotifier.login(email, password);

      if (mounted) {
        if (success) {
          // Fetch user data to determine role and navigate
          UserModel? user;
          try {
            debugPrint('[LoginScreen] before call /me');
            final authRepository = ref.read(authRepositoryProvider);
            user = await authRepository.getMe();
            debugPrint('[LoginScreen] /me result: ${user.toJson()}');
          } catch (e, st) {
            debugPrint('[LoginScreen] /me failed: $e');
            debugPrint('[LoginScreen] /me stacktrace: $st');

            user = ref.read(authNotifierProvider).user;
            debugPrint('[LoginScreen] fallback user from auth state: ${user?.toJson()}');
          }

          if (user == null) {
            setState(() {
              _errorMessage = 'Login berhasil, tetapi data user tidak tersedia.';
            });
            return;
          }

          // Set mock user for compatibility with existing UI
          final mockUser = MockUser(
            id: user.id.toString(),
            username: user.name,
            email: user.email,
            password: '', // Not needed from backend
            role: user.role == UserRole.pic
                ? 'pic'
                : user.role == UserRole.hseSupervisor
                    ? 'supervisor'
                    : 'petugas',
            areaAccess: user.areaAccess,
          );
          ref.read(currentUserProvider.notifier).state = mockUser;

          if (!mounted) return;

          // ==========================================
          // REDIRECT LOGIC UNTUK DEEP LINK
          // ==========================================
          final state = GoRouterState.of(context);
          final redirectUrl = state.uri.queryParameters['redirect'];

          if (redirectUrl != null && redirectUrl.isNotEmpty) {
            // Jika ada request redirect (dari Deep Link Handler), prioritaskan ke sana
            debugPrint('[LoginScreen] redirecting to deep link: $redirectUrl');
            context.go(redirectUrl);
          } else {
            // Navigate based on role default
            final targetRoute = user.role == UserRole.pic
                ? RouteNames.picHome
                : user.role == UserRole.hseSupervisor
                    ? RouteNames.supervisorHome
                    : RouteNames.petugasHome;
                    
            debugPrint('[LoginScreen] redirecting to home -> go $targetRoute');
            context.goNamed(targetRoute);
          }
          
        } else {
          final errorState = ref.read(authNotifierProvider);
          setState(() {
            _errorMessage = errorState.error ?? 'Login gagal. Periksa email dan password backend Anda.';
          });
        }
      }
    } catch (e, st) {
      debugPrint('[LoginScreen] login error: $e');
      debugPrint('[LoginScreen] login stacktrace: $st');
      if (mounted) {
        setState(() {
          _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

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
                Image.asset(
                  'lib/assets/logos/hse-logo-label.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.md),
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
                  'Gunakan akun backend production.',
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
                      _errorMessage ?? '',
                      style: const TextStyle(color: AppColors.statusRejected, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                AppTextField(
                  label: 'Email / Username',
                  hint: 'Masukkan email atau username',
                  controller: _usernameController,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Password',
                  hint: 'Masukkan password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  maxLines: 1,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? PhosphorIcons.eyeClosed(PhosphorIconsStyle.regular)
                          : PhosphorIcons.eye(PhosphorIconsStyle.regular),
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: 'Login',
                  isLoading: authState.isLoading,
                  onPressed: authState.isLoading ? null : _handleLogin,
                ),
                const SizedBox(height: AppSpacing.xxl),

                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.surfaceVariant),
                    borderRadius: BorderRadius.circular(AppRadius.borderMd),
                  ),
                  child: const Text(
                    'Login menggunakan endpoint backend production.',
                    style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
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