import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockUser {
  final String id;
  final String username;
  final String password;
  final String role; 
  final List<String> areaAccess;

  MockUser({
    required this.id, 
    required this.username, 
    required this.password, 
    required this.role,
    this.areaAccess = const [],
  });
}

class MockDatabase {
  final List<MockUser> users = [
    MockUser(id: '1', username: 'petugas', password: '123', role: 'petugas'),
    MockUser(id: '2', username: 'pic', password: '123', role: 'pic', areaAccess: [
      'Area Produksi 1 - Mesin Bubut',
      'Koridor Evakuasi Barat',
      'Gudang Penyimpanan B',
      'Area Parkir Timur',
      'Ruang Rapat Utama',
      'Kantin Karyawan',
      'Area Loading Dock',
    ]),
  ];

  late List<Map<String, dynamic>> reports;

  MockDatabase() {
    final now = DateTime.now();
    
    reports = [
      // ==========================================
      // AREA: Area Produksi 1 - Mesin Bubut
      // ==========================================
      {
        'id': 'rpt_prod1_1',
        'buildingType': 'Fasilitas Produksi',
        'area': 'Area Produksi 1 - Mesin Bubut',
        'riskLevel': 'Berat',
        'notes': 'Pengecekan rutin harian mesin bubut.',
        'rootCause': 'Inspeksi Pagi',
        'date': DateTime(now.year, now.month, now.day, 9, 0).toIso8601String(),
        'status': 'Completed', // Sudah selesai
      },
      {
        'id': 'rpt_prod1_2',
        'buildingType': 'Fasilitas Produksi',
        'area': 'Area Produksi 1 - Mesin Bubut',
        'riskLevel': 'Menengah',
        'notes': 'Pelumas mesin tercecer di lantai.',
        'rootCause': 'Kebocoran Oli',
        'date': DateTime(now.year, now.month, now.day, 10, 0).toIso8601String(),
        'status': 'Pending', // Baru dibuat petugas, Action Needed
      },
      {
        'id': 'rpt_prod1_3',
        'buildingType': 'Fasilitas Produksi',
        'area': 'Area Produksi 1 - Mesin Bubut',
        'riskLevel': 'Kritis',
        'notes': 'Kabel utama terkelupas.',
        'rootCause': 'Bahaya Listrik',
        'date': DateTime(now.year, now.month, now.day, 11, 30).toIso8601String(),
        'status': 'Pending', 
        'followUps': [
          {
            'type': 'PIC_FOLLOW_UP',
            'notes': 'Kabel sudah diisolasi sementara.',
            'photos': [],
            'date': DateTime(now.year, now.month, now.day, 12, 0).toIso8601String(),
          },
          {
            'type': 'PETUGAS_REVIEW',
            'action': 'Rejected',
            'notes': 'Isolasi sementara tidak cukup, harus diganti kabel baru standar SNI.',
            'date': DateTime(now.year, now.month, now.day, 12, 30).toIso8601String(),
          }
        ] // REJECTED -> Kembali ke Pending, Action Needed (Urgent)
      },
      {
        'id': 'rpt_prod1_4',
        'buildingType': 'Fasilitas Produksi',
        'area': 'Area Produksi 1 - Mesin Bubut',
        'riskLevel': 'Ringan',
        'notes': 'Lampu penerangan mesin redup.',
        'rootCause': 'Lampu Rusak',
        'date': DateTime(now.year, now.month, now.day, 13, 0).toIso8601String(),
        'status': 'Follow Up Done',
        'followUps': [
          {
            'type': 'PIC_FOLLOW_UP',
            'notes': 'Lampu telah diganti dengan LED baru.',
            'photos': [],
            'date': DateTime(now.year, now.month, now.day, 14, 0).toIso8601String(),
          }
        ] // Sudah difollowup, Waiting Response Petugas
      },

      // ==========================================
      // AREA: Koridor Evakuasi Barat
      // ==========================================
      {
        'id': 'rpt_kor_1',
        'buildingType': 'Fasilitas Non-Produksi',
        'area': 'Koridor Evakuasi Barat',
        'riskLevel': 'Ringan',
        'notes': 'Jalur evakuasi terhalang troli barang.',
        'rootCause': 'Penempatan Barang',
        'date': DateTime(now.year, now.month, now.day - 1, 10, 30).toIso8601String(),
        'status': 'Follow Up Done',
        'followUps': [
          {
            'type': 'PIC_FOLLOW_UP',
            'notes': 'Troli sudah dipindahkan ke gudang.',
            'photos': [],
            'date': DateTime(now.year, now.month, now.day, 8, 0).toIso8601String(),
          }
        ] // Waiting Response
      },
      {
        'id': 'rpt_kor_2',
        'buildingType': 'Fasilitas Non-Produksi',
        'area': 'Koridor Evakuasi Barat',
        'riskLevel': 'Menengah',
        'notes': 'Tanda EXIT pudar.',
        'rootCause': 'Perawatan Fasilitas',
        'date': DateTime(now.year, now.month, now.day, 15, 0).toIso8601String(),
        'status': 'Pending', // Action Needed
      },

      // ==========================================
      // AREA: Gudang Penyimpanan B
      // ==========================================
      {
        'id': 'rpt_gudB_1',
        'buildingType': 'Gudang',
        'area': 'Gudang Penyimpanan B',
        'riskLevel': 'Kritis',
        'notes': 'Tumpukan palet miring.',
        'rootCause': 'Inspeksi Keamanan',
        'date': DateTime(now.year, now.month, now.day, 14, 0).toIso8601String(),
        'status': 'Pending', // Action Needed
      },

      // ==========================================
      // AREA: Area Parkir Timur (Semua Canceled/Completed - All Clear)
      // ==========================================
      {
        'id': 'rpt_park_1',
        'buildingType': 'Luar Ruangan',
        'area': 'Area Parkir Timur',
        'riskLevel': 'Ringan',
        'notes': 'Patroli dibatalkan karena badai.',
        'rootCause': 'Cuaca Buruk',
        'date': DateTime(now.year, now.month, now.day, 16, 0).toIso8601String(),
        'status': 'Canceled', // Tidak dihitung Action/Waiting
      },

      // ==========================================
      // AREA: Kantin Karyawan (Semua Waiting Response)
      // ==========================================
      {
        'id': 'rpt_kantin_1',
        'buildingType': 'Fasilitas Umum',
        'area': 'Kantin Karyawan',
        'riskLevel': 'Menengah',
        'notes': 'Wastafel mampet.',
        'rootCause': 'Saluran Pembuangan',
        'date': DateTime(now.year, now.month, now.day, 12, 15).toIso8601String(),
        'status': 'Follow Up Done',
        'followUps': [
          {
            'type': 'PIC_FOLLOW_UP',
            'notes': 'Sudah dipompa dan dibersihkan.',
            'photos': [],
            'date': DateTime(now.year, now.month, now.day, 13, 0).toIso8601String(),
          }
        ] // Waiting Response
      },
      
      // ==========================================
      // AREA: Area Loading Dock
      // ==========================================
      {
        'id': 'rpt_load_1',
        'buildingType': 'Gudang',
        'area': 'Area Loading Dock',
        'riskLevel': 'Berat',
        'notes': 'Pintu hidrolik macet.',
        'rootCause': 'Kerusakan Mekanis',
        'date': DateTime(now.year, now.month, now.day, 15, 30).toIso8601String(),
        'status': 'Pending', // Action Needed
      },
    ];
  }

