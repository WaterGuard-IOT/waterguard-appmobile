import 'package:waterguard/data/services/http_service.dart';

class AuthService {
  final HttpService _httpService;

  AuthService(this._httpService);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _httpService.post('/auth/login', data: {
      'username': email, // El backend usa 'username' para login
      'password': password,
    });

    final data = response.data;

    // Guardar el token
    if (data['token'] != null) {
      await _httpService.saveToken(data['token']);
    }

    return data;
  }

  Future<String> register(String username, String email, String password) async {
    final response = await _httpService.post('/auth/register', data: {
      'username': username,
      'email': email,
      'password': password,
    });

    return response.data as String;
  }

  Future<List<dynamic>> getUsers() async {
    final response = await _httpService.get('/auth/users');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final users = await getUsers();
      return users.firstWhere(
            (user) => user['email'] == email,
        orElse: () => null,
      );
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    try {
      final users = await getUsers();
      return users.firstWhere(
            (user) => user['username'] == username,
        orElse: () => null,
      );
    } catch (e) {
      print('Error getting user by username: $e');
      return null;
    }
  }

  // Método para crear usuario de prueba si no existe
  Future<Map<String, dynamic>?> createTestUserIfNeeded() async {
    try {
      final existingUser = await getUserByEmail('test@waterguard.com');
      if (existingUser != null) {
        return existingUser;
      }

      // Crear usuario de prueba
      await register('test_user', 'test@waterguard.com', 'password123');
      return await getUserByEmail('test@waterguard.com');
    } catch (e) {
      print('Error creating test user: $e');
      return null;
    }
  }
}