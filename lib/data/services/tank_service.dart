import 'package:waterguard/data/services/http_service.dart';

class TankService {
  final HttpService _httpService;

  TankService(this._httpService);

  Future<Map<String, dynamic>> createTank(int usuarioId) async {
    final response = await _httpService.post('/usuario/$usuarioId/tanques');
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getTanksByUser(int usuarioId) async {
    final response = await _httpService.get('/usuario/$usuarioId/tanques');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getTankById(int tanqueId) async {
    final response = await _httpService.get('/tanque/$tanqueId');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> registerWaterQuality(
      int tanqueId, {
        required double ph,
        required double turbidez,
        required double conductividad,
        required double temperatura,
      }) async {
    final response = await _httpService.post('/tanque/$tanqueId/calidad', data: {
      'ph': ph,
      'turbidez': turbidez,
      'conductividad': conductividad,
      'temperatura': temperatura,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> registerWaterLevel(
      int tanqueId, {
        required double porcentaje,
      }) async {
    final response = await _httpService.post('/tanque/$tanqueId/nivel', data: {
      'porcentaje': porcentaje,
    });
    return response.data as Map<String, dynamic>;
  }
}