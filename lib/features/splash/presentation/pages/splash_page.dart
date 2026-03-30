import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/storage/session_manager.dart';

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
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final sessionManager = const SessionManager();
    final isLoggedIn = await sessionManager.isLoggedIn();
    if (!isLoggedIn) {
      if (mounted) context.goNamed(RouteNames.login);
      return;
    }

    final role = await sessionManager.getRole();
    if (!mounted) return;

    if (role == 'pic') {
      context.goNamed(RouteNames.picHome);
    } else {
      context.goNamed(RouteNames.petugasHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('HSE Aksamala'),
      ),
    );
  }
}