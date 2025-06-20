// lib/data/services/http_service.dart - CORREGIDO PARA EXCLUIR TOKEN EN AUTH
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waterguard/core/config/app_config.dart';
import 'dart:io';

class HttpService {
  late Dio _dio;

  HttpService() {
    _dio = Dio(BaseOptions(
      baseUrl: EnvironmentConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Configurar manejo de certificados SSL para desarrollo
    (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    // ✅ INTERCEPTOR CORREGIDO - NO ENVIAR TOKEN EN ENDPOINTS DE AUTH
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // ✅ VERIFICAR SI ES UN ENDPOINT DE AUTENTICACIÓN
        final isAuthEndpoint = options.path.contains('/auth/login') ||
            options.path.contains('/auth/register');

        if (!isAuthEndpoint) {
          // Solo agregar token si NO es un endpoint de autenticación
          final token = await _getStoredToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print('🎫 Token agregado a request: ${options.path}');
          } else {
            print('⚠️ No hay token disponible para: ${options.path}');
          }
        } else {
          print('🔓 Endpoint de auth detectado, NO enviando token: ${options.path}');
          // Remover cualquier header de Authorization que pueda existir
          options.headers.remove('Authorization');
        }

        print('🚀 ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) async {
        print('❌ Error ${error.response?.statusCode} ${error.requestOptions.path}');
        print('Error details: ${error.message}');

        // Si recibe 401, eliminar token y redirigir al login
        if (error.response?.statusCode == 401) {
          await _removeStoredToken();
          print('🗑️ Token eliminado por 401');
        }
        handler.next(error);
      },
    ));

    // Interceptor para logging en desarrollo
    if (EnvironmentConfig.enableLogging) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        logPrint: (obj) => print('🌐 $obj'),
      ));
    }
  }

  // MÉTODOS PRIVADOS PARA MANEJO DE TOKEN
  Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.tokenKey);
  }

  Future<void> _removeStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.tokenKey);
    await prefs.remove(AppConfig.userIdKey); // También remover user ID
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.tokenKey, token);
    print('💾 Token guardado correctamente');
  }

  // ✅ MÉTODO PARA LIMPIAR TODOS LOS DATOS DE SESIÓN
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.tokenKey);
    await prefs.remove(AppConfig.userIdKey);
    print('🧹 Sesión limpiada completamente');
  }

  // GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Timeout de conexión. Verifica tu conexión a internet.';
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 401) {
          return 'Credenciales inválidas o sesión expirada';
        } else if (error.response?.statusCode == 403) {
          return 'Acceso denegado. Verifica tus permisos.';
        } else if (error.response?.statusCode == 404) {
          return 'Recurso no encontrado';
        } else if (error.response?.statusCode == 500) {
          return 'Error interno del servidor';
        }
        return 'Error en la respuesta del servidor: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Petición cancelada';
      default:
        return 'Error de conexión. Verifica tu conexión a internet.';
    }
  }

  // Método para probar la conexión al backend
  Future<bool> testConnection() async {
    try {
      // ✅ USAR UN ENDPOINT PÚBLICO PARA PROBAR CONEXIÓN
      final response = await _dio.get('/auth/users');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Test de conexión falló: $e');
      return false;
    }
  }
}