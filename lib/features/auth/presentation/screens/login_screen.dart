import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../../domain/auth_role_helper.dart';

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

  String _mapLoginErrorMessage(Object error) {
    final rawMessage = error.toString().toLowerCase();

    if (rawMessage.contains('email atau password salah') ||
        rawMessage.contains('unauthorized')) {
      return 'Email atau password salah, atau akun Anda belum terdaftar.';
    }

    if (rawMessage.contains('socketexception') ||
        rawMessage.contains('failed host lookup')) {
      return 'Koneksi gagal. Silakan periksa paket data atau Wi‑Fi Anda.';
    }

    if (rawMessage.contains('timeout')) {
      return 'Waktu koneksi habis. Coba lagi dalam beberapa saat.';
    }

    return 'Terjadi kendala pada server. Mohon hubungi tim IT.';
  }

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
          // Gunakan user dari response login agar transisi ke home tidak tertahan /me redundan.
          final user = ref.read(authNotifierProvider).user;

          if (user == null) {
            setState(() {
              _errorMessage = 'Login berhasil, tetapi data user tidak tersedia.';
            });
            return;
          }

          if (!mounted) return;

          // ==========================================
          // REDIRECT LOGIC UNTUK DEEP LINK
          // ==========================================
          final state = GoRouterState.of(context);
          final redirectUrl = state.uri.queryParameters['redirect'];
          final redirectTarget = redirectUrl?.trim();

          if (redirectTarget != null && redirectTarget.isNotEmpty) {
            final isInternalPath = redirectTarget.startsWith('/');

            // Jika ada request redirect (dari Deep Link Handler), prioritaskan ke sana
            debugPrint(
              '[LoginScreen] redirect requested: $redirectTarget, isInternalPath: $isInternalPath',
            );

            if (isInternalPath) {
              context.go(redirectTarget);
            } else {
              debugPrint('[LoginScreen] ignore non-internal redirect target: $redirectTarget');
              final targetRoute = resolveHomeRouteName(user.role);
              context.goNamed(targetRoute);
            }
          } else {
            // Navigate based on role default
            final targetRoute = resolveHomeRouteName(user.role);
                     
            debugPrint('[LoginScreen] redirecting to home -> go $targetRoute');
            context.goNamed(targetRoute);
          }
          
        } else {
          final errorState = ref.read(authNotifierProvider);
          final friendlyMessage = _mapLoginErrorMessage(
            errorState.error ?? 'unknown login error',
          );

          debugPrint(
            '[LoginScreen] mapped login failure message: $friendlyMessage | raw: ${errorState.error}',
          );

          AppToast.error(context, message: friendlyMessage);

          setState(() {
            _errorMessage = friendlyMessage;
          });
        }
      }
    } catch (e, st) {
      debugPrint('[LoginScreen] login error: $e');
      debugPrint('[LoginScreen] login stacktrace: $st');

      final friendlyMessage = _mapLoginErrorMessage(e);
      debugPrint('[LoginScreen] mapped catch message: $friendlyMessage');

      if (mounted) {
        AppToast.error(context, message: friendlyMessage);
        setState(() {
          _errorMessage = friendlyMessage;
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
                  'Gunakan akun berdasarkan role Anda yang sudah dibuat dari MES Aksamala.',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
