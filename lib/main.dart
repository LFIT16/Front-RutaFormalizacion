import 'package:flutter/material.dart';
import 'package:login_signup/components/google_callback_page.dart';
import 'package:login_signup/components/login_page.dart';
import 'package:login_signup/components/main_page.dart';
import 'package:login_signup/components/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ruta de Formalización',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2E7D32)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MainPage(),
        '/auth/google/callback': (context) => const GoogleCallbackPage(),
      },
    );
  }
}