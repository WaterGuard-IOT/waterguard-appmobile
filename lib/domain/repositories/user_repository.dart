import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> getUserById(String id);
  Future<User?> authenticateUser(String email, String password);
  Future<List<User>> getUsersManagingTank(String tankId);
}