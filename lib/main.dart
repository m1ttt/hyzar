import 'package:hyzar/firebase_options.dart';
import 'package:hyzar/pantallas/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            routes: {
              '/login': (context) => const LoginScreen(),
            },
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch:
                    Colors.blue, // Cambia a tu color principal deseado aquí
              ).copyWith(
                secondary:
                    Colors.blue, // Cambia a tu color secundario deseado aquí
                surface: Colors.white, // Cambia el color de la superficie aquí
                background: Colors.white, // Cambia el color de fondo aquí
              ),
              brightness: Brightness.light, // Set light theme
              scaffoldBackgroundColor:
                  Colors.white, // Set background color to white
              useMaterial3: true,
            ),
            home: const LoginScreen(),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error al inicializar Firebase'));
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
