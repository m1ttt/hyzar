// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hyzar/pantallas/principal.dart';
import 'package:hyzar/utilidades/auth.dart';
import 'package:flutter/cupertino.dart'; // Importa CupertinoAlertDialog para iOS
import 'package:hyzar/auth/login/widgets/email_field.dart';
import 'package:hyzar/auth/login/widgets/get_started_button.dart';
import 'package:hyzar/auth/login/widgets/password_field.dart';
import 'package:hyzar/utilidades/backend/user_notifier.dart';
import 'package:provider/provider.dart';
import '../register/registro.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
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
  bool _isLoading = false;
  final Auth _auth = Auth();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final double _elementsOpacity = 1;
  StreamSubscription<User?>? _authStateChangesSubscription;
  bool loadingBallAppear = false;

  @override
  void initState() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    _authStateChangesSubscription =
        _auth.authStateChanges.listen((User? user) async {
      if (user != null && user != currentUser) {
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
            Provider.of<UserNotifier>(context, listen: false)
                .setEmail(user.email!);
            Provider.of<UserNotifier>(context, listen: false)
                .setUserType(userData["tipo"]);
            Provider.of<UserNotifier>(context, listen: false).setUserID(userID);
            Provider.of<UserNotifier>(context, listen: false)
                .setNombre(userData["nombre"]);
            Navigator.push(
                context, SlideFromRightPageRoute(enterPage: PrincipalUser()));
            // Aquí puedes realizar acciones específicas para los usuarios normales
          } else if (userData != null && userData["tipo"] == "admin") {
            // El usuario es un administrador
            print("Es un administrador");
            Provider.of<UserNotifier>(context, listen: false)
                .setEmail(user.email!);
            Provider.of<UserNotifier>(context, listen: false)
                .setUserType(userData["tipo"]);
            Provider.of<UserNotifier>(context, listen: false).setUserID(userID);
            Provider.of<UserNotifier>(context, listen: false)
                .setNombre(userData["nombre"]);
            Navigator.push(
                context, SlideFromRightPageRoute(enterPage: PrincipalUser()));

            // Aquí puedes realizar acciones específicas para los administradores
          } else {
            // El usuario no tiene el campo "tipo" definido o no es ni usuario ni admin
            print(
                "El tipo de usuario no está definido correctamente. [admin/usuario]]");
          }
        }
      } else {
        print("No hay usuario autenticado");
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

  void _iniciarSesion() async {
    setState(() {
      _isLoading = true;
    });
    String email = _emailController.text;
    String password = _passwordController.text;

    Auth auth = Auth();
    User? user = await auth.iniciarSesionEmailPass(email, password);

    if (user != null) {
      // El usuario inició sesión correctamente, puedes realizar acciones adicionales aquí.
      print("Hola, ${user.email}! Inicio de sesión exitoso.");
      // Verificar el tipo de usuario (usuario o admin)
      String userID = user.uid;
      Provider.of<UserNotifier>(context, listen: false).setUserID(userID);
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child("usuarios").child(userID);
      DataSnapshot snapshot = (await userRef.once()).snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic>? userData =
            snapshot.value as Map<dynamic, dynamic>?;
        if (userData != null && userData["tipo"] == "usuario") {
          // El usuario es un usuario normal
          print("Es un usuario");
          Provider.of<UserNotifier>(context, listen: false)
              .setEmail(user.email!);
          Provider.of<UserNotifier>(context, listen: false)
              .setUserType(userData["tipo"]);
          Provider.of<UserNotifier>(context, listen: false).setUserID(userID);
          Provider.of<UserNotifier>(context, listen: false)
              .setNombre(userData["nombre"]);
          Navigator.push(
              context, SlideFromRightPageRoute(enterPage: PrincipalUser()));
          // Aquí puedes realizar acciones específicas para los usuarios normales
        } else if (userData != null && userData["tipo"] == "admin") {
          // El usuario es un administrador
          print("Es un administrador");
          Provider.of<UserNotifier>(context, listen: false)
              .setEmail(user.email!);
          Provider.of<UserNotifier>(context, listen: false)
              .setUserType(userData["tipo"]);
          Navigator.push(
              context, SlideFromRightPageRoute(enterPage: PrincipalUser()));
          Provider.of<UserNotifier>(context, listen: false).setUserID(userID);
          Provider.of<UserNotifier>(context, listen: false)
              .setNombre(userData["nombre"]);
          // Aquí puedes realizar acciones específicas para los administradores
        } else {
          // El usuario no tiene el campo "tipo" definido o no es ni usuario ni admin
          print(
              "El tipo de usuario no está definido correctamente. [admin/usuario]]");
        }
      }
    } else {
      // Hubo un error al iniciar sesión, manejarlo adecuadamente.
      String errorMessage =
          "Ocurrió un error al iniciar sesión. Verifica tus credenciales.";
      _showErrorDialog(errorMessage);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Dialog(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20),
                      Text("Iniciando Sesión"),
                    ],
                  ),
                ),
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
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.medication,
                                      size: 60,
                                      color: Color.fromARGB(255, 0, 105, 243)),
                                  SizedBox(height: 5),
                                  Text("Hyzar",
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
                                          enterPage:
                                              const RegistroUsuarioScreen()));
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
