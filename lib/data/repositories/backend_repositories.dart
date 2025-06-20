// lib/data/repositories/backend_repositories.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:waterguard/data/models/backend_models.dart';
import 'package:waterguard/data/services/auth_service.dart';
import 'package:waterguard/data/services/tank_service.dart';
import 'package:waterguard/domain/entities/alert.dart';
import 'package:waterguard/domain/entities/tank.dart';
import 'package:waterguard/domain/entities/user.dart';
import 'package:waterguard/domain/entities/water_quality.dart';
import 'package:waterguard/domain/repositories/alert_repository.dart';
import 'package:waterguard/domain/repositories/tank_repository.dart';
import 'package:waterguard/domain/repositories/user_repository.dart';
import 'package:waterguard/domain/repositories/water_quality_repository.dart';

// --- IMPLEMENTACIÓN DEL REPOSITORIO DE USUARIO (CORREGIDA) ---
class BackendUserRepositoryImpl implements UserRepository {
  final AuthService _authService;

  BackendUserRepositoryImpl({required AuthService authService})
      : _authService = authService;

  @override
  Future<User?> authenticateUser(String username, String password) async {
    try {
      // 1. Llama al servicio de login. Este se encarga de la llamada HTTP
      //    y de guardar el token si el login es exitoso.
      final loginResponse = await _authService.login(username, password);

      if (loginResponse.isEmpty) {
        print('❌ Repo: Login falló, la respuesta del servicio está vacía.');
        return null;
      }

      // 2. Tras un login exitoso, el backend no devuelve toda la info del usuario.
      //    Por lo tanto, la buscamos usando el 'username' que ya conocemos.
      print('✅ Repo: Login exitoso. Buscando detalles del usuario "$username"...');
      final userData = await _authService.getUserByUsername(username);

      if (userData == null) {
        print('❌ Repo: No se pudo obtener la info del usuario tras el login.');
        return null;
      }

      // 3. Guarda el ID del usuario en SharedPreferences para futuras consultas.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_id', userData['id'].toString());
      print('💾 Repo: ID de usuario guardado: ${userData['id']}');

      // 4. Convierte el JSON a una entidad User y la devuelve.
      return BackendUserModel.fromJson(userData);
    } catch (e) {
      print('💥 Repo: Error catastrófico en la autenticación: $e');
      return null; // Devuelve null si cualquier paso falla.
    }
  }

  @override
  Future<User?> getUserById(String id) async {
    // Esta implementación puede variar, pero un ejemplo simple sería:
    try {
      final users = await _authService.getUsers();
      final userData = users.firstWhere(
            (user) => user['id'].toString() == id,
        orElse: () => null,
      );
      return userData != null ? BackendUserModel.fromJson(userData) : null;
    } catch (e) {
      print('Error getting user by id: $e');
      return null;
    }
  }

  @override
  Future<List<User>> getUsersManagingTank(String tankId) async {
    // Implementación de ejemplo
    return [];
  }
}


// --- OTRAS IMPLEMENTACIONES DE REPOSITORIOS (SIN CAMBIOS) ---

// Repositorio de Tanques para Backend
class BackendTankRepositoryImpl implements TankRepository {
  final TankService _tankService;

  BackendTankRepositoryImpl({required TankService tankService})
      : _tankService = tankService;

  @override
  Future<List<Tank>> getTanks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdString = prefs.getString('current_user_id');
      if (userIdString == null) return [];

      final userId = int.parse(userIdString);
      final tanksData = await _tankService.getTanksByUser(userId);
      return tanksData.map((data) => BackendTankModel.fromJson(data)).toList();
    } catch (e) {
      print('Error getting tanks: $e');
      return [];
    }
  }

  @override
  Future<Tank?> getTankById(String id) async {
    try {
      final tankId = int.parse(id);
      final tankData = await _tankService.getTankById(tankId);
      return BackendTankModel.fromJson(tankData);
    } catch (e) {
      print('Error getting tank by id: $e');
      return null;
    }
  }

  @override
  Future<void> togglePump(String id, bool active) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('Toggle pump for tank $id: $active (simulated)');
  }
}

// Repositorio de Calidad de Agua para Backend
class BackendWaterQualityRepositoryImpl implements WaterQualityRepository {
  final TankService _tankService;

  BackendWaterQualityRepositoryImpl({required TankService tankService})
      : _tankService = tankService;

  @override
  Future<List<WaterQuality>> getWaterQualityReadings() async {
    return [];
  }

  @override
  Future<WaterQuality?> getWaterQualityForTank(String tankId) async {
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getHistoricalData(String tankId) async {
    return [];
  }
}

// Repositorio de Alertas para Backend (simulado)
class BackendAlertRepositoryImpl implements AlertRepository {
  @override
  Future<List<Alert>> getAlerts({bool? resolved}) async {
    return [];
  }

  @override
  Future<Alert?> getAlertById(String id) async {
    return null;
  }

  @override
  Future<void> markAsResolved(String id) async {
    // No-op
  }
}
