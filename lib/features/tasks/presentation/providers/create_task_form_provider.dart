import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/create_hse_task_request.dart';
import '../../data/models/hse_task_model.dart';
import 'task_provider.dart';

class CreateTaskDraft {
  static const int noDepartmentSupport = 0;
  static const int hrgaDepartment = 1;
  static const int engineeringDepartment = 2;

  final String? buildingType;
  final String? area;
  final String? riskLevel;
  final List<String> photos;
  final String? notes;
  final String? rootCause;
  final int? areaId;
  final int toDepartment;

  CreateTaskDraft({
    this.buildingType,
    this.area,
    this.riskLevel,
    this.photos = const [],
    this.notes,
    this.rootCause,
    this.areaId,
    this.toDepartment = noDepartmentSupport,
  });

  CreateTaskDraft copyWith({
    String? buildingType,
    String? area,
    String? riskLevel,
    List<String>? photos,
    String? notes,
    String? rootCause,
    int? areaId,
    int? toDepartment,
  }) {
    return CreateTaskDraft(
      buildingType: buildingType ?? this.buildingType,
      area: area ?? this.area,
      riskLevel: riskLevel ?? this.riskLevel,
      photos: photos ?? this.photos,
      notes: notes ?? this.notes,
      rootCause: rootCause ?? this.rootCause,
      areaId: areaId ?? this.areaId,
      toDepartment: toDepartment ?? this.toDepartment,
    );
  }

  bool get needsOtherDepartmentSupport => toDepartment != noDepartmentSupport;
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
  void setNeedsOtherDepartmentSupport(bool value) {
    state = state.copyWith(
      toDepartment: value
          ? (state.toDepartment == CreateTaskDraft.noDepartmentSupport
              ? CreateTaskDraft.hrgaDepartment
              : state.toDepartment)
          : CreateTaskDraft.noDepartmentSupport,
    );
  }

  void setToDepartment(int value) => state = state.copyWith(toDepartment: value);

  void reset() => state = CreateTaskDraft();

  // PERBAIKAN: Mengubah tipe return dari Future<bool> menjadi Future<HseTaskModel?>
  Future<HseTaskModel?> submitTask() async {
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
        toDepartment: state.toDepartment,
      );

      final photoFiles = state.photos.map((path) => File(path)).toList();

      // PERBAIKAN: Tangani exception dengan lebih baik
      try {
        // Simpan hasil response backend ke dalam variabel
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

      } on DioException catch (e) {
        // Tangani DioException secara terpisah untuk error message yang lebih jelas
        debugPrint('❌ [CreateTaskFormNotifier] DioException: ${e.message}');
        debugPrint('❌ [CreateTaskFormNotifier] Response: ${e.response?.data}');

        // Extract error message dari response
        String errorMessage = 'Gagal membuat laporan';
        try {
          if (e.response?.data is Map) {
            final data = e.response?.data as Map<String, dynamic>;
            if (data['message'] != null) {
              errorMessage = data['message'].toString();
            } else if (data['error'] != null) {
              errorMessage = data['error'].toString();
            }
          }
        } catch (_) {
          errorMessage = 'Gagal membuat laporan: ${e.message ?? "Unknown error"}';
        }

        // Re-throw sebagai generic Exception agar bisa ditangkap UI
        throw Exception(errorMessage);
      }
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
