// lib/data/datasources/mock/mock_data_provider.dart
import 'dart:convert';
import 'package:flutter/services.dart';

class MockDataProvider {
  // Listas para almacenar datos mock
  List<dynamic> tanks = [];
  List<dynamic> qualityReadings = [];
  List<dynamic> alerts = [];
  List<dynamic> users = [];
  List<Map<String, dynamic>> historicalData = [];

  // Método para inicializar los datos desde archivos JSON
  Future<void> init() async {
    try {
      // Cargar datos de tanques
      final tanksJson = await rootBundle.loadString('assets/data/water_tanks.json');
      final tanksData = json.decode(tanksJson);
      tanks = tanksData['tanks'];

      // Cargar datos de calidad de agua
      final qualityJson = await rootBundle.loadString('assets/data/water_quality.json');
      final qualityData = json.decode(qualityJson);
      qualityReadings = qualityData['qualityReadings'];

      // Cargar datos de alertas
      final alertsJson = await rootBundle.loadString('assets/data/alerts.json');
      final alertsData = json.decode(alertsJson);
      alerts = alertsData['alerts'];

      // Cargar datos de usuarios
      final usersJson = await rootBundle.loadString('assets/data/users.json');
      final usersData = json.decode(usersJson);
      users = usersData['users'];

      // Cargar datos históricos
      final historicalJson = await rootBundle.loadString('assets/data/historical_levels.json');
      final historicalData = json.decode(historicalJson);

      // Convertir historicalData a List<Map<String, dynamic>>
      if (historicalData.containsKey('historicalData')) {
        this.historicalData = List<Map<String, dynamic>>.from(
            historicalData['historicalData'].map((item) => Map<String, dynamic>.from(item))
        );
      }

      print('MockDataProvider inicializado correctamente');
    } catch (e) {
      print('Error al inicializar MockDataProvider: $e');
      // En caso de error, inicializar con listas vacías
    }
  }

  // Métodos para acceder a los datos
  Future<List<dynamic>> getTanks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return tanks;
  }

  Future<dynamic> getTankById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return tanks.firstWhere((tank) => tank['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>> getWaterQualityReadings() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return qualityReadings;
  }

  Future<dynamic> getWaterQualityForTank(String tankId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return qualityReadings.firstWhere((reading) => reading['tankId'] == tankId);
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>> getAlerts({bool? resolved}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (resolved != null) {
      return alerts.where((alert) => alert['resolved'] == resolved).toList();
    }
    return alerts;
  }

  // NUEVO: Método para obtener la lista de usuarios
  Future<List<dynamic>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return users;
  }

  Future<dynamic> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return users.firstWhere((user) => user['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> authenticateUser(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return users.firstWhere((user) => user['email'] == email);
    } catch (e) {
      return null;
    }
  }

  // CORREGIDO: Método para obtener los datos históricos con el tipo correcto
  Future<List<Map<String, dynamic>>> getHistoricalData(String tankId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final tankData = historicalData.firstWhere(
              (item) => item['tankId'] == tankId,
          orElse: () => {'readings': []}
      );
      return List<Map<String, dynamic>>.from(tankData['readings'] ?? []);
    } catch (e) {
      return [];
    }
  }

  Future<void> togglePump(String id, bool active) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = tanks.indexWhere((tank) => tank['id'] == id);
    if (index != -1) {
      tanks[index]['pumpActive'] = active;
      tanks[index]['lastUpdated'] = DateTime.now().toIso8601String();
    }
  }

  // NUEVO: Método para marcar una alerta como resuelta
  Future<void> markAlertAsResolved(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = alerts.indexWhere((alert) => alert['id'] == id);
    if (index != -1) {
      alerts[index]['resolved'] = true;
    }
  }
}