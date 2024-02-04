import 'package:hyzar/utilidades/firebase_options.dart';
import 'package:hyzar/auth/login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hyzar/main/widgets/app_theme.dart';
import 'package:hyzar/utilidades/backend/user_notifier.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserNotifier('', '', '', '', null),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError(String error) {
    return const Center(
      child: Text('Error interno'),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // Si los colores dinámicos están disponibles, úsalos; si no, usa los esquemas de color predeterminados
        ColorScheme lightScheme = lightDynamic ?? const ColorScheme.light();
        ColorScheme darkScheme = darkDynamic ?? const ColorScheme.dark();

        return MaterialApp(
          routes: {
            '/login': (context) => const LoginScreen(),
          },
          debugShowCheckedModeBanner: false,
          theme: buildThemeData(lightScheme), // Tema claro
          darkTheme: buildThemeData(darkScheme), // Tema oscuro
          home: const LoginScreen(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return _buildSuccess(context);
        }

        return _buildLoading();
      },
    );
  }
}
