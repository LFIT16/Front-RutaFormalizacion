import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class SecurityService {
  static String get baseUrl => dotenv.env['API_URL']!;

  static Future<String> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/public/security/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('STATUS CODE LOGIN: ${response.statusCode}');
    print('BODY LOGIN: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('Correo o contraseña incorrectos');
    }
  }

  static Future<String> loginWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Inicio de sesión cancelado');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final User? user = userCredential.user;

    if (user == null || user.email == null) {
      throw Exception('No se pudo obtener el usuario de Google');
    }

    final url = Uri.parse('$baseUrl/public/security/google-login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': user.email,
        'name': user.displayName ?? user.email,
        'googleId': user.uid,
        'photoUrl': user.photoURL,
      }),
    );

    print('URL GOOGLE BACKEND: $url');
    print('EMAIL GOOGLE: ${user.email}');
    print('NAME GOOGLE: ${user.displayName}');
    print('UID GOOGLE: ${user.uid}');
    print('PHOTO GOOGLE: ${user.photoURL}');
    print('STATUS CODE GOOGLE BACKEND: ${response.statusCode}');
    print('BODY GOOGLE BACKEND: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('No se pudo iniciar sesión con Google');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/public/security/register');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    print('STATUS CODE REGISTER: ${response.statusCode}');
    print('BODY REGISTER: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Error al registrar usuario');
    }
  }
}