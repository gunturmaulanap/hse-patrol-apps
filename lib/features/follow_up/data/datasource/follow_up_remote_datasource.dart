import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/dio_client.dart';
import '../models/follow_up_model.dart';
import '../models/create_follow_up_request.dart';

abstract class FollowUpRemoteDataSource {
  Future<List<FollowUpModel>> getFollowUpsByReport(int reportId);
  Future<FollowUpModel> getFollowUpById(int reportId, int followUpId);
  Future<FollowUpModel> createFollowUp(int reportId, CreateFollowUpRequest request, List<File>? photos);
  Future<FollowUpModel> updateFollowUp(int reportId, int followUpId, CreateFollowUpRequest request, {List<File>? photos});
  Future<FollowUpModel> approveFollowUp(int reportId, int followUpId, String approval, String? notesHse);
  Future<void> deleteFollowUp(int reportId, int followUpId);
}

class FollowUpRemoteDataSourceImpl implements FollowUpRemoteDataSource {
  final Dio _dio = DioClient.instance;

  void _log(String message, [Object? data]) {
    debugPrint('[FollowUpRemoteDataSource] $message${data != null ? ' => $data' : ''}');
  }

  @override
  Future<List<FollowUpModel>> getFollowUpsByReport(int reportId) async {
    try {
      _log('Fetching follow-ups for report $reportId');
      final response = await _dio.get('/hse-reports/$reportId/follow-ups');

      _log('Response status: ${response.statusCode}');

      final List<dynamic> data = response.data is Map
          ? (response.data['data'] as List<dynamic>? ?? [])
          : (response.data as List<dynamic>? ?? []);

      _log('Found ${data.length} follow-ups');
      return data.map((json) => _parseFollowUpModel(json as Map<String, dynamic>)).toList();
    } catch (e) {
      _log('Error getting follow-ups: ${e.toString()}');
      throw Exception('Gagal mengambil data follow-ups: ${e.toString()}');
    }
  }

  @override
  Future<FollowUpModel> getFollowUpById(int reportId, int followUpId) async {
    try {
      _log('Fetching follow-up $followUpId for report $reportId');
      final response = await _dio.get('/hse-reports/$reportId/follow-ups/$followUpId');

      final data = response.data is Map
          ? (response.data['data'] as Map<String, dynamic>?)
          : (response.data as Map<String, dynamic>?);

      if (data == null) {
        throw Exception('Follow-up not found');
      }

      return _parseFollowUpModel(data);
    } catch (e) {
      _log('Error getting follow-up detail: ${e.toString()}');
      throw Exception('Gagal mengambil detail follow-up: ${e.toString()}');
    }
  }

  @override
  Future<FollowUpModel> createFollowUp(int reportId, CreateFollowUpRequest request, List<File>? photos) async {
    try {
      _log('═════════════════════════════════════');
      _log('🚀 CREATING NEW FOLLOW-UP');
      _log('═════════════════════════════════════');
      _log('📋 Report ID: $reportId');
      _log('📋 Request Data:');
      _log('  • action: "${request.action}"');
      _log('  • notes_pic: "${request.notesPic}"');
      _log('  • notes_hse: "${request.notesHse ?? "null"}"');
      _log('  • photos: ${photos?.length ?? 0} files');

      final formData = FormData.fromMap({
        'action': request.action.trim(),
        'notes_pic': request.notesPic.trim(),
        if (request.notesHse != null && request.notesHse!.trim().isNotEmpty) 'notes_hse': request.notesHse!.trim(),
      });

      // PERBAIKAN 1: Kirim foto sebagai array 'photos[]' bukan 'photo1', 'photo2'
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

      _log('✅ All validations passed');
      _log('📤 FormData fields: ${formData.fields.map((e) => '${e.key}: ${e.value}').toList()}');
      _log('📤 FormData files: ${formData.files.length} files');

      _log('🌐 Sending POST request to /hse-reports/$reportId/follow-ups...');
      final response = await _dio.post(
        '/hse-reports/$reportId/follow-ups',
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
        throw Exception('Failed to create follow-up');
      }

      _log('✅ SUCCESS! Follow-up created with ID: ${data['id']}');
      _log('═════════════════════════════════════');
      return _parseFollowUpModel(data);
    } catch (e) {
      _log('❌ Error creating follow-up: ${e.toString()}');
      _log('❌ Error type: ${e.runtimeType}');

      // Ekstrak response body dari DioException
      if (e is DioException) {
        _log('❌ DioException response status: ${e.response?.statusCode}');
        _log('❌ DioException response data: ${e.response?.data}');
        _log('❌ DioException response headers: ${e.response?.headers}');
      }

      rethrow;
    }
  }

