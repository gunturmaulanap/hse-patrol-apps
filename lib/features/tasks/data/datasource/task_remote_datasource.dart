import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/dio_client.dart';
import '../models/hse_task_model.dart';
import '../models/create_hse_task_request.dart';
import '../models/hse_staff_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<HseTaskModel>> fetchTasks({int? areaId, String? status});
  Future<HseTaskModel> getTaskById(int id);
  Future<HseTaskModel> getTaskByPicToken(String picToken);
  Future<Map<String, dynamic>> validatePicToken(String picToken);
  Future<HseTaskModel> createTask(CreateHseTaskRequest request, List<File>? photos);
  Future<HseTaskModel> updateTask(int id, CreateHseTaskRequest request, {List<File>? photos, String? mode});
  Future<void> cancelTask(int id);
  Future<List<HseStaffModel>> fetchStaffs();
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
  Future<HseTaskModel> getTaskByPicToken(String picToken) async {
    try {
      _log('Fetching task by picToken from ALL reports endpoint', {'token': picToken});
      
      // Fallback: Cari di endpoint list report secara manual
      // Karena backend belum memiliki route khusus GET /hse-reports/pic/:picToken
      final response = await _dio.get('/hse-reports');
      final data = response.data is Map
          ? (response.data['data'] as Map<String, dynamic>?)
          : (response.data as Map<String, dynamic>?);
          
      List<dynamic> allReports = [];
      if (data != null && data['data'] is List) {
        allReports = data['data'];
      } else if (data != null && data['reports'] is List) {
        allReports = data['reports'];
      } else if (response.data is List) {
        allReports = response.data;
      } else if (response.data is Map && response.data['data'] is List) {
        allReports = response.data['data'];
      } else if (response.data is Map && response.data['items'] is List) {
        allReports = response.data['items'];
      }
      
      for (final report in allReports) {
        if (report is Map<String, dynamic>) {
           final pt = report['pic_token']?.toString() ?? report['picToken']?.toString();
           if (pt == picToken) {
             _log('Task found by picToken in all reports', {'id': report['id']});
             return _parseReportModel(report);
           }
        }
      }

      _log('Task not found for picToken in all reports');
      throw Exception('Task not found');
    } catch (e) {
      _log('Error getting task by picToken: ${e.toString()}');
      throw Exception('Gagal mengambil task: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> validatePicToken(String picToken) async {
    final endpoint = '/hse-reports/pic/$picToken';

    try {
      _log('Validating picToken (existing endpoint)', {
        'endpoint': endpoint,
        'token': picToken,
      });

      final response = await _dio.get(endpoint);
      final raw = response.data;
      final map = raw is Map<String, dynamic>
          ? raw
          : raw is Map
              ? Map<String, dynamic>.from(raw)
              : <String, dynamic>{};

      final data = map['data'] is Map
          ? Map<String, dynamic>.from(map['data'] as Map)
          : map;

      final tokenValid = _resolveBool(
            data['token_valid'] ??
                data['valid'] ??
                data['is_valid'] ??
                map['token_valid'] ??
                map['valid'] ??
                map['is_valid'],
          ) ??
          true;

      final authorized = _resolveBool(
            data['authorized'] ??
                data['is_authorized'] ??
                data['allowed'] ??
                map['authorized'] ??
                map['is_authorized'] ??
                map['allowed'],
          ) ??
          true;

      final result = <String, dynamic>{
        'tokenValid': tokenValid,
        'authorized': authorized,
        'taskId': data['task_id'] ?? data['taskId'] ?? data['id'] ?? map['task_id'] ?? map['taskId'] ?? map['id'],
        'reportId': data['report_id'] ?? data['reportId'] ?? map['report_id'] ?? map['reportId'],
        'areaId': data['area_id'] ?? data['areaId'] ?? map['area_id'] ?? map['areaId'],
        'authorId': data['author_id'] ?? data['authorId'] ?? data['created_by'] ?? data['createdBy'],
        'reason': data['reason'] ?? data['message'] ?? map['message'] ?? '',
        'raw': map,
      };

      _log('Validation result (normalized)', {
        'tokenValid': result['tokenValid'],
        'authorized': result['authorized'],
        'taskId': result['taskId'],
        'areaId': result['areaId'],
      });

      return result;
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;
      final responseData = e.response?.data;
      final payload = responseData is Map
          ? Map<String, dynamic>.from(responseData as Map)
          : <String, dynamic>{};

      final tokenValid = status != 404;
      final authorized = status != 401 && status != 403;

      final result = <String, dynamic>{
        'tokenValid': tokenValid,
        'authorized': authorized,
        'taskId': payload['task_id'] ?? payload['taskId'] ?? payload['id'],
        'reportId': payload['report_id'] ?? payload['reportId'],
        'areaId': payload['area_id'] ?? payload['areaId'],
        'authorId': payload['author_id'] ?? payload['authorId'],
        'reason': payload['message']?.toString() ?? e.message ?? '',
        'raw': payload,
      };

      _log('Validation result (from error response)', {
        'status': status,
        'tokenValid': result['tokenValid'],
        'authorized': result['authorized'],
      });

      return result;
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
      // PERBAIKAN: Backend memerlukan field 'mode' = 'cancel'
      // Kirim sebagai JSON (bukan FormData) karena tidak ada file upload
      // Menggunakan PATCH untuk partial update (lebih sesuai daripada PUT)
      final response = await _dio.patch(
        '/hse-reports/$id',
        data: {'mode': 'cancel'},
      );

      // Log response untuk debugging
      _log('Cancel task response: ${response.statusCode}');
    } on DioException catch (e) {
      _log('Cancel task DioException: ${e.response?.statusCode} => ${e.response?.data}');

      // Tangkap error detail dari backend
      if (e.response?.statusCode == 422) {
        final responseData = e.response?.data;
        String errorMsg = 'Gagal membatalkan laporan.';

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
            throw Exception(errorDetail.toString().trim());
          }
        }
        throw Exception(errorMsg);
      }

      throw Exception('Gagal cancel report: ${e.toString()}');
    } catch (e) {
      _log('Cancel task error: ${e.toString()}');
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
      userName: json['user']?.toString() ?? json['user_name']?.toString() ?? json['username']?.toString(),
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool? _resolveBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    if (normalized == 'true' || normalized == '1' || normalized == 'yes' || normalized == 'valid' || normalized == 'authorized') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no' || normalized == 'invalid' || normalized == 'unauthorized') {
      return false;
    }
    return null;
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

  @override
  Future<List<HseStaffModel>> fetchStaffs() async {
    try {
      _log('Fetching staffs list');
      final response = await _dio.get('/hse/staffs');

      _log('Staffs response status', response.statusCode);

      final List<dynamic> data = _extractListData(response.data);

      final staffs = data.map((json) {
        return HseStaffModel.fromJson(json as Map<String, dynamic>);
      }).toList();

      _log('Staffs fetched successfully', {'count': staffs.length});
      return staffs;
    } catch (e) {
      _log('Error fetching staffs: ${e.toString()}');
      throw Exception('Gagal mengambil data staff: ${e.toString()}');
    }
  }
}
