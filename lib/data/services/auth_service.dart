// lib/data/services/auth_service.dart - CON DEBUGGING Y USUARIO DE PRUEBA
import 'package:waterguard/data/services/http_service.dart';

class AuthService {
  final HttpService _httpService;

  AuthService(this._httpService);

  // ✅ MÉTODO PARA VERIFICAR USUARIOS EXISTENTES
  Future<void> debugShowExistingUsers() async {
    print('🔍 === DEBUGGING: Verificando usuarios existentes ===');
    try {
      // Intentar obtener usuarios sin autenticación
      final response = await _httpService.get('/auth/users');
      final users = response.data as List<dynamic>;

      print('📋 Usuarios encontrados en el backend:');
      if (users.isEmpty) {
        print('❌ No hay usuarios registrados en el backend');
        print('💡 Necesitas crear un usuario primero usando register');
      } else {
        for (int i = 0; i < users.length; i++) {
          final user = users[i];
          print('   ${i + 1}. Usuario: ${user['username']}, Email: ${user['email']}, ID: ${user['id']}');
        }
      }
    } catch (e) {
      print('❌ No se pudo obtener lista de usuarios: $e');
      print('💡 Esto es normal si necesitas estar autenticado para ver usuarios');
    }
    print('🔍 === FIN DEBUGGING ===');
  }

  // ✅ MÉTODO ESPECÍFICO PARA DEBUGGEAR EL PROBLEMA DE jp@gmail.com
  Future<void> debugSpecificUser(String email) async {
    print('🔍 === DEBUGGING USUARIO ESPECÍFICO: $email ===');
    try {
      final response = await _httpService.get('/auth/users');
      final users = response.data as List<dynamic>;

      // Buscar usuario específico por email
      final user = users.firstWhere(
            (user) => user['email'] == email,
        orElse: () => null,
      );

      if (user != null) {
        print('✅ Usuario encontrado:');
        print('   📧 Email: ${user['email']}');
        print('   👤 Username: ${user['username']}');
        print('   🆔 ID: ${user['id']}');
        print('   📅 Otros campos: ${user.keys.toList()}');
        print('');
        print('💡 Para login usa:');
        print('   Username: ${user['username']}');
        print('   Password: [tu contraseña]');
      } else {
        print('❌ No se encontró usuario con email: $email');
        print('📋 Usuarios disponibles:');
        for (var u in users) {
          print('   - ${u['username']} (${u['email']})');
        }
      }
    } catch (e) {
      print('❌ Error al buscar usuario específico: $e');
    }
    print('🔍 === FIN DEBUGGING ESPECÍFICO ===');
  }

