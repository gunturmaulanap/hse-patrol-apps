import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/storage/session_manager.dart';
import '../../../../core/utils/system_ui_helper.dart';
import '../../../../shared/enums/user_role.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Atur System UI ketika app pertama kali dibuka
    _setupSystemUI();
    _init();
  }

  /// Atur System UI (Status Bar & Navigation Bar)
  void _setupSystemUI() {
    // Opsi 1: Edge to Edge (RECOMMENDED) - Konten memenuhi layar
    SystemUIHelper.setSystemUIMode(mode: 'edgeToEdge');

    // Opsi 2: Immersive Sticky - Sembunyikan navigation bar, muncul saat swipe
    // SystemUIHelper.enableImmersiveMode(sticky: true);

    // Opsi 3: Immersive Full - Sembunyikan semua system bars (fullscreen)
    // SystemUIHelper.enableImmersiveMode(sticky: false);

    // Atur orientasi layar ke portrait only (opsional)
    SystemUIHelper.portraitOnly();

    // Set status bar style untuk dark theme
    SystemUIHelper.setStatusBarStyle(isDark: true);
  }

  Future<void> _init() async {
    // Splash delay untuk branding
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    try {
      final sessionManager = ref.read(sessionManagerProvider);

      // DEBUG: Tampilkan token untuk verifikasi
      final token = await sessionManager.getToken();
      final role = await sessionManager.getRole();
      debugPrint('[Splash] DEBUG: Token = ${token?.substring(0, 20) ?? 'null'}...');
      debugPrint('[Splash] DEBUG: Role = $role');

      final isLoggedIn = await sessionManager.isLoggedIn();
      debugPrint('[Splash] isLoggedIn: $isLoggedIn');

      if (!isLoggedIn) {
        debugPrint('[Splash] before redirect/router decision -> go login');
        if (!mounted) return;
        context.goNamed(RouteNames.login);
        return;
      }

      debugPrint('[Splash] before call /me');
      final authRepository = ref.read(authRepositoryProvider);
      final me = await authRepository.getMe();
      debugPrint('[Splash] /me result: ${me.toJson()}');

      ref.read(authNotifierProvider.notifier).setHydratedUser(me);

      final route = me.role == UserRole.pic
          ? RouteNames.picHome
          : me.role == UserRole.hseSupervisor
              ? RouteNames.supervisorHome
              : RouteNames.petugasHome;
      debugPrint('[Splash] before redirect/router decision -> go $route');
      if (!mounted) return;
      context.goNamed(route);
    } catch (e, st) {
      debugPrint('[Splash] init error: $e');
      debugPrint('[Splash] stacktrace: $st');

      final sessionManager = SessionManager();
      await sessionManager.clearToken();
      await sessionManager.clearRole();

      if (!mounted) return;

      debugPrint('[Splash] before redirect/router decision -> fallback login');
      context.goNamed(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image.asset(
          'lib/assets/logos/hse-logo.png',
          width: 220,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
