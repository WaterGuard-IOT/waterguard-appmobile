// lib/domain/repositories/user_repository.dart
import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> getUserById(String id);
  Future<User?> authenticateUser(String username, String password);
  Future<List<User>> getUsersManagingTank(String tankId);
}
