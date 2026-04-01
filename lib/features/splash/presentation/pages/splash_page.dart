import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/mock_api/mock_database.dart';
import '../../../../core/storage/session_manager.dart';
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
    _init();
  }

  Future<void> _init() async {
    // Splash delay untuk branding
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    try {
      final sessionManager = ref.read(sessionManagerProvider);
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

      ref.read(currentUserProvider.notifier).state = MockUser(
            id: me.id.toString(),
            username: me.name,
            email: me.email,
            password: '',
            role: me.role == UserRole.pic
                ? 'pic'
                : me.role == UserRole.hseSupervisor
                    ? 'supervisor'
                    : 'petugas',
            areaAccess: me.areaAccess,
          );

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
          'lib/assets/logos/hse-aksamala.png',
          width: 220,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
