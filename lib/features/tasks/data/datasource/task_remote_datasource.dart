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

      if (data == null) throw Exception('Report not found');
      return _parseReportModel(data);
    } catch (e) {
      throw Exception('Gagal mengambil detail report: ${e.toString()}');
    }
  }

  @override
  Future<HseTaskModel> createTask(CreateHseTaskRequest request, List<File>? photos) async {
    try {
      if (request.title.trim().isEmpty) throw Exception('❌ Title tidak boleh kosong');
      if (request.areaId == null || request.areaId! <= 0) throw Exception('❌ area_id tidak valid');
      if (request.riskLevel.trim().isEmpty) throw Exception('❌ Risk level tidak boleh kosong');
      if (request.rootCause.trim().isEmpty) throw Exception('❌ Root cause tidak boleh kosong');
      if (request.notes.trim().isEmpty) throw Exception('❌ Notes tidak boleh kosong');

      final formData = FormData.fromMap({
        'title': request.title.trim(),
        'area_id': request.areaId,
        'risk_level': request.riskLevel.trim(),
        'root_cause': request.rootCause.trim(),
        'notes': request.notes.trim(),
      });

      // PERBAIKAN 1: Format key sesuai API Doc (photos[0], photos[1])
      if (photos != null && photos.isNotEmpty) {
        for (var i = 0; i < photos.length && i < 3; i++) {
          final file = await MultipartFile.fromFile(
            photos[i].path,
            filename: 'photo_${i + 1}.jpg', // Berikan ekstensi valid
          );
          formData.files.add(MapEntry('photos[$i]', file)); 
        }
      }

      // PERBAIKAN 2: Jangan menimpa Options(contentType: ...). 
      // Biarkan Dio yang membuatkan header Content-Type + Boundary secara otomatis!
      final response = await _dio.post(
        '/hse-reports',
        data: formData,
      );

      final data = response.data is Map
          ? (response.data['data'] as Map<String, dynamic>?)
          : (response.data as Map<String, dynamic>?);

      if (data == null) throw Exception('Failed to create report: ${response.data}');

      return _parseReportModel(data);

    } on DioException catch (e) {
      // PERBAIKAN 3: Tangkap error 422 di dalam catch block DioException
      if (e.response?.statusCode == 422) {
        final responseData = e.response?.data;
        String errorMsg = 'Validasi data gagal.';
        
        if (responseData is Map<String, dynamic>) {
          errorMsg = responseData['message']?.toString() ?? errorMsg;
          final errors = responseData['errors'];
          
          if (errors is Map) {
            final errorDetail = StringBuffer('$errorMsg\n\n');
            errors.forEach((key, value) {
              if (value is List) {
                errorDetail.writeln('• ${value.join(", ")}');
              } else {
                errorDetail.writeln('• $value');
              }
            });
            // Lempar dengan pesan rapih yang akan dibaca oleh UI
            throw Exception(errorDetail.toString().trim());
          }
        }
        throw Exception(errorMsg);
      }
      
      _log('❌ ERROR creating task: ${e.message}');
      rethrow;
    } catch (e) {
      rethrow;
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

      if (photos != null && photos.isNotEmpty) {
        for (var i = 0; i < photos.length && i < 3; i++) {
          final file = await MultipartFile.fromFile(
            photos[i].path,
            filename: 'photo_${i + 1}.jpg',
          );
          formData.files.add(MapEntry('photos[$i]', file)); 
        }
      }

      // Sama, biarkan dio mengatur Boundary untuk PUT multipart (jika server support)
      final response = await _dio.put(
        '/hse-reports/$id',
        data: formData,
      );

      final data = response.data is Map
          ? (response.data['data'] as Map<String, dynamic>?)
          : (response.data as Map<String, dynamic>?);

      if (data == null) throw Exception('Failed to update report');

      return _parseReportModel(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
         // Sama seperti create, bisa Anda perluas jika butuh pesan detail
         throw Exception(e.response?.data['message'] ?? 'Validasi update gagal');
      }
      throw Exception('Gagal update report: ${e.message}');
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