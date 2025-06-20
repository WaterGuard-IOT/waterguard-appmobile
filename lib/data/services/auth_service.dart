import 'package:waterguard/data/services/http_service.dart';

class AuthService {
  final HttpService _httpService;

  AuthService(this._httpService);

  Future<Map<String, dynamic>> login(String email, String password) async {
    print('🔐 AuthService.login() llamado con: $email');

    final response = await _httpService.post('/auth/login', data: {
      'username': email, // El backend usa 'username' para login
      'password': password,
    });

    final data = response.data;
    print('📦 Respuesta del login: $data');

    // Guardar el token
    if (data['token'] != null) {
      await _httpService.saveToken(data['token']);
      print('🎫 Token guardado: ${data['token'].substring(0, 20)}...');
    }

    return data;
  }

  Future<String> register(String username, String email, String password) async {
    print('📝 AuthService.register() llamado');

    final response = await _httpService.post('/auth/register', data: {
      'username': username,
      'email': email,
      'password': password,
    });

    print('✅ Usuario registrado exitosamente');
    return response.data as String;
  }

  Future<List<dynamic>> getUsers() async {
    print('👥 AuthService.getUsers() llamado');

    try {
      final response = await _httpService.get('/auth/users');
      print('✅ Usuarios obtenidos: ${response.data}');
      return response.data as List<dynamic>;
    } catch (e) {
      print('❌ Error al obtener usuarios: $e');
      // Si falla por autenticación, devolver lista vacía
      if (e.toString().contains('403')) {
        print('🔒 Error 403: No autorizado para obtener usuarios');
        return [];
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    print('🔍 AuthService.getUserByEmail() llamado con: $email');

    try {
      final users = await getUsers();

      if (users.isEmpty) {
        print('📝 Lista de usuarios vacía, creando datos básicos');
        return {
          'id': 1,
          'username': email.split('@')[0],
          'email': email,
          'tanques': [],
        };
      }

      final user = users.firstWhere(
            (user) => user['email'] == email,
        orElse: () => null,
      );

      if (user != null) {
        print('✅ Usuario encontrado: ${user['username']}');
      } else {
        print('❌ Usuario no encontrado con email: $email');
      }

      return user;
    } catch (e) {
      print('❌ Error al buscar usuario por email: $e');

      // Si no podemos obtener usuarios del backend, crear datos básicos
      if (e.toString().contains('403')) {
        print('📝 Error 403 - Creando datos básicos para el usuario');
        return {
          'id': 1,
          'username': email.split('@')[0],
          'email': email,
          'tanques': [],
        };
      }

      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    print('🔍 AuthService.getUserByUsername() llamado con: $username');

    try {
      final users = await getUsers();
      final user = users.firstWhere(
            (user) => user['username'] == username,
        orElse: () => null,
      );

      if (user != null) {
        print('✅ Usuario encontrado: ${user['email']}');
      } else {
        print('❌ Usuario no encontrado con username: $username');
      }

      return user;
    } catch (e) {
      print('❌ Error al buscar usuario por username: $e');
      return null;
    }
  }

  // Método para crear usuario de prueba si no existe
  Future<Map<String, dynamic>?> createTestUserIfNeeded() async {
    print('🧪 AuthService.createTestUserIfNeeded() llamado');

    try {
      final existingUser = await getUserByEmail('test@waterguard.com');
      if (existingUser != null) {
        print('✅ Usuario de prueba ya existe');
        return existingUser;
      }

      // Crear usuario de prueba
      print('📝 Creando usuario de prueba...');
      await register('test_user', 'test@waterguard.com', 'password123');
      return await getUserByEmail('test@waterguard.com');
    } catch (e) {
      print('❌ Error al crear usuario de prueba: $e');

      // Si falla, devolver datos de prueba básicos
      return {
        'id': 1,
        'username': 'test_user',
        'email': 'test@waterguard.com',
        'tanques': [],
      };
    }
  }
}