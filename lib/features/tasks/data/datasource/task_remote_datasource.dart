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
      _log('Creating task with title: ${request.title}');

      final formData = FormData.fromMap({
        'title': request.title,              // ← TAMBAHKAN INI!
        'area_id': request.areaId,
        'risk_level': request.riskLevel,
        'root_cause': request.rootCause,
        'notes': request.notes,
      });

      // Add photos if available
      if (photos != null && photos.isNotEmpty) {
        for (var i = 0; i < photos.length; i++) {
          final file = await MultipartFile.fromFile(
            photos[i].path,
            filename: 'photo_$i.jpg',
          );
          formData.files.add(MapEntry('photos[$i]', file));
        }
      }

      _log('FormData fields: ${formData.fields}');

      final response = await _dio.post(
        '/hse-reports',
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
        ),
      );

      _log('Response status: ${response.statusCode}');
      _log('Response data: ${response.data}');

      final data = response.data is Map
          ? (response.data['data'] as Map<String, dynamic>?)
          : (response.data as Map<String, dynamic>?);

      if (data == null) {
        throw Exception('Failed to create report');
      }

      return _parseReportModel(data);
    } catch (e) {
      _log('Error creating task: ${e.toString()}');
      throw Exception('Gagal membuat report: ${e.toString()}');
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

      // Add photos if available
      if (photos != null && photos.isNotEmpty) {
        for (var i = 0; i < photos.length; i++) {
          final file = await MultipartFile.fromFile(
            photos[i].path,
            filename: 'photo_$i.jpg',
          );
          formData.files.add(MapEntry('photos[$i]', file));
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
      followUps: json['follow_ups'] != null || json['followUps'] != null
          ? List<Map<String, dynamic>>.from(json['follow_ups'] ?? json['followUps'] ?? [])
          : [],
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
      return raw
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (raw is Map) {
      return raw.values
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return <String>[];
  }

  List<dynamic> _extractListData(dynamic raw) {
    if (raw is List) {
      return raw;
    }

    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);

      final data = map['data'];
      if (data is List) {
        return data;
      }

      if (data is Map) {
        final reports = data['reports'];
        if (reports is List) {
          return reports;
        }

        final nested = data['data'];
        if (nested is List) {
          return nested;
        }

        final items = data['items'];
        if (items is List) {
          return items;
        }
      }

      final items = map['items'];
      if (items is List) {
        return items;
      }

      final reports = map['reports'];
      if (reports is List) {
        return reports;
      }
    }

    return <dynamic>[];
  }
}