  @override
  Future<FollowUpModel> updateFollowUp(int reportId, int followUpId, CreateFollowUpRequest request, {List<File>? photos}) async {
    try {
      _log('Updating follow-up $followUpId for report $reportId');

      final formData = FormData.fromMap({
        'mode': 'update',
        'action': request.action.trim(),
        'notes_pic': request.notesPic.trim(),
        if (request.notesHse != null && request.notesHse!.trim().isNotEmpty) 'notes_hse': request.notesHse!.trim(),
      });

      // Disamakan format fotonya menjadi photos[] untuk array
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
        '/hse-reports/$reportId/follow-ups/$followUpId',
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
        ),
      );

      final data = response.data is Map
          ? (response.data['data'] as Map<String, dynamic>?)
          : (response.data as Map<String, dynamic>?);

      if (data == null) {
        throw Exception('Failed to update follow-up');
      }

      return _parseFollowUpModel(data);
    } catch (e) {
      _log('Error updating follow-up: ${e.toString()}');
      throw Exception('Gagal update follow-up: ${e.toString()}');
    }
  }

  @override
  Future<FollowUpModel> approveFollowUp(int reportId, int followUpId, String approval, String? notesHse) async {
    try {
      final response = await _dio.put(
        '/hse-reports/$reportId/follow-ups/$followUpId',
        data: {
          'mode': 'approval',
          'approval': approval.trim(),
          if (notesHse != null && notesHse.trim().isNotEmpty) 'notes_hse': notesHse.trim(),
        },
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      final data = response.data is Map
          ? (response.data['data'] as Map<String, dynamic>?)
          : (response.data as Map<String, dynamic>?);

      if (data == null) {
        throw Exception('Failed to approve/reject follow-up');
      }

      return _parseFollowUpModel(data);
    } catch (e) {
      throw Exception('Gagal approval follow-up: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteFollowUp(int reportId, int followUpId) async {
    try {
      await _dio.put(
        '/hse-reports/$reportId/follow-ups/$followUpId',
        data: {'mode': 'delete'},
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );
    } catch (e) {
      throw Exception('Gagal delete follow-up: ${e.toString()}');
    }
  }

  FollowUpModel _parseFollowUpModel(Map<String, dynamic> json) {
    return FollowUpModel(
      id: _toInt(json['id']),
      // PERBAIKAN 2: Menambahkan fallback untuk hse_report_id
      reportId: _toInt(json['hse_report_id'] ?? json['report_id'] ?? json['reportId']), 
      action: json['action']?.toString() ?? '',
      notesPic: json['notes_pic']?.toString() ?? json['notesPic']?.toString(),
      notesHse: json['notes_hse']?.toString() ?? json['notesHse']?.toString(),
      // PERBAIKAN 3: Memanggil fungsi helper parsing foto agar aman meskipun format dari backend adalah Map {}
      photos: _parsePhotos(json['photos']),
      status: json['status']?.toString(),
      date: json['date']?.toString() ?? json['created_at']?.toString(),
    );
  }

  // Helper aman untuk konversi integer
  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  // Helper aman untuk parse foto (mendukung List[] maupun Map{}) dan filter null
  List<String> _parsePhotos(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty && e != 'null').toList();
    }
    if (raw is Map) {
      return raw.values.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty && e != 'null').toList();
    }
    return <String>[];
  }
}