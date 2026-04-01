import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

class PicFollowUpDraft {
  final List<String> photos;
  final String? notes;
  final String? reportId; // ID laporan yang sedang difollow-up
  final String? action; // Tindakan yang dilakukan PIC

  PicFollowUpDraft({
    this.photos = const [],
    this.notes,
    this.reportId,
    this.action,
  });

  PicFollowUpDraft copyWith({
    List<String>? photos,
    String? notes,
    String? reportId,
    String? action,
  }) {
    return PicFollowUpDraft(
      photos: photos ?? this.photos,
      notes: notes ?? this.notes,
      reportId: reportId ?? this.reportId,
      action: action ?? this.action,
    );
  }
}

class PicFollowUpFormNotifier extends StateNotifier<PicFollowUpDraft> {
  PicFollowUpFormNotifier() : super(PicFollowUpDraft());

  void setReportId(String id) => state = state.copyWith(reportId: id);

  void addPhoto(String photoPath) {
    if (state.photos.length < 3) {
      state = state.copyWith(photos: [...state.photos, photoPath]);
    }
  }

  void removePhoto(int index) {
    if (index >= 0 && index < state.photos.length) {
      final newPhotos = List<String>.from(state.photos);
      newPhotos.removeAt(index);
      state = state.copyWith(photos: newPhotos);
    }
  }

  void setNotes(String value) => state = state.copyWith(notes: value);
  void setAction(String value) => state = state.copyWith(action: value);
  void reset() => state = PicFollowUpDraft();

  // Submit follow-up to backend
  Future<void> submitFollowUp({
    required String reportId,
    required String action,
    required String notesPic,
    List<File>? photos,
  }) async {
    // This will be called from the screen with followUpRepository
    state = state.copyWith(
      reportId: reportId,
      action: action,
      notes: notesPic,
    );
  }
}

final picFollowUpFormProvider = StateNotifierProvider<PicFollowUpFormNotifier, PicFollowUpDraft>((ref) {
  return PicFollowUpFormNotifier();
});
