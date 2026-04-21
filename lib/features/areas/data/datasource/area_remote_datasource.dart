import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/area_model.dart';

abstract class AreaRemoteDataSource {
  Future<List<AreaModel>> fetchAreas();
  Future<List<AreaModel>> fetchAreasByUser();
  Future<List<String>> fetchBuildingTypes();
}

class AreaRemoteDataSourceImpl implements AreaRemoteDataSource {
  final Dio _dio = DioClient.instance;

  @override
  Future<List<AreaModel>> fetchAreas() async {
    try {
      final response = await _dio.get('/areas');

      // Handle response format
      final List<dynamic> data = response.data is Map
          ? (response.data['data'] as List<dynamic>? ?? [])
          : (response.data as List<dynamic>? ?? []);

      return data
          .map(_toMapOrNull)
          .whereType<Map<String, dynamic>>()
          .map(AreaModel.fromJson)
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data areas: ${e.toString()}');
    }
  }

  @override
  Future<List<AreaModel>> fetchAreasByUser() async {
    try {
      final response = await _dio.get('/areas/by-user');

      // Handle response format
      final List<dynamic> data = response.data is Map
          ? (response.data['data'] as List<dynamic>? ?? [])
          : (response.data as List<dynamic>? ?? []);

      return data
          .map(_toMapOrNull)
          .whereType<Map<String, dynamic>>()
          .map(AreaModel.fromJson)
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data areas by user: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> fetchBuildingTypes() async {
    try {
      final response = await _dio.get('/areas/building-types');

      final List<dynamic> data = response.data is Map
          ? (response.data['data'] as List<dynamic>? ?? [])
          : (response.data as List<dynamic>? ?? []);

      return data
          .map((item) => item?.toString().trim() ?? '')
          .where((item) => item.isNotEmpty)
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data building types: ${e.toString()}');
    }
  }

  Map<String, dynamic>? _toMapOrNull(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}
