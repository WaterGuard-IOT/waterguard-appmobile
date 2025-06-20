// lib/data/services/auth_service.dart - SIMPLIFICADO PARA USERNAME DIRECTO
import 'package:waterguard/data/services/http_service.dart';

class AuthService {
  final HttpService _httpService;

  AuthService(this._httpService);

  // ✅ LOGIN SIMPLIFICADO - DIRECTO AL BACKEND
  Future<Map<String, dynamic>> login(String username, String password) async {
    print('🔐 AuthService.login() llamado con username: $username');

    // Limpiar sesión anterior
    await _httpService.clearSession();

    try {
      // Login directo con username - tal como espera el backend
      final response = await _httpService.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      final data = response.data;
      print('📦 Login exitoso: $data');

      // Guardar token si existe
      if (data['token'] != null) {
        await _httpService.saveToken(data['token']);
        print('🎫 Token guardado: ${data['token'].substring(0, 20)}...');
      }

      return data;
    } catch (e) {
      print('❌ Error en login: $e');
      rethrow;
    }
  }

  // ✅ REGISTRO SIMPLIFICADO
  Future<String> register(String username, String email, String password) async {
    print('📝 AuthService.register() llamado para: $username');

    // Limpiar cualquier sesión anterior
    await _httpService.clearSession();

    try {
      final response = await _httpService.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });

      print('✅ Usuario registrado exitosamente: $username');
      return response.data as String;
    } catch (e) {
      print('❌ Error en registro: $e');
      rethrow;
    }
  }

  // ✅ OBTENER USUARIOS (PARA DEBUG)
  Future<List<dynamic>> getUsers() async {
    print('👥 AuthService.getUsers() llamado');

    try {
      final response = await _httpService.get('/auth/users');
      print('✅ Usuarios obtenidos: ${response.data.length} usuarios');
      return response.data as List<dynamic>;
    } catch (e) {
      print('❌ Error al obtener usuarios: $e');
      // Si falla por autenticación, devolver lista vacía
      if (e.toString().contains('403') || e.toString().contains('401')) {
        print('🔒 No autorizado para obtener usuarios');
        return [];
      }
      rethrow;
    }
  }

  // ✅ OBTENER USUARIO POR ID (SIMPLIFICADO)
  Future<Map<String, dynamic>?> getUserById(String id) async {
    print('🔍 AuthService.getUserById() llamado con ID: $id');

    try {
      final users = await getUsers();

      if (users.isEmpty) {
        print('📝 Lista de usuarios vacía');
        return null;
      }

      final user = users.firstWhere(
            (user) => user['id'].toString() == id,
        orElse: () => null,
      );

      if (user != null) {
        print('✅ Usuario encontrado: ${user['username']}');
      } else {
        print('❌ Usuario no encontrado con ID: $id');
      }

      return user;
    } catch (e) {
      print('❌ Error al buscar usuario por ID: $e');
      return null;
    }
  }

  // ✅ BUSCAR USUARIO POR USERNAME
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

  // ✅ LOGOUT/LIMPIAR SESIÓN
  Future<void> logout() async {
    print('🚪 Cerrando sesión...');
    await _httpService.clearSession();
    print('✅ Sesión cerrada correctamente');
  }

  // ✅ DEBUG: MOSTRAR USUARIOS EXISTENTES
  Future<void> debugShowExistingUsers() async {
    print('🔍 === DEBUGGING: Verificando usuarios existentes ===');
    try {
      final users = await getUsers();

      print('📋 Usuarios encontrados en el backend:');
      if (users.isEmpty) {
        print('❌ No hay usuarios registrados en el backend');
        print('💡 Necesitas crear un usuario primero usando register');
      } else {
        for (int i = 0; i < users.length; i++) {
          final user = users[i];
          print('   ${i + 1}. Username: ${user['username']}, Email: ${user['email']}, ID: ${user['id']}');
        }
      }
    } catch (e) {
      print('❌ No se pudo obtener lista de usuarios: $e');
    }
    print('🔍 === FIN DEBUGGING ===');
  }

  // ✅ CREAR USUARIO DE PRUEBA ESPECÍFICO
  Future<bool> createSpecificTestUser(String username, String email, String password) async {
    print('🧪 Creando usuario específico: $username');
    try {
      await register(username, email, password);
      print('✅ Usuario $username creado exitosamente');
      return true;
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('already exists') ||
          errorString.contains('duplicate') ||
          errorString.contains('ya existe')) {
        print('ℹ️ Usuario $username ya existe');
        return true;
      } else {
        print('❌ Error creando usuario $username: $e');
        return false;
      }
    }
  }

  // ✅ MÉTODO DE COMPATIBILIDAD PARA EL REPOSITORIO
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    print('🔍 AuthService.getUserByEmail() llamado con: $email');

    try {
      final users = await getUsers();
      final user = users.firstWhere(
            (user) => user['email'] == email,
        orElse: () => null,
      );

      if (user != null) {
        print('✅ Usuario encontrado por email: ${user['username']}');
      } else {
        print('❌ Usuario no encontrado con email: $email');
      }

      return user;
    } catch (e) {
      print('❌ Error al buscar usuario por email: $e');
      return null;
    }
  }

  // ✅ MÉTODO PARA CREAR USUARIO DE PRUEBA SI NO EXISTE
  Future<Map<String, dynamic>?> createTestUserIfNeeded() async {
    print('🧪 AuthService.createTestUserIfNeeded() llamado');

    try {
      const testUsername = 'testuser';
      const testEmail = 'test@waterguard.com';
      const testPassword = 'password123';

      // Verificar si ya existe
      final existingUser = await getUserByUsername(testUsername);
      if (existingUser != null) {
        print('✅ Usuario de prueba ya existe');
        return existingUser;
      }

      // Crear usuario de prueba
      print('📝 Creando usuario de prueba...');
      await register(testUsername, testEmail, testPassword);
      return await getUserByUsername(testUsername);
    } catch (e) {
      print('❌ Error al crear usuario de prueba: $e');

      // Si falla, devolver datos de prueba básicos
      return {
        'id': 1,
        'username': 'testuser',
        'email': 'test@waterguard.com',
        'tanques': [],
      };
    }
  }
}