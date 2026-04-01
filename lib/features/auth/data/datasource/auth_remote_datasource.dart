import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/dio_client.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> logout();
  Future<UserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio = DioClient.instance;

  void _log(String message, [Object? data]) {
    debugPrint('[AuthRemoteDataSource] $message${data != null ? ' => $data' : ''}');
  }

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      _log('login() request payload', {
        'email': request.emailOrUsername.trim(),
        'password_length': request.password.length,
      });

      final response = await _dio.post(
        '/login',
        data: {
          'email': request.emailOrUsername.trim(),
          'password': request.password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
        ),
      );

      _log('raw login response', response.data);

      final root = _asMap(
        response.data,
        fallbackMessage: 'Format response login tidak valid',
      );

      final payload = _unwrapData(root);

      final status =
          (payload['status'] ?? root['status'])?.toString().trim().toLowerCase();

      final message =
          (payload['message'] ?? root['message'])?.toString().trim();

      if (status != null &&
          status.isNotEmpty &&
          status != 'success' &&
          status != 'ok') {
        throw Exception(message?.isNotEmpty == true ? message : 'Login gagal');
      }

      final normalizedJson = <String, dynamic>{
        'token': payload['token'] ??
            payload['access_token'] ??
            root['token'] ??
            root['access_token'],
        'user': payload['user'] ?? root['user'],
      };

      _log('parsed login response map', normalizedJson);

      final token = normalizedJson['token']?.toString().trim();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan dalam response login');
      }

      final userRaw = normalizedJson['user'];
      final userMap = userRaw is Map ? Map<String, dynamic>.from(userRaw) : null;
      if (userMap == null) {
        _log('login response user not found, using safe default user object');
      }

      final safeLoginJson = <String, dynamic>{
        'token': token,
        'user': userMap ?? <String, dynamic>{},
      };

      final loginResponse = LoginResponse.fromJson(safeLoginJson);
      _log('parsed LoginResponse', loginResponse.toJson());

      return loginResponse;
    } on DioException catch (e) {
      _log('login() DioException', e);
      _log('login() DioException response', e.response?.data);

      if (e.response?.statusCode == 401) {
        throw Exception('Email atau password salah.');
      }

      final backendMessage = _extractErrorMessage(e.response?.data);

      throw Exception(
        'Gagal melakukan login: ${backendMessage ?? e.message ?? 'Terjadi kesalahan pada server'}',
      );
    } catch (e, st) {
      _log('login() unexpected error', e);
      _log('login() stacktrace', st);
      throw Exception('Gagal melakukan login: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (_) {
      // ignore
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      _log('before calling /me');

      final response = await _dio.get(
        '/me',
        options: Options(responseType: ResponseType.json),
      );

      _log('raw /me response', response.data);

      final root = _asMap(
        response.data,
        fallbackMessage: 'Format response user tidak valid',
      );

      final data = _unwrapData(root);

      final userPayload = _extractUserPayload(root: root, payload: data);

      if (userPayload == null || userPayload.isEmpty) {
        throw Exception('Data user kosong');
      }

      final user = UserModel.fromBackendJson(userPayload);
      _log('parsed /me user', user.toJson());

      return user;
    } on DioException catch (e) {
      _log('getMe() DioException', e);
      _log('getMe() DioException response', e.response?.data);

      final backendMessage = _extractErrorMessage(e.response?.data);

      throw Exception(
        'Gagal mengambil data user: ${backendMessage ?? e.message ?? 'Terjadi kesalahan pada server'}',
      );
    } catch (e, st) {
      _log('getMe() unexpected error', e);
      _log('getMe() stacktrace', st);
      throw Exception('Gagal mengambil data user: $e');
    }
  }

  Map<String, dynamic>? _extractUserPayload({
    required Map<String, dynamic> root,
    required Map<String, dynamic> payload,
  }) {
    final payloadUser = payload['user'];
    if (payloadUser is Map<String, dynamic>) {
      return payloadUser;
    }
    if (payloadUser is Map) {
      return Map<String, dynamic>.from(payloadUser);
    }

    final rootUser = root['user'];
    if (rootUser is Map<String, dynamic>) {
      return rootUser;
    }
    if (rootUser is Map) {
      return Map<String, dynamic>.from(rootUser);
    }

    if (payload.containsKey('id') || payload.containsKey('email')) {
      return payload;
    }
    if (root.containsKey('id') || root.containsKey('email')) {
      return root;
    }

    return null;
  }

  Map<String, dynamic> _asMap(
    dynamic raw, {
    required String fallbackMessage,
  }) {
    if (raw == null) {
      throw Exception(fallbackMessage);
    }

    if (raw is Map<String, dynamic>) {
      return raw;
    }

    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }

    if (raw is String) {
      final text = raw.trim();
      if (text.isEmpty) {
        throw Exception(fallbackMessage);
      }

      final decoded = jsonDecode(text);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }

    throw Exception(fallbackMessage);
  }

  Map<String, dynamic> _unwrapData(Map<String, dynamic> map) {
    final inner = map['data'];

    if (inner is Map<String, dynamic>) {
      return inner;
    }

    if (inner is Map) {
      return Map<String, dynamic>.from(inner);
    }

    return map;
  }

  String? _extractErrorMessage(dynamic raw) {
    try {
      if (raw == null) return null;

      if (raw is String) {
        final text = raw.trim();
        if (text.isEmpty) return null;

        try {
          final decoded = jsonDecode(text);
          if (decoded is Map) {
            return _extractErrorMessageFromMap(
              Map<String, dynamic>.from(decoded),
            );
          }
        } catch (_) {
          return text;
        }

        return text;
      }

      if (raw is Map<String, dynamic>) {
        return _extractErrorMessageFromMap(raw);
      }

      if (raw is Map) {
        return _extractErrorMessageFromMap(Map<String, dynamic>.from(raw));
      }

      return raw.toString();
    } catch (_) {
      return null;
    }
  }

  String? _extractErrorMessageFromMap(Map<String, dynamic> map) {
    final message = map['message']?.toString().trim();
    if (message != null && message.isNotEmpty) {
      return message;
    }

    final error = map['error']?.toString().trim();
    if (error != null && error.isNotEmpty) {
      return error;
    }

    final errors = map['errors'];

    if (errors is List && errors.isNotEmpty) {
      return errors.map((e) => e.toString()).join(', ');
    }

    if (errors is Map && errors.isNotEmpty) {
      return errors.values
          .expand((value) => value is List ? value : [value])
          .map((value) => value.toString())
          .join(', ');
    }

    return null;
  }
}
