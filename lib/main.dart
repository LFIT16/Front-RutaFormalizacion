import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:login_signup/components/home_page.dart';
import 'package:login_signup/components/login_page.dart';
import 'package:login_signup/services/token_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Initialize Firebase asynchronously
  Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  // Verificar si el usuario está logueado
  Future<bool> _isLoggedIn() async {
    return await TokenService.isLoggedIn();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize Firebase and wait for completion
      future: initializeFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Once Firebase is initialized, return MaterialApp with routes
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Ruta de Formalización',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            home: FutureBuilder<bool>(
              future: _isLoggedIn(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // Si el usuario está logueado, ir a home; si no, ir a login
                  return snapshot.data == true ? const HomePage() : const LoginPage();
                } else {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
            routes: {
              '/login': (context) => const LoginPage(),
              '/home': (context) => const HomePage(),
            },
          );
        } else {
          // Show loading indicator while Firebase is initializing
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
      },
    );
  }
}
