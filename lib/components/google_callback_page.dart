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

    // Con Flutter Web hash router, la URL llega como:
    //   http://localhost:7000/#/auth/google/callback?token=XXX
    // uri.fragment = "/auth/google/callback?token=XXX"
    // uri.queryParameters = {} (vacío, los params están dentro del fragment)
    //

    print('=== GOOGLE CALLBACK ===');
    print('URI completa: $uri');
    print('Fragment: ${uri.fragment}');
    print('Query params: ${uri.queryParameters}');
    // Extraemos los params del fragment:
    String? token;
    String? require2fa;
    String? email;

    final fragment = uri.fragment; // "/auth/google/callback?token=XXX"
    final questionMark = fragment.indexOf('?');

    if (questionMark != -1) {
      // Hay query params dentro del fragment
      final queryString = fragment.substring(questionMark + 1);
      final params = Uri.splitQueryString(queryString);
      token = params['token'];
      require2fa = params['require2fa'];
      email = params['email'];
    } else {
      // Fallback: intentar queryParameters normales (sin hash router)
      token = uri.queryParameters['token'];
      require2fa = uri.queryParameters['require2fa'];
      email = uri.queryParameters['email'];
    }

    if (token != null) {
      await TokenService.saveToken(token);

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
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => VerifyCodePage(email: email!, purpose: 'LOGIN'),
          ),
        );
      }
    } else {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
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