// lib/data/services/auth_service.dart
import 'package:waterguard/data/services/http_service.dart';

class AuthService {
  final HttpService _httpService;

  AuthService(this._httpService);

  /// Realiza el login directamente contra el backend usando username y password.
  /// Lanza una excepción si el login falla.
  Future<Map<String, dynamic>> login(String username, String password) async {
    print('🔐 AuthService: Intentando login para username: $username');
    await _httpService.clearSession(); // Limpia cualquier token anterior

    try {
      final response = await _httpService.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      final data = response.data;
      if (data != null && data['token'] != null) {
        await _httpService.saveToken(data['token']);
        print('🎫 AuthService: Token guardado exitosamente.');
      }
      return data;
    } catch (e) {
      print('❌ AuthService: Error en el login: $e');
      rethrow; // Propaga el error para que sea manejado en el BLoC
    }
  }

  /// Registra un nuevo usuario en el backend.
  Future<String> register(String username, String email, String password) async {
    print('📝 AuthService: Registrando nuevo usuario: $username');
    await _httpService.clearSession();

    try {
      final response = await _httpService.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });
      print('✅ AuthService: Usuario registrado exitosamente.');
      return response.data.toString();
    } catch (e) {
      print('❌ AuthService: Error en el registro: $e');
      rethrow;
    }
  }

  /// Obtiene la lista completa de usuarios del backend.
  /// Utilizado para buscar detalles de un usuario después del login.
  Future<List<dynamic>> getUsers() async {
    print('👥 AuthService: Obteniendo lista de usuarios.');
    try {
      final response = await _httpService.get('/auth/users');
      return response.data as List<dynamic>;
    } catch (e) {
      print('❌ AuthService: Error al obtener usuarios: $e');
      return []; // Devuelve lista vacía en caso de error
    }
  }

  /// Busca un usuario específico por su nombre de usuario.
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    print('🔍 AuthService: Buscando usuario por username: $username');
    try {
      final users = await getUsers();
      final user = users.firstWhere(
            (user) => user['username'] == username,
        orElse: () => null,
      );
      if (user != null) {
        print('✅ AuthService: Usuario encontrado.');
      } else {
        print('⚠️ AuthService: Usuario no encontrado con username: $username');
      }
      return user;
    } catch (e) {
      print('❌ AuthService: Error buscando por username: $e');
      return null;
    }
  }

  /// Cierra la sesión, eliminando el token almacenado.
  Future<void> logout() async {
    print('🚪 AuthService: Cerrando sesión...');
    await _httpService.clearSession();
    print('✅ AuthService: Sesión cerrada.');
  }
}
