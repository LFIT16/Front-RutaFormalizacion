import 'package:http/http.dart' as http;
import 'dart:convert';
// auth_service.dart
import 'package:flutter/foundation.dart';

import 'package:login_signup/services/token_service.dart';

class AuthService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8383/auth';        // web
    }
    return 'http://10.0.2.2:8383/auth';           // emulador Android

  }

  // Registrar usuario
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    String? address,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'name': name,
              'lastName': lastName,
              'email': email,
              'phone': phone,
              'password': password,
              'confirmPassword': confirmPassword,
              'address': address ?? '',
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw TimeoutException('Timeout en la conexión al servidor'),
          );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Usuario registrado exitosamente',
          'email': email,
        };
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'error': responseData['error'] ?? 'El email ya está registrado',
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Datos inválidos',
        };
      } else {
        return {
          'success': false,
          'error': 'Error en el servidor: ${response.statusCode}',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'error': 'Error de conexión: El servidor tardó demasiado en responder',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // Login usuario
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw TimeoutException('Timeout en la conexión al servidor'),
          );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Se envió un código 2FA a tu correo',
          'email': email,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Email o contraseña incorrectos',
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Cuenta no activada',
        };
      } else {
        return {
          'success': false,
          'error': 'Error en el servidor: ${response.statusCode}',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'error': 'Error de conexión: El servidor tardó demasiado en responder',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // Verificar código 2FA
  static Future<Map<String, dynamic>> verifyCode({
    required String email,
    required String codigo,
    required String purpose, // "REGISTRO" o "LOGIN"
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/2fa/verify'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'codigo': codigo,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw TimeoutException('Timeout en la conexión al servidor'),
          );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Código verificado exitosamente',
          'token': responseData['token'],
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Código incorrecto',
          'intentosRestantes': responseData['intentosRestantes'] ?? 0,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': responseData['error'] ?? 'El código ha expirado',
        };
      } else if (response.statusCode == 429) {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Demasiados intentos fallidos',
          'intentosRestantes': 0,
        };
      } else {
        return {
          'success': false,
          'error': 'Error en el servidor: ${response.statusCode}',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'error': 'Error de conexión: El servidor tardó demasiado en responder',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  // Reenviar código 2FA
  static Future<Map<String, dynamic>> resendCode({
    required String email,
    required String purpose,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/2fa/send'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'proposito': purpose,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw TimeoutException('Timeout en la conexión al servidor'),
          );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Código reenviado',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': responseData['error'] ?? 'Usuario no encontrado',
        };
      } else {
        return {
          'success': false,
          'error': 'Error en el servidor: ${response.statusCode}',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'error': 'Error de conexión: El servidor tardó demasiado en responder',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> getMe() async {
    try {
      final token = await TokenService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30),
          onTimeout: () => throw TimeoutException('Timeout'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'user': data['user']};
      }
      return {'success': false};
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> updateUser({
    required String userId,
    required String name,
    required String lastName,
    required String phone,
    String? address,
  }) async {
    try {
      final token = await TokenService.getToken();
      final response = await http
          .put(
            Uri.parse('http://localhost:8383/api/users/$userId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'name': name,
              'lastName': lastName,
              'phone': phone,
              'address': address ?? '',
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Timeout'),
          );

      if (response.statusCode == 200) {
        return {'success': true, 'user': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Error al actualizar: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: ${e.toString()}'};
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
