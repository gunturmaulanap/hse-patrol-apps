import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/network/dio_client.dart';
import 'core/storage/secure_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide navigation bar dan status bar untuk fullscreen experience
  // Ini setara dengan SystemChrome.setEnabledSystemUIOverlays([]) di versi lama
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

  await SecureStorageService.init();
  await DioClient.initInterceptors();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'HSE Aksamala',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
