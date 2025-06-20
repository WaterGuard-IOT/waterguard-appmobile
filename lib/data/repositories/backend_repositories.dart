// Repositorios que se conectan al backend

import 'package:waterguard/data/services/auth_service.dart';
import 'package:waterguard/data/services/tank_service.dart';
import 'package:waterguard/domain/entities/user.dart';
import 'package:waterguard/domain/entities/tank.dart';
import 'package:waterguard/domain/entities/water_quality.dart';
import 'package:waterguard/domain/entities/alert.dart';
import 'package:waterguard/domain/repositories/user_repository.dart';
import 'package:waterguard/domain/repositories/tank_repository.dart';
import 'package:waterguard/domain/repositories/water_quality_repository.dart';
import 'package:waterguard/domain/repositories/alert_repository.dart';
import 'package:waterguard/data/models/backend_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Repositorio de Usuario para Backend
class BackendUserRepositoryImpl implements UserRepository {
  final AuthService _authService;

  BackendUserRepositoryImpl({required AuthService authService})
      : _authService = authService;

  @override
  Future<User?> getUserById(String id) async {
    try {
      final users = await _authService.getUsers();
      final userData = users.firstWhere(
            (user) => user['id'].toString() == id,
        orElse: () => null,
      );

      if (userData == null) return null;
      return BackendUserModel.fromJson(userData);
    } catch (e) {
      print('Error getting user by id: $e');
      return null;
    }
  }

  @override
  Future<User?> authenticateUser(String email, String password) async {
    try {
      // FLUJO CORREGIDO: Primero hacer login
      Map<String, dynamic>? loginResponse;

      // Intentar login directo con email como username
      try {
        print('🔐 Intentando login con email: $email');
        loginResponse = await _authService.login(email, password);
        print('✅ Login exitoso con email');
      } catch (e) {
        print('❌ Login con email falló: $e');

        // Si falla con email, intentar primero obtener el username
        // Para esto necesitamos crear un usuario de prueba o usar datos conocidos
        try {
          print('🔄 Intentando login con username estimado...');
          // Extraer nombre de usuario del email
          final username = email.split('@')[0];
          loginResponse = await _authService.login(username, password);
          print('✅ Login exitoso con username: $username');
        } catch (e2) {
          print('❌ Login con username también falló: $e2');
          return null;
        }
      }

      if (loginResponse == null) {
        print('❌ No se pudo hacer login');
        return null;
      }

      // FLUJO CORREGIDO: Ahora que tenemos token, obtener información del usuario
      Map<String, dynamic>? userData;
      try {
        print('📋 Obteniendo información del usuario...');
        userData = await _authService.getUserByEmail(email);
        print('✅ Información del usuario obtenida');
      } catch (e) {
        print('⚠️ No se pudo obtener info del usuario: $e');
        // Si no podemos obtener la info del usuario, crear datos básicos
        userData = {
          'id': 1, // ID temporal
          'username': email.split('@')[0],
          'email': email,
          'tanques': [], // Lista vacía de tanques
        };
        print('📝 Usando datos básicos del usuario');
      }

      // Guardar el ID del usuario para futuras consultas
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_id', userData['id'].toString());
      print('💾 ID del usuario guardado: ${userData['id']}');

      return BackendUserModel.fromJson(userData);
    } catch (e) {
      print('💥 Error general en autenticación: $e');
      return null;
    }
  }

  @override
  Future<List<User>> getUsersManagingTank(String tankId) async {
    try {
      final users = await _authService.getUsers();
      return users
          .where((user) {
        final tanques = user['tanques'] as List?;
        return tanques?.any((tanque) => tanque['id'].toString() == tankId) ?? false;
      })
          .map((userData) => BackendUserModel.fromJson(userData))
          .toList();
    } catch (e) {
      print('Error getting users managing tank: $e');
      return [];
    }
  }

  // Método adicional para crear datos de prueba
  Future<User?> createTestUser() async {
    try {
      return await _authService.createTestUserIfNeeded().then((userData) {
        if (userData != null) {
          return BackendUserModel.fromJson(userData);
        }
        return null;
      });
    } catch (e) {
      print('Error creating test user: $e');
      return null;
    }
  }
}

