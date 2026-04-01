import 'dart:io';
import 'package:dio/dio.dart';
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

  @override
  Future<List<FollowUpModel>> getFollowUpsByReport(int reportId) async {
    try {
      final response = await _dio.get('/$reportId/follow-ups');

      // Handle response format
      final List<dynamic> data = response.data is Map
          ? (response.data['data'] as List<dynamic>? ?? [])
          : (response.data as List<dynamic>? ?? []);

      return data.map((json) => _parseFollowUpModel(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data follow-ups: ${e.toString()}');
    }
  }

  @override
  Future<FollowUpModel> getFollowUpById(int reportId, int followUpId) async {
    try {
      final response = await _dio.get('/$reportId/follow-ups/$followUpId');

      final data = response.data is Map
          ? (response.data['data'] as Map<String, dynamic>?)
          : (response.data as Map<String, dynamic>?);

      if (data == null) {
        throw Exception('Follow-up not found');
      }

      return _parseFollowUpModel(data);
    } catch (e) {
      throw Exception('Gagal mengambil detail follow-up: ${e.toString()}');
    }
  }

  @override
  Future<FollowUpModel> createFollowUp(int reportId, CreateFollowUpRequest request, List<File>? photos) async {
    try {
      final formData = FormData.fromMap({
        'action': request.action,
        'notes_pic': request.notesPic,
        if (request.notesHse != null) 'notes_hse': request.notesHse,
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

      final response = await _dio.post(
        '/$reportId/follow-ups',
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
        ),
      );

      final data = response.data is Map
          ? (response.data['data'] as Map<String, dynamic>?)
          : (response.data as Map<String, dynamic>?);

      if (data == null) {
        throw Exception('Failed to create follow-up');
      }

      return _parseFollowUpModel(data);
    } catch (e) {
      throw Exception('Gagal membuat follow-up: ${e.toString()}');
    }
  }

  @override
  Future<FollowUpModel> updateFollowUp(int reportId, int followUpId, CreateFollowUpRequest request, {List<File>? photos}) async {
    try {
      final formData = FormData.fromMap({
        'mode': 'update',
        'action': request.action,
        'notes_pic': request.notesPic,
        if (request.notesHse != null) 'notes_hse': request.notesHse,
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
        '/$reportId/follow-ups/$followUpId',
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
          'approval': approval,
          if (notesHse != null) 'notes_hse': notesHse,
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
      id: json['id'] as int? ?? 0,
      reportId: json['report_id'] as int? ?? json['reportId'] as int? ?? 0,
      action: json['action']?.toString() ?? '',
      notesPic: json['notes_pic']?.toString() ?? json['notesPic']?.toString(),
      notesHse: json['notes_hse']?.toString() ?? json['notesHse']?.toString(),
      photos: json['photos'] != null
          ? List<String>.from(json['photos'])
          : [],
      status: json['status']?.toString(),
      date: json['date']?.toString() ?? json['created_at']?.toString(),
    );
  }
}
