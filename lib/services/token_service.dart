import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static const String _tokenKey = 'jwt_token';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';

  // Guardar token
  static Future<bool> saveToken(String token) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_tokenKey, token);
    } catch (e) {
      debugPrint('Error saving token: $e');
      return false;
    }
  }

  // Obtener token
  static Future<String?> getToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('Error getting token: $e');
      return null;
    }
  }

  // Guardar información del usuario
  static Future<bool> saveUserInfo({
    required String email,
    required String name,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userEmailKey, email);
      await prefs.setString(_userNameKey, name);
      return true;
    } catch (e) {
      debugPrint('Error saving user info: $e');
      return false;
    }
  }

  // Obtener email del usuario
  static Future<String?> getUserEmail() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userEmailKey);
    } catch (e) {
      debugPrint('Error getting user email: $e');
      return null;
    }
  }

  // Obtener nombre del usuario
  static Future<String?> getUserName() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (e) {
      debugPrint('Error getting user name: $e');
      return null;
    }
  }

  // Eliminar token (logout)
  static Future<bool> deleteToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_tokenKey);
    } catch (e) {
      debugPrint('Error deleting token: $e');
      return false;
    }
  }

  // Limpiar toda la información del usuario
  static Future<bool> clearUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userNameKey);
      return true;
    } catch (e) {
      debugPrint('Error clearing user data: $e');
      return false;
    }
  }

  // Verificar si hay sesión activa
  static Future<bool> isLoggedIn() async {
    try {
      final String? token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if logged in: $e');
      return false;
    }
  }
}
