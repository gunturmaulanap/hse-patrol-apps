import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/network/dio_client.dart';
import 'core/storage/secure_storage_service.dart';

Future<void> main() async {
  // 1. Inisialisasi wajib
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Sembunyikan navigasi & status bar secara total (Immersive Sticky)
  // Mode ini akan menghilangkan semua icon. Icon hanya muncul jika di-swipe.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // 3. Maksa bar menjadi transparan (menghilangkan sisa warna bar jika sistem memaksanya muncul)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

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
      // 4. Trik Terakhir: Membungkus dengan Builder untuk menjaga mode fullscreen
      builder: (context, child) {
        return Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              // Jika aplikasi kehilangan fokus (misal buka notifikasi) lalu kembali, 
              // kita paksa sembunyikan lagi navigasinya.
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
            }
          },
          child: child!,
        );
      },
    );
  }
}