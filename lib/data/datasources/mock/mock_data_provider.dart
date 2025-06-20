// lib/data/datasources/mock/mock_data_provider.dart - SOLO CALIDAD Y ALERTAS
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class MockDataProvider {
  // Listas para almacenar SOLO datos mock de calidad y alertas
  List<dynamic> qualityReadings = [];
  List<dynamic> alerts = [];

  // El resto de datos vienen del backend real
  List<dynamic> tanks = [];
  List<dynamic> users = [];
  List<Map<String, dynamic>> historicalData = [];

  // Método para inicializar los datos
  Future<void> init() async {
    try {
      await _loadRealDataFromAssets(); // Cargar datos reales que ya existen
      _generateMockQualityAndAlerts(); // Solo mockear calidad y alertas
      print('✅ MockDataProvider inicializado: Backend real + Calidad/Alertas mockeadas');
    } catch (e) {
      print('❌ Error al inicializar MockDataProvider: $e');
      _generateMockQualityAndAlerts(); // Generar solo calidad y alertas de respaldo
    }
  }

  Future<void> _loadRealDataFromAssets() async {
    try {
      // SOLO cargar datos que realmente necesitamos mockear
      // Los tanques y usuarios vienen del backend, no de archivos JSON

      // Cargar datos de calidad de agua (MOCK)
      try {
        final qualityJson = await rootBundle.loadString('assets/data/water_quality.json');
        final qualityData = json.decode(qualityJson);
        qualityReadings = qualityData['qualityReadings'] ?? [];
        print('✅ Datos de calidad cargados desde JSON');
      } catch (e) {
        print('⚠️ No se pudo cargar water_quality.json: $e');
        qualityReadings = [];
      }

      // Cargar datos de alertas (MOCK)
      try {
        final alertsJson = await rootBundle.loadString('assets/data/alerts.json');
        final alertsData = json.decode(alertsJson);
        alerts = alertsData['alerts'] ?? [];
        print('✅ Datos de alertas cargados desde JSON');
      } catch (e) {
        print('⚠️ No se pudo cargar alerts.json: $e');
        alerts = [];
      }

      // NO cargar tanques, usuarios ni histórico - vienen del backend
      tanks = []; // Vacío porque viene del backend
      users = []; // Vacío porque viene del backend
      historicalData = []; // Vacío porque viene del backend

    } catch (e) {
      print('⚠️ Error general al cargar archivos JSON: $e');
    }
  }

  void _generateMockQualityAndAlerts() {
    final random = Random();

    // --- SOLO GENERAR DATOS DE CALIDAD DE AGUA MOCKEADOS ---
    _generateWaterQualityData();

    // --- SOLO GENERAR ALERTAS MOCKEADAS ---
    _generateAlertsData();

    print('🧪 Datos de calidad de agua y alertas generados (mockeados)');
    print('🔗 Tanques y usuarios usarán datos del backend real');
  }

  void _generateWaterQualityData() {
    final random = Random();
    final now = DateTime.now();

    // Generar datos de calidad para tanques (IDs fijos que deberían existir en el backend)
    final tankIds = ['1', '2', '3', '4', '5'];

    qualityReadings = tankIds.map((tankId) {
      // Generar valores realistas de pH (6.0 - 8.5)
      final ph = 6.0 + random.nextDouble() * 2.5;

      // Generar valores realistas de temperatura (15-30°C)
      final temperature = 15.0 + random.nextDouble() * 15.0;

      // Generar turbidez (0-10 NTU)
      final turbidity = random.nextDouble() * 10;

      // Generar conductividad (100-800 µS/cm)
      final conductivity = 100 + random.nextDouble() * 700;

      // Determinar estado basado en valores
      String status = 'good';
      if (ph < 6.5 || ph > 8.5 || temperature < 15 || temperature > 25 || turbidity > 5) {
        status = 'poor';
      } else if (ph < 7.0 || ph > 8.0 || temperature < 18 || temperature > 22 || turbidity > 2) {
        status = 'acceptable';
      }

      return {
        'tankId': tankId,
        'timestamp': now.subtract(Duration(minutes: random.nextInt(30))).toIso8601String(),
        'ph': double.parse(ph.toStringAsFixed(2)),
        'temperature': double.parse(temperature.toStringAsFixed(1)),
        'turbidity': double.parse(turbidity.toStringAsFixed(2)),
        'conductivity': double.parse(conductivity.toStringAsFixed(0)),
        'status': status,
        'chlorine': double.parse((0.1 + random.nextDouble() * 0.4).toStringAsFixed(2)), // mg/L
        'oxygen': double.parse((6.0 + random.nextDouble() * 3.0).toStringAsFixed(1)), // mg/L
      };
    }).toList();
  }

  void _generateAlertsData() {
    final random = Random();
    final now = DateTime.now();

    alerts.clear();

    // Generar alertas realistas
    final alertsToGenerate = [
      {
        'tankId': '1',
        'type': 'low_water_level',
        'severity': 'warning',
        'message': 'El nivel del agua ha bajado al 25%. Se recomienda revisar el consumo.',
        'hoursAgo': 4,
        'resolved': false,
        'pumpActivated': true,
      },
      {
        'tankId': '2',
        'type': 'quality_issue',
        'severity': 'warning',
        'message': 'El pH del agua está ligeramente fuera del rango óptimo. Monitorear de cerca.',
        'hoursAgo': 6,
        'resolved': false,
        'pumpActivated': false,
      },
      {
        'tankId': '4',
        'type': 'quality_issue',
        'severity': 'error',
        'message': 'CRÍTICO: Calidad del agua muy deficiente. Requiere atención inmediata.',
        'hoursAgo': 2,
        'resolved': false,
        'pumpActivated': false,
      },
      {
        'tankId': '3',
        'type': 'high_temperature',
        'severity': 'warning',
        'message': 'La temperatura del agua está elevada. Monitorear para evitar proliferación bacteriana.',
        'hoursAgo': 8,
        'resolved': false,
        'pumpActivated': false,
      },
      {
        'tankId': '1',
        'type': 'sensor_disconnected',
        'severity': 'warning',
        'message': 'El sensor de temperatura no ha enviado datos en los últimos 30 minutos.',
        'hoursAgo': 24,
        'resolved': true,
        'pumpActivated': false,
      },
      {
        'tankId': '5',
        'type': 'low_water_level',
        'severity': 'error',
        'message': 'CRÍTICO: Nivel de agua extremadamente bajo. Bomba activada automáticamente.',
        'hoursAgo': 48,
        'resolved': true,
        'pumpActivated': true,
      },
      {
        'tankId': '2',
        'type': 'ph_critical',
        'severity': 'info',
        'message': 'El pH del agua ha sido normalizado tras el mantenimiento.',
        'hoursAgo': 72,
        'resolved': true,
        'pumpActivated': false,
      },
    ];

    for (int i = 0; i < alertsToGenerate.length; i++) {
      final alertData = alertsToGenerate[i];
      alerts.add({
        'id': '${i + 1}',
        'tankId': alertData['tankId'],
        'type': alertData['type'],
        'severity': alertData['severity'],
        'message': alertData['message'],
        'timestamp': now.subtract(Duration(hours: alertData['hoursAgo'] as int)).toIso8601String(),
        'resolved': alertData['resolved'],
        'pumpActivated': alertData['pumpActivated'],
      });
    }
  }

  // --- MÉTODOS PARA DATOS REALES (BACKEND) ---
  Future<List<dynamic>> getTanks() async {
    // Este método no se usa porque los tanques vienen del backend
    await Future.delayed(const Duration(milliseconds: 300));
    return tanks; // Solo como fallback
  }

  Future<dynamic> getTankById(String id) async {
    // Este método no se usa porque los tanques vienen del backend
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return tanks.firstWhere((tank) => tank['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>> getUsers() async {
    // Este método no se usa porque los usuarios vienen del backend
    await Future.delayed(const Duration(milliseconds: 300));
    return users; // Solo como fallback
  }

  Future<dynamic> getUserById(String id) async {
    // Este método no se usa porque los usuarios vienen del backend
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return users.firstWhere((user) => user['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> authenticateUser(String email, String password) async {
    // Este método no se usa porque la autenticación viene del backend
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return users.firstWhere((user) => user['email'] == email);
    } catch (e) {
      return null;
    }
  }

  // --- MÉTODOS PARA DATOS MOCKEADOS (CALIDAD Y ALERTAS) ---

  Future<List<dynamic>> getWaterQualityReadings() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return qualityReadings;
  }

  Future<dynamic> getWaterQualityForTank(String tankId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return qualityReadings.firstWhere((reading) => reading['tankId'] == tankId);
    } catch (e) {
      // Generar datos en tiempo real si no existen
      return _generateRealTimeQuality(tankId);
    }
  }

  dynamic _generateRealTimeQuality(String tankId) {
    final random = Random();
    final now = DateTime.now();

    final ph = 6.5 + random.nextDouble() * 1.5;
    final temperature = 18.0 + random.nextDouble() * 8.0;
    final turbidity = random.nextDouble() * 3.0;

    String status = 'good';
    if (ph < 6.8 || ph > 7.8 || temperature < 20 || temperature > 24 || turbidity > 1.5) {
      status = 'acceptable';
    }
    if (ph < 6.5 || ph > 8.0 || temperature < 18 || temperature > 26 || turbidity > 2.5) {
      status = 'poor';
    }

    return {
      'tankId': tankId,
      'timestamp': now.toIso8601String(),
      'ph': double.parse(ph.toStringAsFixed(2)),
      'temperature': double.parse(temperature.toStringAsFixed(1)),
      'turbidity': double.parse(turbidity.toStringAsFixed(2)),
      'conductivity': double.parse((200 + random.nextDouble() * 400).toStringAsFixed(0)),
      'status': status,
      'chlorine': double.parse((0.1 + random.nextDouble() * 0.4).toStringAsFixed(2)),
      'oxygen': double.parse((6.0 + random.nextDouble() * 3.0).toStringAsFixed(1)),
    };
  }

  Future<List<dynamic>> getAlerts({bool? resolved}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (resolved != null) {
      return alerts.where((alert) => alert['resolved'] == resolved).toList();
    }
    return alerts;
  }

  Future<void> markAlertAsResolved(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = alerts.indexWhere((alert) => alert['id'] == id);
    if (index != -1) {
      alerts[index]['resolved'] = true;
      print('✅ MockDataProvider: Alerta $id marcada como resuelta');
    }
  }

  // --- MÉTODOS DE TANQUES (QUE DEBERÍAN USAR EL BACKEND) ---

  Future<void> togglePump(String id, bool active) async {
    // Este método debería usar el backend real, pero como fallback:
    await Future.delayed(const Duration(milliseconds: 500));
    final index = tanks.indexWhere((tank) => tank['id'] == id);
    if (index != -1) {
      tanks[index]['pumpActive'] = active;
      tanks[index]['lastUpdated'] = DateTime.now().toIso8601String();
      print('🔄 MockDataProvider (Fallback): Bomba del tanque $id ${active ? "activada" : "desactivada"}');
    }
  }

  Future<void> updateTankLevel(String id, double newLevel) async {
    // Este método debería usar el backend real, pero como fallback:
    await Future.delayed(const Duration(milliseconds: 100));
    final index = tanks.indexWhere((tank) => tank['id'] == id);
    if (index != -1) {
      tanks[index]['currentLevel'] = newLevel;
      tanks[index]['lastUpdated'] = DateTime.now().toIso8601String();
    }
  }

  // --- DATOS HISTÓRICOS (PUEDEN SER REALES O MOCKEADOS SEGÚN BACKEND) ---

  Future<List<Map<String, dynamic>>> getHistoricalData(String tankId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final tankData = historicalData.firstWhere(
              (item) => item['tankId'] == tankId,
          orElse: () => {'readings': []}
      );
      return List<Map<String, dynamic>>.from(tankData['readings'] ?? []);
    } catch (e) {
      // Si no hay datos históricos, generar algunos básicos para la demo
      return _generateBasicHistoricalData(tankId);
    }
  }

  List<Map<String, dynamic>> _generateBasicHistoricalData(String tankId) {
    final random = Random();
    final now = DateTime.now();
    final readings = <Map<String, dynamic>>[];

    // Generar 7 días de datos básicos
    for (int day = 7; day >= 0; day--) {
      final timestamp = now.subtract(Duration(days: day));
      final baseLevel = 500 + random.nextDouble() * 300; // 500-800L

      readings.add({
        'timestamp': timestamp.toIso8601String(),
        'level': double.parse(baseLevel.toStringAsFixed(1)),
        'percentage': double.parse(((baseLevel / 1000) * 100).toStringAsFixed(1)),
        'pumpActive': random.nextBool(),
        'ph': double.parse((6.5 + random.nextDouble() * 1.5).toStringAsFixed(2)),
        'temperature': double.parse((18.0 + random.nextDouble() * 8.0).toStringAsFixed(1)),
      });
    }

    return readings;
  }

  // --- MÉTODO PARA AGREGAR NUEVAS ALERTAS (MOCKEAR) ---

  Future<void> addNewAlert(String tankId, String type, String severity, String message) async {
    final newAlert = {
      'id': '${alerts.length + 1}',
      'tankId': tankId,
      'type': type,
      'severity': severity,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'resolved': false,
      'pumpActivated': false,
    };
    alerts.add(newAlert);
    print('🚨 Nueva alerta generada para tanque $tankId: $message');
  }
}