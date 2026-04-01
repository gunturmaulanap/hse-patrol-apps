import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/mock_api/mock_database.dart';
import '../../data/models/create_hse_task_request.dart';
import 'task_provider.dart';

class CreateTaskDraft {
  final String? buildingType;
  final String? area;
  final String? riskLevel;
  final List<String> photos;
  final String? notes;
  final String? rootCause;
  final int? areaId; // Tambahkan areaId untuk backend

  CreateTaskDraft({
    this.buildingType,
    this.area,
    this.riskLevel,
    this.photos = const [],
    this.notes,
    this.rootCause,
    this.areaId,
  });

  CreateTaskDraft copyWith({
    String? buildingType,
    String? area,
    String? riskLevel,
    List<String>? photos,
    String? notes,
    String? rootCause,
    int? areaId,
  }) {
    return CreateTaskDraft(
      buildingType: buildingType ?? this.buildingType,
      area: area ?? this.area,
      riskLevel: riskLevel ?? this.riskLevel,
      photos: photos ?? this.photos,
      notes: notes ?? this.notes,
      rootCause: rootCause ?? this.rootCause,
      areaId: areaId ?? this.areaId,
    );
  }
}

class CreateTaskFormNotifier extends StateNotifier<CreateTaskDraft> {
  final Ref ref;
  CreateTaskFormNotifier(this.ref) : super(CreateTaskDraft());

  void setBuildingType(String value) => state = state.copyWith(buildingType: value);
  void setArea(String value) => state = state.copyWith(area: value);
  void setRiskLevel(String value) => state = state.copyWith(riskLevel: value);
  void addPhoto(String photoPath) => state = state.copyWith(photos: [...state.photos, photoPath]);
  void setNotes(String value) => state = state.copyWith(notes: value);
  void setRootCause(String value) => state = state.copyWith(rootCause: value);
  void setAreaId(int? id) => state = state.copyWith(areaId: id);

  void reset() => state = CreateTaskDraft();

  Future<bool> submitTask() async {
    try {
      final taskRepo = ref.read(taskRepositoryProvider);

      // Mapping area name ke areaId (perlu dicari dari area list)
      // Untuk sekarang, gunakan default areaId 1 jika belum ada mapping
      final areaId = state.areaId ?? 1;
      final areaName = state.area ?? 'Unknown Area';
      final rootCause = state.rootCause ?? '-';

      // Generate title sesuai format: 'Inspeksi $area - Masalah: $cause'
      final title = 'Inspeksi $areaName - Masalah: $rootCause';

      // Create request
      final request = CreateHseTaskRequest(
        title: title,
        areaId: areaId,
        riskLevel: state.riskLevel ?? 'medium',
        rootCause: rootCause,
        notes: state.notes ?? '-',
      );

      // Convert photo paths to File objects
      final photoFiles = state.photos.map((path) => File(path)).toList();

      // Call backend API
      await taskRepo.createTask(request, photoFiles.isNotEmpty ? photoFiles : null);

      // Update local mock database untuk UI consistency
      final db = ref.read(mockDatabaseProvider);
      db.addReport({
        'id': 'rpt_${DateTime.now().millisecondsSinceEpoch}',
        'buildingType': state.buildingType ?? '-',
        'area': state.area ?? '-',
        'riskLevel': state.riskLevel ?? '-',
        'photos': state.photos,
        'notes': state.notes ?? '-',
        'rootCause': state.rootCause ?? '-',
        'date': DateTime.now().toIso8601String(),
        'status': 'Pending',
      });

      return true;
    } catch (e) {
      // Jika backend API gagal, fallback ke mock database untuk development
      print('Error submitting to backend: $e');

      // Simpan ke Mock Database sebagai fallback
      final db = ref.read(mockDatabaseProvider);
      db.addReport({
        'id': 'rpt_${DateTime.now().millisecondsSinceEpoch}',
        'buildingType': state.buildingType ?? '-',
        'area': state.area ?? '-',
        'riskLevel': state.riskLevel ?? '-',
        'photos': state.photos,
        'notes': state.notes ?? '-',
        'rootCause': state.rootCause ?? '-',
        'date': DateTime.now().toIso8601String(),
        'status': 'Pending',
      });

      return true;
    }
  }
}

final createTaskFormProvider = StateNotifierProvider<CreateTaskFormNotifier, CreateTaskDraft>((ref) {
  return CreateTaskFormNotifier(ref);
});
