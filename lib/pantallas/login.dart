import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hyzar/pantallas/principal.dart';
import 'package:hyzar/utilidades/auth.dart';
import 'package:flutter/cupertino.dart'; // Importa CupertinoAlertDialog para iOS
import 'package:hyzar/presentation/widgets/email_field.dart';
import 'package:hyzar/presentation/widgets/get_started_button.dart';
import 'package:hyzar/presentation/widgets/password_field.dart';
import 'registro.dart';

void main() {
  runApp(const Login());
}

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const LoginScreen(),
    );
  }
}

class SlideFromRightPageRoute<T> extends PageRouteBuilder<T> {
  final Widget enterPage;

  SlideFromRightPageRoute({required this.enterPage})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => enterPage,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Aqui son las variables de inicio de sesión
  final Auth _auth = Auth();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  double _elementsOpacity = 1;
  StreamSubscription<User?>? _authStateChangesSubscription;
  bool loadingBallAppear = false;

  @override
  void initState() {
    _authStateChangesSubscription = _auth.authStateChanges.listen((User? user) {
      if (user != null) {
        // El usuario está autenticado, redirigir a la pantalla principal
        Navigator.push(
          context,
          SlideFromRightPageRoute(enterPage: PrincipalUser()),
        );
      }
    });
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  void _showErrorDialog(String message) {
    if (Theme.of(context).platform == TargetPlatform.android) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    // Cancelar la suscripción al listener al salir de la pantalla
    _authStateChangesSubscription?.cancel();
    super.dispose();
  }

  void _registrar() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    try {
      await _auth.registrarEmailPass(email, password);
      print("Hola si me registre");
      // Resto del código después del inicio de sesión exitoso
    } catch (e) {
      String errorMessage = "Hubo un error + $e";
      _showErrorDialog(errorMessage);
    }
    // Aquí puedes agregar lógica adicional después del registro exitoso
  }

  void _iniciarSesion() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    Auth auth = Auth();
    User? user = await auth.iniciarSesionEmailPass(email, password);

    if (user != null) {
      // El usuario inició sesión correctamente, puedes realizar acciones adicionales aquí.
      print("Hola, ${user.email}! Inicio de sesión exitoso.");
      // Verificar el tipo de usuario (usuario o admin)
      String userID = user.uid;
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child("usuarios").child(userID);
      DataSnapshot snapshot = (await userRef.once()).snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic>? userData =
            snapshot.value as Map<dynamic, dynamic>?;
        if (userData != null && userData["tipo"] == "usuario") {
          // El usuario es un usuario normal
          print("Es un usuario");
          Navigator.push(
              context, SlideFromRightPageRoute(enterPage: PrincipalUser()));
          // Aquí puedes realizar acciones específicas para los usuarios normales
        } else if (userData != null && userData["tipo"] == "admin") {
          // El usuario es un administrador
          print("Es un administrador");
          // Aquí puedes realizar acciones específicas para los administradores
        } else {
          // El usuario no tiene el campo "tipo" definido o no es ni usuario ni admin
          print("El tipo de usuario no está definido correctamente.");
        }
      }
    } else {
      // Hubo un error al iniciar sesión, manejarlo adecuadamente.
      String errorMessage =
          "Ocurrió un error al iniciar sesión. Verifica tus credenciales.";
      _showErrorDialog(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: loadingBallAppear
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30.0),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 70),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        tween: Tween(begin: 1, end: _elementsOpacity),
                        builder: (_, value, __) => Opacity(
                          opacity: value,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.medication,
                                      size: 60,
                                      color: Color.fromARGB(255, 0, 105, 243)),
                                  const SizedBox(height: 5),
                                  const Text("Hyzar",
                                      style: TextStyle(
                                          fontSize: 30,
                                          color:
                                              Color.fromARGB(255, 0, 105, 243),
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Text(
                                "Inicia sesión para continuar",
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.6),
                                  fontSize: 35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            EmailField(
                              fadeEmail: _elementsOpacity == 0,
                              emailController: _emailController,
                            ),
                            const SizedBox(height: 40),
                            PasswordField(
                              fadePassword: _elementsOpacity == 0,
                              passwordController: _passwordController,
                            ),
                            const SizedBox(height: 60),
                            GetStartedButton(
                              elementsOpacity: _elementsOpacity,
                              onTap: () {
                                _iniciarSesion();
                              },
                              onAnimatinoEnd: () async {
                                await Future.delayed(
                                    const Duration(milliseconds: 500));
                                setState(() {
                                  loadingBallAppear = true;
                                });
                              },
                              buttonText: "Iniciar Sesión",
                              iconData: Icons.arrow_forward_rounded,
                              buttonColor:
                                  const Color.fromARGB(255, 0, 105, 243),
                            ),
                            const SizedBox(height: 16), // Added padding
                            SizedBox(
                              width: 200,
                              height: 50,
                              child: GetStartedButton(
                                elementsOpacity: _elementsOpacity,
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      SlideFromRightPageRoute(
                                          enterPage: RegistroUsuarioScreen()));
                                },
                                onAnimatinoEnd: () async {
                                  // Add your logic here for the second button.
                                },
                                buttonText: "Registrarse",
                                iconData: Icons.how_to_reg,
                                buttonColor:
                                    const Color.fromARGB(255, 243, 130, 0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
