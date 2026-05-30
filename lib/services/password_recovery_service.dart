import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PasswordRecoveryService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8383/auth';
    return 'http://10.0.2.2:8383/auth';
  }

  static Future<Map<String, dynamic>> sendRecoveryCode({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recovery/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 30),
          onTimeout: () => throw TimeoutException('Timeout'));

      if (response.body.isEmpty) {
        return {'success': false, 'error': 'Sin respuesta del servidor'};
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'message': responseData['message']};
      } else {
        return {'success': false, 'error': responseData['error'] ?? 'Error al enviar código'};
      }
    } on TimeoutException {
      return {'success': false, 'error': 'El servidor tardó demasiado'};
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String codigo,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recovery/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'codigo': codigo,
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 30),
          onTimeout: () => throw TimeoutException('Timeout'));

      if (response.body.isEmpty) {
        return {'success': false, 'error': 'Sin respuesta del servidor'};
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {'success': true, 'message': responseData['message']};
      } else if (response.statusCode == 400) {
        return {'success': false, 'error': responseData['error'] ?? 'Código incorrecto', 'intentosRestantes': responseData['intentosRestantes']};
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': responseData['error'] ?? 'Código expirado'};
      } else if (response.statusCode == 429) {
        return {'success': false, 'error': responseData['error'] ?? 'Demasiados intentos'};
      } else {
        return {'success': false, 'error': responseData['error'] ?? 'Error al restablecer'};
      }
    } on TimeoutException {
      return {'success': false, 'error': 'El servidor tardó demasiado'};
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