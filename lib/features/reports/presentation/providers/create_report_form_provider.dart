import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/mock_api/mock_database.dart';

class CreateReportDraft {
  final String? buildingType;
  final String? area;
  final String? riskLevel;
  final List<String> photos;
  final String? notes;
  final String? rootCause;

  CreateReportDraft({
    this.buildingType,
    this.area,
    this.riskLevel,
    this.photos = const [],
    this.notes,
    this.rootCause,
  });

  CreateReportDraft copyWith({
    String? buildingType,
    String? area,
    String? riskLevel,
    List<String>? photos,
    String? notes,
    String? rootCause,
  }) {
    return CreateReportDraft(
      buildingType: buildingType ?? this.buildingType,
      area: area ?? this.area,
      riskLevel: riskLevel ?? this.riskLevel,
      photos: photos ?? this.photos,
      notes: notes ?? this.notes,
      rootCause: rootCause ?? this.rootCause,
    );
  }
}

class CreateReportFormNotifier extends StateNotifier<CreateReportDraft> {
  final Ref ref;
  CreateReportFormNotifier(this.ref) : super(CreateReportDraft());

  void setBuildingType(String value) => state = state.copyWith(buildingType: value);
  void setArea(String value) => state = state.copyWith(area: value);
  void setRiskLevel(String value) => state = state.copyWith(riskLevel: value);
  void addPhoto(String photoPath) => state = state.copyWith(photos: [...state.photos, photoPath]);
  void setNotes(String value) => state = state.copyWith(notes: value);
  void setRootCause(String value) => state = state.copyWith(rootCause: value);

  void reset() => state = CreateReportDraft();

  Future<bool> submitReport() async {
    // Mock API Delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simpan ke Mock Database
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

final createReportFormProvider = StateNotifierProvider<CreateReportFormNotifier, CreateReportDraft>((ref) {
  return CreateReportFormNotifier(ref);
});