  void addReport(Map<String, dynamic> report) {
    reports.insert(0, report);
  }

  void updateReportStatus(String id, String action, {String? picNotes, List<String>? picPhotos, String? rejectedReason}) {
    final index = reports.indexWhere((r) => r['id'] == id);
    if (index != -1) {
      final updatedReport = Map<String, dynamic>.from(reports[index]);
      List<dynamic> followUps = updatedReport['followUps'] != null 
          ? List<dynamic>.from(updatedReport['followUps']) 
          : [];
          
      if (action == 'Follow Up Done') {
         updatedReport['status'] = 'Follow Up Done';
         followUps.add({
           'type': 'PIC_FOLLOW_UP',
           'notes': picNotes,
           'photos': picPhotos ?? [],
           'date': DateTime.now().toIso8601String(),
         });
      } else if (action == 'Approved') {
         updatedReport['status'] = 'Completed';
         followUps.add({
           'type': 'PETUGAS_REVIEW',
           'action': 'Approved',
           'date': DateTime.now().toIso8601String(),
         });
      } else if (action == 'Rejected') {
         updatedReport['status'] = 'Pending';
         followUps.add({
           'type': 'PETUGAS_REVIEW',
           'action': 'Rejected',
           'notes': rejectedReason,
           'date': DateTime.now().toIso8601String(),
         });
      } else if (action == 'Canceled') {
         updatedReport['status'] = 'Canceled';
         followUps.add({
           'type': 'PETUGAS_REVIEW',
           'action': 'Canceled',
           'notes': rejectedReason ?? 'Dibatalkan oleh petugas',
           'date': DateTime.now().toIso8601String(),
         });
      }
      
      updatedReport['followUps'] = followUps;
      reports[index] = updatedReport;
    }
  }
}

final mockDatabaseProvider = Provider<MockDatabase>((ref) {
  return MockDatabase();
});

final currentUserProvider = StateProvider<MockUser?>((ref) => null);