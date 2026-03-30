import 'package:flutter_riverpod/flutter_riverpod.dart';

class PicFollowUpDraft {
  final List<String> photos;
  final String? notes;
  final String? reportId; // ID laporan yang sedang difollow-up

  PicFollowUpDraft({this.photos = const [], this.notes, this.reportId});

  PicFollowUpDraft copyWith({List<String>? photos, String? notes, String? reportId}) {
    return PicFollowUpDraft(
      photos: photos ?? this.photos,
      notes: notes ?? this.notes,
      reportId: reportId ?? this.reportId,
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

  void setNotes(String value) => state = state.copyWith(notes: value);
  void reset() => state = PicFollowUpDraft();
}

final picFollowUpFormProvider = StateNotifierProvider<PicFollowUpFormNotifier, PicFollowUpDraft>((ref) {
  return PicFollowUpFormNotifier();
});
