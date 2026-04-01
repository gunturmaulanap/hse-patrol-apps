import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import '../core/network/dio_client.dart';
import '../core/storage/secure_storage_service.dart';

void bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SecureStorage (important for web support)
  await SecureStorageService.init();

  // Initialize DioClient interceptors
  await DioClient.initInterceptors();

  runApp(const ProviderScope(child: HseAksamalaApp()));
}