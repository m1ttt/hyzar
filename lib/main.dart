import 'package:hyzar/firebase_options.dart';
import 'package:hyzar/pantallas/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
// Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
            secondary: Colors.blue, // Cambia a tu color secundario deseado aquí
            surface: Colors.white, // Cambia el color de la superficie aquí       
            background: Colors.white, // Cambia el color de fondo aquí
          ),
          brightness: Brightness.light, // Set light theme
          scaffoldBackgroundColor:
              Colors.white, // Set background color to white
          useMaterial3: true,
        ),
        // darkTheme: ThemeData(
        //   primarySwatch: Colors.blue,

        //   brightness: Brightness.dark, // Set dark theme
        //   scaffoldBackgroundColor:
        //       Colors.black, // Set background color to black everywhere
        //   useMaterial3: true,
        // ),
        home: const LoginScreen());
  }
}
