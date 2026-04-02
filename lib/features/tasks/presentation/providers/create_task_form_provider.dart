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
  void setNotes(String value) => state = state.copyWith(notes: value);
  void setRootCause(String value) => state = state.copyWith(rootCause: value);
  void setAreaId(int? id) => state = state.copyWith(areaId: id);

  void reset() => state = CreateTaskDraft();

  Future<bool> submitTask() async {
    try {
      debugPrint('═════════════════════════════════════');
      debugPrint('📋 [CreateTaskFormNotifier] VALIDATING FORM DATA');
      debugPrint('═════════════════════════════════════');

      // VALIDASI DATA SEBELUM SUBMIT
      if (state.areaId == null) {
        debugPrint('❌ areaId is NULL');
        throw Exception('Area belum dipilih. Silakan pilih area di langkah 2.');
      }
      if (state.area == null || state.area!.isEmpty) {
        debugPrint('❌ area is NULL or empty: ${state.area}');
        throw Exception('Nama area belum dipilih. Silakan pilih area di langkah 2.');
      }
      if (state.riskLevel == null || state.riskLevel!.isEmpty) {
        debugPrint('❌ riskLevel is NULL or empty: ${state.riskLevel}');
        throw Exception('Tingkat risiko belum dipilih. Silakan pilih di langkah 3.');
      }
      if (state.photos.isEmpty) {
        debugPrint('❌ photos is EMPTY');
        throw Exception('Minimal 1 foto wajib diambil. Silakan ambil foto di langkah 4.');
      }
      if (state.notes == null || state.notes!.isEmpty) {
        debugPrint('❌ notes is NULL or empty');
        throw Exception('Keterangan wajib diisi. Silakan isi keterangan di langkah 5.');
      }
      if (state.rootCause == null || state.rootCause!.isEmpty) {
        debugPrint('❌ rootCause is NULL or empty');
        throw Exception('Akar masalah wajib diisi. Silakan isi akar masalah di langkah 6.');
      }

      final taskRepo = ref.read(taskRepositoryProvider);

      final areaId = state.areaId!;
      final areaName = state.area!;
      final rootCause = state.rootCause!.trim();
      final notes = state.notes!.trim();
      final riskLevel = state.riskLevel!.trim();

      // Generate title sesuai format backend
      final title = 'Area $areaName Masalah $rootCause';

      debugPrint('✅ All validations passed!');
      debugPrint('📤 Sending data to backend:');
      debugPrint('  • title: "$title"');
      debugPrint('  • areaId: $areaId (int)');
      debugPrint('  • riskLevel: "$riskLevel" (string)');
      debugPrint('  • rootCause: "$rootCause"');
      debugPrint('  • notes: "$notes"');
      debugPrint('  • photos: ${state.photos.length} files');

      final request = CreateHseTaskRequest(
        title: title,
        areaId: areaId,
        riskLevel: riskLevel,
        rootCause: rootCause,
        notes: notes,
      );

      final photoFiles = state.photos.map((path) => File(path)).toList();

      await taskRepo.createTask(request, photoFiles.isNotEmpty ? photoFiles : null);

      ref.invalidate(tasksFutureProvider);
      ref.invalidate(petugasTaskMapsProvider);
      ref.invalidate(supervisorOwnTaskMapsProvider);
      ref.invalidate(supervisorStaffTaskMapsProvider);
      ref.invalidate(supervisorAllVisibleTaskMapsProvider);
      ref.invalidate(supervisorStaffNamesProvider);

      reset();
      debugPrint('✅ SUCCESS! Form reset after successful submit');
      debugPrint('═════════════════════════════════════');

      return true;
    } catch (e) {
      debugPrint('❌ [CreateTaskFormNotifier] submitTask error: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      // RETHROW: Supaya ditangkap oleh Try-Catch di Review Screen UI
      rethrow;
    }
  }
}

final createTaskFormProvider = StateNotifierProvider<CreateTaskFormNotifier, CreateTaskDraft>((ref) {
  return CreateTaskFormNotifier(ref);
});