// Repositorio de Tanques para Backend
class BackendTankRepositoryImpl implements TankRepository {
  final TankService _tankService;

  BackendTankRepositoryImpl({required TankService tankService})
      : _tankService = tankService;

  @override
  Future<List<Tank>> getTanks() async {
    try {
      // Obtener el ID del usuario actual
      final prefs = await SharedPreferences.getInstance();
      final userIdString = prefs.getString('current_user_id');

      if (userIdString == null) return [];

      final userId = int.parse(userIdString);
      final tanksData = await _tankService.getTanksByUser(userId);
      return tanksData
          .map((data) => BackendTankModel.fromJson(data))
          .toList();
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
    // Esta funcionalidad no está disponible en el backend actual
    // Se puede simular o implementar más adelante
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
    try {
      // Obtener todos los tanques y sus datos de calidad
      final prefs = await SharedPreferences.getInstance();
      final userIdString = prefs.getString('current_user_id');

      if (userIdString == null) return [];

      final userId = int.parse(userIdString);
      final tanksData = await _tankService.getTanksByUser(userId);
      final List<WaterQuality> qualities = [];

      for (var tankData in tanksData) {
        if (tankData['calidad'] != null) {
          final quality = BackendWaterQualityModel.fromJson(
            tankData['calidad'],
            tankData['id'].toString(),
          );
          qualities.add(quality);
        }
      }

      return qualities;
    } catch (e) {
      print('Error getting water quality readings: $e');
      return [];
    }
  }

  @override
  Future<WaterQuality?> getWaterQualityForTank(String tankId) async {
    try {
      final tankIdInt = int.parse(tankId);
      final tankData = await _tankService.getTankById(tankIdInt);

      if (tankData['calidad'] == null) return null;

      return BackendWaterQualityModel.fromJson(
        tankData['calidad'],
        tankId,
      );
    } catch (e) {
      print('Error getting water quality for tank: $e');
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getHistoricalData(String tankId) async {
    // El backend actual no tiene datos históricos, generamos algunos ficticios
    // pero basados en datos reales del tanque si están disponibles
    try {
      final tankIdInt = int.parse(tankId);
      final tankData = await _tankService.getTankById(tankIdInt);

      final List<Map<String, dynamic>> historicalData = [];
      final now = DateTime.now();

      // Obtener el nivel actual si existe
      double baseLevel = 500.0; // Nivel base por defecto
      if (tankData['nivel'] != null && tankData['nivel']['porcentaje'] != null) {
        baseLevel = 1000.0 * (tankData['nivel']['porcentaje'] / 100.0);
      }

      // Generar datos históricos simulados basados en el nivel actual
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        // Variar el nivel alrededor del nivel base
        final variation = (i % 3 == 0 ? -50 : 50) + (i * 10);
        final level = (baseLevel + variation).clamp(100.0, 1000.0);

        historicalData.add({
          'timestamp': date.toIso8601String(),
          'level': level,
        });
      }

      return historicalData;
    } catch (e) {
      print('Error getting historical data: $e');
      // Fallback a datos completamente ficticios
      final List<Map<String, dynamic>> historicalData = [];
      final now = DateTime.now();

      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final level = 400 + (i * 50) + (i % 2 == 0 ? 100 : 50);

        historicalData.add({
          'timestamp': date.toIso8601String(),
          'level': level,
        });
      }

      return historicalData;
    }
  }
}

// Repositorio de Alertas para Backend (usando datos simulados)
class BackendAlertRepositoryImpl implements AlertRepository {
  @override
  Future<List<Alert>> getAlerts({bool? resolved}) async {
    // El backend actual no maneja alertas, retornamos lista vacía
    // Se puede implementar más adelante
    return [];
  }

  @override
  Future<Alert?> getAlertById(String id) async {
    return null;
  }

  @override
  Future<void> markAsResolved(String id) async {
    // Implementar cuando el backend soporte alertas
  }
}