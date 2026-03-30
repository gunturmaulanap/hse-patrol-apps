import '../../../../core/network/dio_client.dart';
import '../models/area_model.dart';

abstract class AreaRemoteDataSource {
  Future<List<AreaModel>> fetchAreas();
}

class AreaRemoteDataSourceImpl implements AreaRemoteDataSource {
  @override
  Future<List<AreaModel>> fetchAreas() async {
    // === MOCK API IMPLEMENTATION FOR TESTING UI ===
    await Future.delayed(const Duration(seconds: 1));
    return const [
      AreaModel(id: 1, code: 'GUT-01', name: 'Gudang Utama', buildingType: 'Warehouse'),
      AreaModel(id: 2, code: 'PROD-A', name: 'Area Produksi A', buildingType: 'Factory'),
      AreaModel(id: 3, code: 'OFF-01', name: 'Kantor Administrasi', buildingType: 'Office'),
    ];

    /* ACTUAL IMPLEMENTATION
    final response = await DioClient.instance.get('/api/areas');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => AreaModel.fromJson(json)).toList();
    */
  }
}
