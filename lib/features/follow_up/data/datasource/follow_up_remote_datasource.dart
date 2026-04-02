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
      // PERBAIKAN 1: Endpoint sesuai API Docs (tanpa /hse-reports)
      final response = await _dio.get('/$reportId/follow-ups');

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
      // PERBAIKAN 1: Endpoint sesuai API Docs
      final response = await _dio.get('/$reportId/follow-ups/$followUpId');

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

      final formData = FormData.fromMap({
        'action': request.action.trim(),
        'notes_pic': request.notesPic.trim(),
        if (request.notesHse != null && request.notesHse!.trim().isNotEmpty) 'notes_hse': request.notesHse!.trim(),
      });

      // PERBAIKAN 2: Format array key photos[$i] sesuai docs API
      if (photos != null && photos.isNotEmpty) {
        _log('📷 Processing ${photos.length} photos...');
        for (var i = 0; i < photos.length && i < 3; i++) {
          final file = await MultipartFile.fromFile(
            photos[i].path,
            filename: 'photo_${i + 1}.jpg', // Set ekstensi yang valid
          );
          formData.files.add(MapEntry('photos[$i]', file)); 
          _log('  • photos[$i]: ${photos[i].path}');
        }
      }

      _log('🌐 Sending POST request to /$reportId/follow-ups...');
      
      // PERBAIKAN 3: Jangan gunakan options contentType secara manual agar boundary Dio tidak hilang
      final response = await _dio.post(
        '/$reportId/follow-ups',
        data: formData,
      );

      final data = response.data is Map
          ? (response.data['data'] as Map<String, dynamic>?)
          : (response.data as Map<String, dynamic>?);

      if (data == null) {
        throw Exception('Failed to create follow-up');
      }

      _log('✅ SUCCESS! Follow-up created');
      return _parseFollowUpModel(data);
    } on DioException catch (e) {
      // Tangkap error validasi secara rapih
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
            throw Exception(errorDetail.toString().trim());
          }
        }
        throw Exception(errorMsg);
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<FollowUpModel> updateFollowUp(int reportId, int followUpId, CreateFollowUpRequest request, {List<File>? photos}) async {
    try {
      final formData = FormData.fromMap({
        'mode': 'update',
        'action': request.action.trim(),
        'notes_pic': request.notesPic.trim(),
        if (request.notesHse != null && request.notesHse!.trim().isNotEmpty) 'notes_hse': request.notesHse!.trim(),
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

      // Endpoint sesuai docs dan tanpa options header manual
      final response = await _dio.put(
        '/$reportId/follow-ups/$followUpId',
        data: formData,
      );

      final data = response.data is Map
          ? (response.data['data'] as Map<String, dynamic>?)
          : (response.data as Map<String, dynamic>?);

      if (data == null) {
        throw Exception('Failed to update follow-up');
      }

      return _parseFollowUpModel(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
         throw Exception(e.response?.data['message'] ?? 'Validasi update gagal');
      }
      throw Exception('Gagal update follow-up: ${e.message}');
    } catch (e) {
      throw Exception('Gagal update follow-up: ${e.toString()}');
    }
  }

  @override
  Future<FollowUpModel> approveFollowUp(int reportId, int followUpId, String approval, String? notesHse) async {
    try {
      final response = await _dio.put(
        '/$reportId/follow-ups/$followUpId',
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
        '/$reportId/follow-ups/$followUpId',
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
      reportId: _toInt(json['hse_report_id'] ?? json['report_id'] ?? json['reportId']), 
      action: json['action']?.toString() ?? '',
      notesPic: json['notes_pic']?.toString() ?? json['notesPic']?.toString(),
      notesHse: json['notes_hse']?.toString() ?? json['notesHse']?.toString(),
      photos: _parsePhotos(json['photos']),
      status: json['status']?.toString(),
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
      return raw.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty && e != 'null').toList();
    }
    if (raw is Map) {
      return raw.values.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty && e != 'null').toList();
    }
    return <String>[];
  }
}