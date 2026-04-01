import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/area_model.dart';

abstract class AreaRemoteDataSource {
  Future<List<AreaModel>> fetchAreas();
  Future<List<AreaModel>> fetchAreasByUser();
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

      return data.map((json) => AreaModel.fromJson(json as Map<String, dynamic>)).toList();
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

      return data.map((json) => AreaModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data areas by user: ${e.toString()}');
    }
  }
}
