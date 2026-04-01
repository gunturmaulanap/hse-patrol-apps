import 'dart:io';
import '../../data/models/follow_up_model.dart';
import '../../data/models/create_follow_up_request.dart';

abstract class FollowUpRepository {
  Future<List<FollowUpModel>> getFollowUpsByReport(int reportId);
  Future<FollowUpModel> getFollowUpById(int reportId, int followUpId);
  Future<FollowUpModel> createFollowUp(int reportId, CreateFollowUpRequest request, List<File>? photos);
  Future<FollowUpModel> updateFollowUp(int reportId, int followUpId, CreateFollowUpRequest request, {List<File>? photos});
  Future<FollowUpModel> approveFollowUp(int reportId, int followUpId, String approval, String? notesHse);
  Future<void> deleteFollowUp(int reportId, int followUpId);
}
