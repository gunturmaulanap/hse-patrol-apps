import 'dart:io';
import '../../domain/repositories/follow_up_repository.dart';
import '../datasource/follow_up_remote_datasource.dart';
import '../models/follow_up_model.dart';
import '../models/create_follow_up_request.dart';

class FollowUpRepositoryImpl implements FollowUpRepository {
  final FollowUpRemoteDataSource _remoteDataSource;

  FollowUpRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<FollowUpModel>> getFollowUpsByReport(int reportId) async {
    return _remoteDataSource.getFollowUpsByReport(reportId);
  }

  @override
  Future<FollowUpModel> getFollowUpById(int reportId, int followUpId) async {
    return _remoteDataSource.getFollowUpById(reportId, followUpId);
  }

  @override
  Future<FollowUpModel> createFollowUp(int reportId, CreateFollowUpRequest request, List<File>? photos) async {
    return _remoteDataSource.createFollowUp(reportId, request, photos);
  }

  @override
  Future<FollowUpModel> updateFollowUp(int reportId, int followUpId, CreateFollowUpRequest request, {List<File>? photos}) async {
    return _remoteDataSource.updateFollowUp(reportId, followUpId, request, photos: photos);
  }

  @override
  Future<FollowUpModel> approveFollowUp(int reportId, int followUpId, String approval, String? notesHse) async {
    return _remoteDataSource.approveFollowUp(reportId, followUpId, approval, notesHse);
  }

  @override
  Future<void> deleteFollowUp(int reportId, int followUpId) async {
    return _remoteDataSource.deleteFollowUp(reportId, followUpId);
  }
}
