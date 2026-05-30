import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
//port 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  // Backend API base URL 
  static late final String baseUrl;

  static void init() {
  final apiUrl = 'http://localhost:8383';
  baseUrl = '$apiUrl/auth';
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
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'password': password,
          'confirmPassword': confirmPassword,
          'address': address ?? '',
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Timeout en la conexión al servidor'),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Usuario registrado exitosamente',
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
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Timeout en la conexión al servidor'),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Se envió un código 2FA a tu correo',
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
      final response = await http.post(
        Uri.parse('$baseUrl/2fa/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'codigo': codigo,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Timeout en la conexión al servidor'),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Código verificado exitosamente',
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
      final response = await http.post(
        Uri.parse('$baseUrl/2fa/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'proposito': purpose,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Timeout en la conexión al servidor'),
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

  // Login con Google (dentro de la clase AuthService)
  static Future<Map<String, dynamic>> loginWithGoogle() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile', 'openid'],
      clientId: '408294359663-pihvunt5ou1h5nkul77du76vvlsq66d1.apps.googleusercontent.com',
    );

    await googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return {'success': false, 'error': 'Login cancelado por el usuario'};
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // En web se usa el accessToken, no el idToken
    final String? accessToken = googleAuth.accessToken;

    if (accessToken == null) {
      return {'success': false, 'error': 'No se pudo obtener el token de Google'};
    }

    // Enviar el accessToken al backend
    final response = await http.post(
      Uri.parse('$baseUrl/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'accessToken': accessToken}),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw TimeoutException('Timeout en la conexión al servidor'),
    );

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return {
        'success': true,
        'token': responseData['token'],
        'email': responseData['email'] ?? googleUser.email,
        'name': responseData['name'] ?? googleUser.displayName ?? '',
      };
    } else {
      return {
        'success': false,
        'error': responseData['error'] ?? 'Error al autenticar con Google',
      };
    }
  } on TimeoutException {
    return {'success': false, 'error': 'El servidor tardó demasiado en responder'};
  } catch (e) {
    return {'success': false, 'error': 'Error: ${e.toString()}'};
  }
}
}