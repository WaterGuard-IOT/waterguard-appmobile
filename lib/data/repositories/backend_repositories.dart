// lib/data/repositories/backend_repositories.dart - ERROR userData CORREGIDO
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

      // Buscar el usuario por ID de forma segura
      Map<String, dynamic>? userData;
      try {
        userData = users.firstWhere(
              (user) => user['id'].toString() == id,
        );
      } catch (e) {
        print('Usuario con ID $id no encontrado');
        return null;
      }

      // ✅ VERIFICACIÓN EXPLÍCITA ANTES DE USAR userData
      if (userData == null) {
        print('Error: userData es null para ID $id');
        return null;
      }

      return BackendUserModel.fromJson(userData);
    } catch (e) {
      print('Error getting user by id: $e');
      return null;
    }
  }

  @override
  Future<User?> authenticateUser(String email, String password) async {
    try {
      Map<String, dynamic>? loginResponse;

      // Intentar login directo con email como username
      try {
        print('🔐 Intentando login con email: $email');
        loginResponse = await _authService.login(email, password);
        print('✅ Login exitoso con email');
      } catch (e) {
        print('❌ Login con email falló: $e');

        // Si falla con email, intentar con username
        try {
          print('🔄 Intentando login con username estimado...');
          final username = email.split('@')[0];
          loginResponse = await _authService.login(username, password);
          print('✅ Login exitoso con username: $username');
        } catch (e2) {
          print('❌ Login con username también falló: $e2');
          return null;
        }
      }

      // Verificar que tenemos respuesta válida
      if (loginResponse == null || loginResponse.isEmpty) {
        print('❌ No se pudo hacer login - respuesta vacía');
        return null;
      }

      // Obtener información del usuario
      Map<String, dynamic>? userData;
      try {
        print('📋 Obteniendo información del usuario...');
        userData = await _authService.getUserByEmail(email);
        print('✅ Información del usuario obtenida');
      } catch (e) {
        print('⚠️ No se pudo obtener info del usuario: $e');

        // Si no podemos obtener la info del usuario, crear datos básicos
        userData = <String, dynamic>{  // ✅ TIPO EXPLÍCITO NO-NULLABLE
          'id': 1,
          'username': email.split('@')[0],
          'email': email,
          'tanques': <Map<String, dynamic>>[], // Lista explícitamente tipada
        };
        print('📝 Usando datos básicos del usuario');
      }

      // ✅ VERIFICACIÓN EXPLÍCITA ANTES DE USAR userData
      if (userData == null) {
        print('❌ No se pudo obtener datos del usuario después de login');
        return null;
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
      final List<User> managingUsers = [];

      for (final userData in users) {
        // ✅ VERIFICACIÓN EXPLÍCITA DE userData
        if (userData == null) continue;

        // Verificación segura de la existencia de 'tanques'
        final tanques = userData['tanques'];
        if (tanques != null && tanques is List) {
          final hasTank = tanques.any((tanque) {
            if (tanque != null && tanque is Map<String, dynamic>) {
              return tanque['id']?.toString() == tankId;
            }
            return false;
          });

          if (hasTank) {
            managingUsers.add(BackendUserModel.fromJson(userData));
          }
        }
      }

      return managingUsers;
    } catch (e) {
      print('Error getting users managing tank: $e');
      return [];
    }
  }

  // Método adicional para crear datos de prueba
  Future<User?> createTestUser() async {
    try {
      final userData = await _authService.createTestUserIfNeeded();

      // ✅ VERIFICACIÓN EXPLÍCITA ANTES DE USAR userData
      if (userData == null) {
        print('❌ No se pudo crear usuario de prueba');
        return null;
      }

      return BackendUserModel.fromJson(userData);
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
      final prefs = await SharedPreferences.getInstance();
      final userIdString = prefs.getString('current_user_id');

      if (userIdString == null) {
        print('No hay usuario logueado');
        return [];
      }

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
      final prefs = await SharedPreferences.getInstance();
      final userIdString = prefs.getString('current_user_id');

      if (userIdString == null) return [];

      final userId = int.parse(userIdString);
      final tanksData = await _tankService.getTanksByUser(userId);
      final List<WaterQuality> qualities = [];

      for (var tankData in tanksData) {
        // ✅ VERIFICACIÓN EXPLÍCITA DE tankData
        if (tankData == null) continue;

        // Verificación segura de la existencia de 'calidad'
        final calidadData = tankData['calidad'];
        if (calidadData != null && calidadData is Map<String, dynamic>) {
          final quality = BackendWaterQualityModel.fromJson(
            calidadData,
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

      // ✅ VERIFICACIÓN EXPLÍCITA DE tankData
      if (tankData == null) {
        print('Error: tankData es null para tank ID $tankId');
        return null;
      }

      // Verificación segura de la existencia de 'calidad'
      final calidadData = tankData['calidad'];
      if (calidadData == null || calidadData is! Map<String, dynamic>) {
        return null;
      }

      return BackendWaterQualityModel.fromJson(calidadData, tankId);
    } catch (e) {
      print('Error getting water quality for tank: $e');
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getHistoricalData(String tankId) async {
    try {
      final tankIdInt = int.parse(tankId);
      final tankData = await _tankService.getTankById(tankIdInt);

      // ✅ VERIFICACIÓN EXPLÍCITA DE tankData
      if (tankData == null) {
        print('Error: tankData es null para historical data tank ID $tankId');
        return _generateFallbackHistoricalData();
      }

      final List<Map<String, dynamic>> historicalData = [];
      final now = DateTime.now();

      // Obtener el nivel actual si existe
      double baseLevel = 500.0; // Nivel base por defecto
      final nivelData = tankData['nivel'];
      if (nivelData != null && nivelData is Map<String, dynamic>) {
        final porcentaje = nivelData['porcentaje'];
        if (porcentaje != null && porcentaje is num) {
          baseLevel = 1000.0 * (porcentaje / 100.0);
        }
      }

      // Generar datos históricos simulados basados en el nivel actual
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
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
      return _generateFallbackHistoricalData();
    }
  }

  // ✅ MÉTODO HELPER PARA DATOS FALLBACK
  List<Map<String, dynamic>> _generateFallbackHistoricalData() {
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