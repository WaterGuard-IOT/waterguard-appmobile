// lib/data/services/tank_service.dart
import 'package:waterguard/data/services/http_service.dart';

class TankService {
  final HttpService _httpService;

  TankService(this._httpService);

  /// Obtiene todos los tanques asociados a un ID de usuario.
  Future<List<dynamic>> getTanksByUser(int usuarioId) async {
    final response = await _httpService.get('/usuario/$usuarioId/tanques');
    return response.data as List<dynamic>;
  }

  /// Obtiene los detalles de un tanque específico por su ID.
  Future<Map<String, dynamic>> getTankById(int tanqueId) async {
    final response = await _httpService.get('/tanque/$tanqueId');
    return response.data as Map<String, dynamic>;
  }

  /// Crea un nuevo tanque con datos personalizados.
  Future<Map<String, dynamic>> createTank(Map<String, dynamic> tankData) async {
    print('📦 Enviando datos para crear tanque: $tankData');
    final response = await _httpService.post('/tanque', data: tankData);
    return response.data as Map<String, dynamic>;
  }

  /// **(CLAVE)** Actualiza un tanque existente usando el método PUT.
  /// Se comunica con el endpoint PUT /api/tanque/{id}
  Future<Map<String, dynamic>> updateTank(
      int tankId, Map<String, dynamic> tankData) async {
    print('🔄 Enviando actualización PUT para tanque $tankId: $tankData');
    // Utiliza el método put del httpService que corresponde a PUT
    final response = await _httpService.put('/tanque/$tankId', data: tankData);
    return response.data as Map<String, dynamic>;
  }
}
