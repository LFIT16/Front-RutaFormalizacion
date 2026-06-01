import 'package:flutter/material.dart';
import 'package:login_signup/components/verify_code_page.dart';
import 'package:login_signup/services/auth_service.dart';
import 'package:login_signup/services/token_service.dart';

class GoogleCallbackPage extends StatefulWidget {
  const GoogleCallbackPage({Key? key}) : super(key: key);

  @override
  State<GoogleCallbackPage> createState() => _GoogleCallbackPageState();
}

class _GoogleCallbackPageState extends State<GoogleCallbackPage> {
  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    final uri = Uri.base;
    final token = uri.queryParameters['token'];
    final require2fa = uri.queryParameters['require2fa'];
    final email = uri.queryParameters['email'];

    if (token != null) {
      // Guardar token
      await TokenService.saveToken(token);

      // Obtener datos del usuario
      final meResult = await AuthService.getMe();
      if (meResult['success'] && meResult['user'] != null) {
        final user = meResult['user'];
        await TokenService.saveUserId(user['id'] ?? '');
        await TokenService.saveUserInfo(
          email: user['email'] ?? '',
          name: user['name'] ?? '',
        );
      }

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } else if (require2fa == 'true' && email != null) {
      // Redirigir a verificación 2FA
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => VerifyCodePage(email: email, purpose: 'LOGIN'),
          ),
        );
      }
    } else {
      // Error
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xff2E7D32)),
            SizedBox(height: 16),
            Text('Verificando con Google...'),
          ],
        ),
      ),
    );
  }
}