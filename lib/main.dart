import 'package:hyzar/utilidades/firebase_options.dart';
import 'package:hyzar/auth/login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hyzar/main/widgets/app_theme.dart';
import 'package:hyzar/utilidades/backend/user_notifier.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserNotifier('', '', ''),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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

  Widget _buildSuccess() {
    return MaterialApp(
      routes: {
        '/login': (context) => const LoginScreen(),
      },
      debugShowCheckedModeBanner: false,
      theme: buildThemeData(),
      home: const LoginScreen(),
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
          return _buildSuccess();
        }

        return _buildLoading();
      },
    );
  }
}
