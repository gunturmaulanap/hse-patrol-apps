import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/follow_up_remote_datasource.dart';
import '../../data/repositories/follow_up_repository_impl.dart';
import '../../domain/repositories/follow_up_repository.dart';

final followUpRemoteDataSourceProvider = Provider<FollowUpRemoteDataSource>((ref) {
  return FollowUpRemoteDataSourceImpl();
});

final followUpRepositoryProvider = Provider<FollowUpRepository>((ref) {
  final remote = ref.read(followUpRemoteDataSourceProvider);
  return FollowUpRepositoryImpl(remote);
});
