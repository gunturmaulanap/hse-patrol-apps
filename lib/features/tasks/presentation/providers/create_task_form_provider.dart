import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/create_hse_task_request.dart';
import 'task_provider.dart';

class CreateTaskDraft {
  final String? buildingType;
  final String? area;
  final String? riskLevel;
  final List<String> photos;
  final String? notes;
  final String? rootCause;
  final int? areaId; 

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

  void removePhoto(int index) {
    if (index >= 0 && index < state.photos.length) {
      final newPhotos = List<String>.from(state.photos);
      newPhotos.removeAt(index);
      state = state.copyWith(photos: newPhotos);
    }
  }

  void updatePhotoAtIndex(int index, String photoPath) {
    if (index >= 0 && index < state.photos.length) {
      final newPhotos = List<String>.from(state.photos);
      newPhotos[index] = photoPath;
      state = state.copyWith(photos: newPhotos);
    }
  }

  void setNotes(String value) => state = state.copyWith(notes: value);
  void setRootCause(String value) => state = state.copyWith(rootCause: value);
  void setAreaId(int? id) => state = state.copyWith(areaId: id);

  void reset() => state = CreateTaskDraft();

  // PERBAIKAN: Mengubah tipe return dari Future<bool> menjadi Future<dynamic>
  Future<dynamic> submitTask() async {
    try {
      final taskRepo = ref.read(taskRepositoryProvider);

      final areaId = state.areaId ?? 1;
      final areaName = state.area ?? 'Unknown Area';
      final rootCause = state.rootCause ?? '-';

      final title = 'Area $areaName Masalah $rootCause';

      final request = CreateHseTaskRequest(
        title: title,
        areaId: areaId,
        riskLevel: state.riskLevel ?? 'medium',
        rootCause: rootCause,
        notes: state.notes ?? '-',
      );

      final photoFiles = state.photos.map((path) => File(path)).toList();

      // PERBAIKAN: Simpan hasil response backend ke dalam variabel
      final createdTask = await taskRepo.createTask(request, photoFiles.isNotEmpty ? photoFiles : null);

      // Invalidate cache list agar data terbaru langsung muncul
      ref.invalidate(tasksFutureProvider);
      ref.invalidate(petugasTaskMapsProvider);
      ref.invalidate(supervisorOwnTaskMapsProvider);
      ref.invalidate(supervisorStaffTaskMapsProvider);
      ref.invalidate(supervisorAllVisibleTaskMapsProvider);
      ref.invalidate(supervisorStaffNamesProvider);

      // Reset form draft
      reset();
      debugPrint('✅ [CreateTaskFormNotifier] Form reset after successful submit');

      // PERBAIKAN: Kembalikan data task (HseTaskModel) ke UI
      return createdTask;
      
    } catch (e) {
      debugPrint('❌ [CreateTaskFormNotifier] submitTask error: $e');
      // RETHROW: Supaya ditangkap oleh Try-Catch di Review Screen UI
      rethrow; 
    }
  }
}

final createTaskFormProvider = StateNotifierProvider<CreateTaskFormNotifier, CreateTaskDraft>((ref) {
  return CreateTaskFormNotifier(ref);
});