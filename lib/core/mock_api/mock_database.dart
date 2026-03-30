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
    MockUser(id: '2', username: 'pic', password: '123', role: 'pic', areaAccess: ['Area Produksi 1 - Mesin Bubut', 'Koridor Evakuasi Barat']),
  ];

  late List<Map<String, dynamic>> reports;

  MockDatabase() {
    final now = DateTime.now();
    
    reports = [
      // --- HARI INI ---
      {
        'id': 'rpt_today_1',
        'buildingType': 'Fasilitas Produksi',
        'area': 'Area Produksi 1 - Mesin Bubut',
        'riskLevel': 'Berat',
        'notes': 'Pengecekan rutin harian mesin bubut.',
        'rootCause': 'Inspeksi Pagi',
        'date': DateTime(now.year, now.month, now.day, 9, 0).toIso8601String(),
        'status': 'Completed',
      },
      {
        'id': 'rpt_today_2',
        'buildingType': 'Fasilitas Non-Produksi',
        'area': 'Koridor Evakuasi Barat',
        'riskLevel': 'Ringan',
        'notes': 'Pengecekan lampu neon dan jalur evakuasi.',
        'rootCause': 'Inspeksi Rutin',
        'date': DateTime(now.year, now.month, now.day, 10, 30).toIso8601String(),
        'status': 'Follow Up Done',
        'followUps': [
          {
            'type': 'PIC_FOLLOW_UP',
            'notes': 'Lampu sudah diganti.',
            'photos': [],
            'date': DateTime(now.year, now.month, now.day, 11, 0).toIso8601String(),
          }
        ]
      },
      {
        'id': 'rpt_today_3',
        'buildingType': 'Gudang',
        'area': 'Gudang Penyimpanan B',
        'riskLevel': 'Kritis',
        'notes': 'Pengecekan tumpukan palet.',
        'rootCause': 'Inspeksi Keamanan',
        'date': DateTime(now.year, now.month, now.day, 14, 0).toIso8601String(),
        'status': 'Pending',
      },
      // IMPROVISASI: Menambahkan task status CANCELED hari ini
      {
        'id': 'rpt_today_4',
        'buildingType': 'Luar Ruangan',
        'area': 'Area Parkir Timur',
        'riskLevel': 'Ringan',
        'notes': 'Patroli dibatalkan karena cuaca sangat buruk/hujan badai.',
        'rootCause': 'Cuaca Buruk',
        'date': DateTime(now.year, now.month, now.day, 16, 0).toIso8601String(),
        'status': 'Canceled',
      },
      // --- BESOK ---
      {
        'id': 'rpt_tmrw_1',
        'buildingType': 'Fasilitas Produksi',
        'area': 'Area Produksi 2 - Mesin CNC',
        'riskLevel': 'Menengah',
        'notes': 'Jadwal inspeksi mesin CNC.',
        'rootCause': 'Inspeksi Rutin',
        'date': DateTime(now.year, now.month, now.day + 1, 8, 30).toIso8601String(),
        'status': 'Pending',
      },
      // --- LUSA ---
      {
        'id': 'rpt_day_after_1',
        'buildingType': 'Perkantoran',
        'area': 'Ruang Rapat Utama',
        'riskLevel': 'Ringan',
        'notes': 'Pengecekan APAR dan Smoke Detector.',
        'rootCause': 'Inspeksi Bulanan',
        'date': DateTime(now.year, now.month, now.day + 2, 10, 0).toIso8601String(),
        'status': 'Pending',
      },
      // --- KEMARIN (Riwayat) ---
      {
        'id': 'rpt_yest_1',
        'buildingType': 'Gudang',
        'area': 'Gudang Bahan Kimia',
        'riskLevel': 'Berat',
        'notes': 'Bocor sedikit di atap.',
        'rootCause': 'Genteng geser',
        'date': DateTime(now.year, now.month, now.day - 1, 15, 0).toIso8601String(),
        'status': 'Canceled',
      }
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