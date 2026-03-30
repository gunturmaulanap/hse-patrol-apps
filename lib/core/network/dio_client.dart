import 'package:dio/dio.dart';

import '../../app/env/app_env.dart';

class DioClient {
  DioClient._();

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: AppEnv.baseUrl,
      connectTimeout: AppEnv.connectTimeout,
      receiveTimeout: AppEnv.receiveTimeout,
      headers: {
        'Accept': 'application/json',
      },
    ),
  );
}