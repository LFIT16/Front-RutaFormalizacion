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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff2E7D32),
          primary: const Color(0xff2E7D32),
          secondary: const Color(0xff1565C0),
          tertiary: const Color(0xff6A1B9A),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MainPage(),
        // Esta ruta exacta ya no es suficiente porque Flutter recibe
        // "/auth/google/callback?token=XXX" como nombre de ruta completo.
        // El onGenerateRoute de abajo se encarga de eso.
      },
      // onGenerateRoute intercepta rutas que 'routes' no matchea exactamente.
      // Cuando el backend redirige a /#/auth/google/callback?token=XXX,
      // Flutter pasa el path+query completo como settings.name.
      // Aquí extraemos solo el path para identificar la ruta correcta.
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';
        // Extraer solo el path (antes del '?')
        final path = name.contains('?') ? name.substring(0, name.indexOf('?')) : name;

        if (path == '/auth/google/callback') {
          return MaterialPageRoute(
            builder: (_) => const GoogleCallbackPage(),
            settings: settings, // importante: pasar settings para que Uri.base funcione
          );
        }

        // Rutas conocidas como fallback
        if (path == '/login') {
          return MaterialPageRoute(builder: (_) => const LoginPage());
        }
        if (path == '/home') {
          return MaterialPageRoute(builder: (_) => const MainPage());
        }

        // Fallback general
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      },
    );
  }
}