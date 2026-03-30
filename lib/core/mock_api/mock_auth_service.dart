import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mock_database.dart';

class MockAuthService {
  final MockDatabase db;

  MockAuthService(this.db);

  MockUser? login({required String username, required String password}) {
    try {
      return db.users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
    } catch (e) {
      return null;
    }
  }
}

final mockAuthServiceProvider = Provider<MockAuthService>((ref) {
  final db = ref.watch(mockDatabaseProvider);
  return MockAuthService(db);
});
