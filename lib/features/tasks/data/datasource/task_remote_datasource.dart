import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/dio_client.dart';
import '../models/hse_task_model.dart';
import '../models/create_hse_task_request.dart';

abstract class TaskRemoteDataSource {
  Future<List<HseTaskModel>> fetchTasks({int? areaId, String? status});
  Future<HseTaskModel> getTaskById(int id);
  Future<HseTaskModel> createTask(CreateHseTaskRequest request, List<File>? photos);
  Future<HseTaskModel> updateTask(int id, CreateHseTaskRequest request, {List<File>? photos, String? mode});
  Future<void> cancelTask(int id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio _dio = DioClient.instance;

  void _log(String message, [Object? data]) {
    debugPrint('[TaskRemoteDataSource] $message${data != null ? ' => $data' : ''}');
  }

  @override
  Future<List<HseTaskModel>> fetchTasks({int? areaId, String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (areaId != null) queryParams['area_id'] = areaId;
      if (status != null) queryParams['status'] = status;

      final response = await _dio.get(
        '/hse-reports',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      _log('raw /hse-reports response', response.data);

      final List<dynamic> data = _extractListData(response.data);

      return data.map((json) => _parseReportModel(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data reports: ${e.toString()}');
    }
  }

  @override
  Future<HseTaskModel> getTaskById(int id) async {
    try {
      final response = await _dio.get('/hse-reports/$id');

      final data = response.data is Map
          ? (response.data['data'] as Map<String, dynamic>?)
          : (response.data as Map<String, dynamic>?);

      if (data == null) {
        throw Exception('Report not found');
      }

      return _parseReportModel(data);
    } catch (e) {
      throw Exception('Gagal mengambil detail report: ${e.toString()}');
    }
  }

  @override
  Future<HseTaskModel> createTask(CreateHseTaskRequest request, List<File>? photos) async {
    try {
      // VALIDASI DATA DENGAN PESAN ERROR YANG JELAS
      if (request.title.trim().isEmpty) {
        throw Exception('❌ Title tidak boleh kosong');
      }
      if (request.areaId == null || request.areaId! <= 0) {
        throw Exception('❌ area_id tidak valid: ${request.areaId}. Pastikan area sudah dipilih dengan benar.');
      }
      if (request.riskLevel.trim().isEmpty) {
        throw Exception('❌ Risk level tidak boleh kosong');
      }
      if (request.rootCause.trim().isEmpty) {
        throw Exception('❌ Root cause tidak boleh kosong');
      }
      if (request.notes.trim().isEmpty) {
        throw Exception('❌ Notes tidak boleh kosong');
      }

      _log('═════════════════════════════════════');
      _log('🚀 CREATING NEW HSE REPORT');
      _log('═════════════════════════════════════');
      _log('📋 Request Data:');
      _log('  • title: "${request.title}" (${request.title.runtimeType})');
      _log('  • area_id: ${request.areaId} (${request.areaId.runtimeType})');
      _log('  • risk_level: "${request.riskLevel}" (${request.riskLevel.runtimeType})');
      _log('  • root_cause: "${request.rootCause}" (${request.rootCause.runtimeType})');
      _log('  • notes: "${request.notes}" (${request.notes.runtimeType})');
      _log('  • photos: ${photos?.length ?? 0} files');

      // Validasi risk level
      final validRiskLevels = ['1', '2', '3', '4'];
      if (!validRiskLevels.contains(request.riskLevel)) {
        throw Exception('❌ Invalid risk_level: "${request.riskLevel}". Must be one of: ${validRiskLevels.join(', ')}');
      }

      _log('✅ All validations passed');

      final formData = FormData.fromMap({
        'title': request.title.trim(),
        'area_id': request.areaId, // Integer, bukan string
        'risk_level': request.riskLevel.trim(), // String sudah sesuai
        'root_cause': request.rootCause.trim(),
        'notes': request.notes.trim(),
      });

      _log('📤 FormData fields: ${formData.fields.map((e) => '${e.key}: ${e.value}').toList()}');

      // PERBAIKAN: Kirim foto sebagai array 'photos[]' bukan 'photo1', 'photo2'
      if (photos != null && photos.isNotEmpty) {
        _log('📷 Processing ${photos.length} photos...');
        for (var i = 0; i < photos.length && i < 3; i++) {
          final file = await MultipartFile.fromFile(
            photos[i].path,
            filename: 'photo${i + 1}.jpg',
          );
          formData.files.add(MapEntry('photos[]', file)); // Gunakan 'photos[]' untuk array
          _log('  • photos[]: ${photos[i].path}');
        }
      }

      _log('📤 FormData files: ${formData.files.length} files');

      _log('🌐 Sending POST request to /hse-reports...');
      final response = await _dio.post(
        '/hse-reports',
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
        ),
      );

      _log('📥 Response status: ${response.statusCode}');
      _log('📥 Response data: ${response.data}');

      if (response.statusCode == 422) {
        // Parse error message dari response backend
        String errorMsg = 'Validation error from backend';
        dynamic errors = null;

        if (response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          errorMsg = data['message']?.toString() ??
                     data['error']?.toString() ??
                     data['errors']?.toString() ??
                     'Validation error (422): ${data.toString()}';

          // Cek apakah ada field errors
          if (data['errors'] != null) {
            errors = data['errors'];
          }
        }

        _log('❌❌❌ ERROR 422 DETAIL ❌❌❌');
        _log('❌ Message: $errorMsg');
        _log('❌ Errors: $errors');
        _log('❌ Full Response: ${response.data}');

        // Buat pesan error yang sangat detail
        final errorDetail = StringBuffer('Backend validation error (422)\n\n');
        errorDetail.writeln('📋 Pesan Backend: $errorMsg');

        if (errors != null) {
          if (errors is Map) {
            errors.forEach((key, value) {
              errorDetail.writeln('• $key: $value');
            });
          } else if (errors is List) {
            errors.forEach((item) {
              errorDetail.writeln('• $item');
            });
          }
        }

        throw Exception(errorDetail.toString());
      }

      final data = response.data is Map
          ? (response.data['data'] as Map<String, dynamic>?)
          : (response.data as Map<String, dynamic>?);

      if (data == null) {
        _log('❌ ERROR: Failed to extract data from response');
        throw Exception('Failed to create report: ${response.data}');
      }

      _log('✅ SUCCESS! Task created with ID: ${data['id']}');
      _log('═════════════════════════════════════');
      return _parseReportModel(data);
    } catch (e) {
      _log('❌ ERROR creating task: ${e.toString()}');
      _log('❌ Error type: ${e.runtimeType}');

      // PERBAIKAN: Ekstrak response body dari DioException
      if (e is DioException) {
        _log('❌ DioException response status: ${e.response?.statusCode}');
        _log('❌ DioException response data: ${e.response?.data}');
        _log('❌ DioException response headers: ${e.response?.headers}');
      }

      rethrow; // PERBAIKAN: Lempar errornya ke layer atas
    }
  }

  @override
  Future<HseTaskModel> updateTask(int id, CreateHseTaskRequest request, {List<File>? photos, String? mode}) async {
    try {
      final formData = FormData.fromMap({
        if (mode != null) 'mode': mode,
        'area_id': request.areaId,
        'risk_level': request.riskLevel,
        'root_cause': request.rootCause,
        'notes': request.notes,
      });

      // Disamakan formatnya dengan create (photos[] untuk array)
      if (photos != null && photos.isNotEmpty) {
        for (var i = 0; i < photos.length && i < 3; i++) {
          final file = await MultipartFile.fromFile(
            photos[i].path,
            filename: 'photo${i + 1}.jpg',
          );
          formData.files.add(MapEntry('photos[]', file)); // Gunakan 'photos[]' untuk array
        }
      }

      final response = await _dio.put(
        '/hse-reports/$id',
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
        ),
      );

      final data = response.data is Map
          ? (response.data['data'] as Map<String, dynamic>?)
          : (response.data as Map<String, dynamic>?);

      if (data == null) {
        throw Exception('Failed to update report');
      }

      return _parseReportModel(data);
    } catch (e) {
      throw Exception('Gagal update report: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelTask(int id) async {
    try {
      await _dio.put(
        '/hse-reports/$id',
        data: FormData.fromMap({'mode': 'cancel'}),
        options: Options(
          contentType: Headers.multipartFormDataContentType,
        ),
      );
    } catch (e) {
      throw Exception('Gagal cancel report: ${e.toString()}');
    }
  }

  HseTaskModel _parseReportModel(Map<String, dynamic> json) {
    final title = json['title']?.toString().trim().isNotEmpty == true
        ? json['title']?.toString().trim()
        : json['name']?.toString().trim();

    final parsedPhotos = _parsePhotos(json['photos']);

    return HseTaskModel(
      id: _toInt(json['id']),
      code: json['code']?.toString() ?? '',
      userId: _toInt(json['created_by'] ?? json['createdBy'] ?? json['user_id'] ?? json['userId']),
      areaId: _toInt(json['area_id'] ?? json['areaId']),
      name: title,
      riskLevel: json['risk_level']?.toString() ?? json['riskLevel']?.toString() ?? '',
      rootCause: json['root_cause']?.toString() ?? json['rootCause']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      picToken: json['pic_token']?.toString() ?? json['picToken']?.toString(),
      photos: parsedPhotos,
      // PERBAIKAN: Parsing aman untuk followUps kosong dari backend
      followUps: (json['follow_ups'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ??
                 (json['followUps'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ??
                 [],
      date: json['date']?.toString() ?? json['created_at']?.toString(),
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  List<String> _parsePhotos(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
    }
    if (raw is Map) {
      return raw.values.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
    }
    return <String>[];
  }

  List<dynamic> _extractListData(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final data = map['data'];
      if (data is List) return data;
      if (data is Map) {
        final reports = data['reports'];
        if (reports is List) return reports;
        final nested = data['data'];
        if (nested is List) return nested;
        final items = data['items'];
        if (items is List) return items;
      }
      final items = map['items'];
      if (items is List) return items;
      final reports = map['reports'];
      if (reports is List) return reports;
    }
    return <dynamic>[];
  }
}