  // ✅ MÉTODO PARA CREAR USUARIO DE PRUEBA Y HACER LOGIN AUTOMÁTICO
  Future<Map<String, dynamic>?> setupTestUserAndLogin() async {
    print('🧪 === SETUP USUARIO DE PRUEBA ===');

    // Datos del usuario de prueba
    const testUsername = 'waterguard_test';
    const testEmail = 'test@waterguard.com';
    const testPassword = 'WaterGuard2024!';

    try {
      // 1. Intentar crear el usuario de prueba
      print('📝 Creando usuario de prueba...');
      await register(testUsername, testEmail, testPassword);
      print('✅ Usuario de prueba creado exitosamente');

      // 2. Hacer login automático
      print('🔐 Haciendo login automático...');
      final loginResult = await login(testEmail, testPassword);
      print('✅ Login automático exitoso');

      return loginResult;

    } catch (e) {
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('already exists') ||
          errorString.contains('duplicate') ||
          errorString.contains('ya existe')) {
        print('ℹ️ Usuario de prueba ya existe, intentando login...');
        try {
          final loginResult = await login(testEmail, testPassword);
          print('✅ Login con usuario existente exitoso');
          return loginResult;
        } catch (loginError) {
          print('❌ Error en login con usuario existente: $loginError');
          return null;
        }
      } else {
        print('❌ Error en setup de usuario de prueba: $e');
        return null;
      }
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    print('🔐 AuthService.login() llamado con: $email');

    // ✅ LIMPIAR SESIÓN ANTERIOR ANTES DE LOGIN
    await _httpService.clearSession();

    // ✅ ESTRATEGIA DUAL: Intentar login por email Y por username
    try {
      // INTENTO 1: Login directo con email como username
      print('📧 Intento 1: Login con email como username');
      final response = await _httpService.post('/auth/login', data: {
        'username': email,
        'password': password,
      });

      final data = response.data;
      print('📦 Login exitoso con email: $data');

      if (data['token'] != null) {
        await _httpService.saveToken(data['token']);
        print('🎫 Token guardado: ${data['token'].substring(0, 20)}...');
      }

      return data;
    } catch (e) {
      print('❌ Login con email falló: $e');

      // INTENTO 2: Buscar el username real del usuario por email
      try {
        print('🔍 Intento 2: Buscando username real por email...');
        final users = await getUsers();

        // Buscar usuario por email en la lista
        final user = users.firstWhere(
              (user) => user['email'] == email,
          orElse: () => null,
        );

        if (user != null && user['username'] != null) {
          final realUsername = user['username'];
          print('✅ Username real encontrado: $realUsername');

          // Login con el username real
          final response = await _httpService.post('/auth/login', data: {
            'username': realUsername,
            'password': password,
          });

          final data = response.data;
          print('📦 Login exitoso con username real: $data');

          if (data['token'] != null) {
            await _httpService.saveToken(data['token']);
            print('🎫 Token guardado: ${data['token'].substring(0, 20)}...');
          }

          return data;
        } else {
          print('❌ No se encontró usuario con email: $email');
          throw Exception('Usuario no encontrado con email: $email');
        }
      } catch (e2) {
        print('❌ Error en intento 2: $e2');

        // INTENTO 3: Login con username estimado (primera parte del email)
        try {
          print('🔄 Intento 3: Username estimado de email...');
          final estimatedUsername = email.split('@')[0];

          final response = await _httpService.post('/auth/login', data: {
            'username': estimatedUsername,
            'password': password,
          });

          final data = response.data;
          print('📦 Login exitoso con username estimado: $data');

          if (data['token'] != null) {
            await _httpService.saveToken(data['token']);
            print('🎫 Token guardado: ${data['token'].substring(0, 20)}...');
          }

          return data;
        } catch (e3) {
          print('❌ Todos los intentos de login fallaron');
          print('   - Email como username: $e');
          print('   - Username real: $e2');
          print('   - Username estimado: $e3');
          rethrow;
        }
      }
    }
  }

  Future<String> register(String username, String email, String password) async {
    print('📝 AuthService.register() llamado para: $username');

    // ✅ LIMPIAR CUALQUIER SESIÓN ANTERIOR ANTES DE REGISTRO
    await _httpService.clearSession();

    final response = await _httpService.post('/auth/register', data: {
      'username': username,
      'email': email,
      'password': password,
    });

    print('✅ Usuario registrado exitosamente: $username');
    return response.data as String;
  }

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
        print('🔒 Error de autorización: No autorizado para obtener usuarios');
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
      if (e.toString().contains('403') || e.toString().contains('401')) {
        print('📝 Error de autorización - Creando datos básicos para el usuario');
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

  // ✅ MÉTODO PARA LOGOUT/LIMPIAR SESIÓN
  Future<void> logout() async {
    print('🚪 Cerrando sesión...');
    await _httpService.clearSession();
    print('✅ Sesión cerrada correctamente');
  }

  // ✅ MÉTODO PARA CREAR USUARIOS DE PRUEBA ESPECÍFICOS
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

  // ✅ MÉTODO PARA COMPATIBILIDAD (MÉTODO FALTANTE)
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