// lib/data/repositories/user_repository_impl.dart
import 'package:waterguard/data/datasources/mock/mock_data_provider.dart';
import 'package:waterguard/domain/entities/user.dart';
import 'package:waterguard/domain/repositories/user_repository.dart';
import 'package:waterguard/data/models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final MockDataProvider mockDataProvider;

  UserRepositoryImpl({required this.mockDataProvider});

  @override
  Future<User?> getUserById(String id) async {
    final userData = await mockDataProvider.getUserById(id);
    if (userData == null) return null;
    return UserModel.fromJson(userData);
  }

  @override
  Future<User?> authenticateUser(String email, String password) async {
    final userData = await mockDataProvider.authenticateUser(email, password);
    if (userData == null) return null;
    return UserModel.fromJson(userData);
  }

  @override
  Future<List<User>> getUsersManagingTank(String tankId) async {
    // Esta funcionalidad podría implementarse en el mockDataProvider
    // o simularse con los datos existentes
    final allUsers = await mockDataProvider.getUsers();
    return allUsers
        .where((user) => user['managedTanks']?.contains(tankId) ?? false)
        .map((data) => UserModel.fromJson(data))
        .toList();
  }
}