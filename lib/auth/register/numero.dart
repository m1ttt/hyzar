// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hyzar/auth/register/password.dart';
import 'package:hyzar/utilidades/Colores.dart';
import 'package:image_picker/image_picker.dart';

class NumeroUsuarioScreen extends StatefulWidget {
  final Map<String, String> datosUsuario;

  const NumeroUsuarioScreen({
    Key? key,
    required this.datosUsuario,
  }) : super(key: key);

  @override
  _NumeroUsuarioState createState() => _NumeroUsuarioState();
}

class _NumeroUsuarioState extends State<NumeroUsuarioScreen> {
  final picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child("usuarios");

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final bool _aceptoTerminos = false;
  String? genero;

  Future<String> subirImagen(File imagen, String codigo) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('$codigo');
      final uploadTask = ref.putFile(imagen);

      final taskSnapshot = await uploadTask;
      final imageUrl = await taskSnapshot.ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Error al subir imagen: $e');
      throw e;
    }
  }

  void _registrarUsuario() async {
    if (_aceptoTerminos) {
      if (_nombreController.text.isNotEmpty &&
          _correoController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty) {
        if (_passwordController.text == _confirmPasswordController.text) {
          try {
            UserCredential userCredential =
                await _auth.createUserWithEmailAndPassword(
              email: _correoController.text.trim(),
              password: _passwordController.text,
            );

            if (userCredential.user != null) {
              String userID = userCredential.user!.uid;

              await _databaseReference.child(userID).set({
                "nombre": _nombreController.text,
                "correo": _correoController.text,
                "telefono": _telefonoController.text,
                "genero": genero,
                "tipo": "usuario",
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Usuario registrado correctamente")),
              );

              Navigator.pop(context);
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Autenticación fallida")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Las contraseñas no coinciden")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Todos los campos son requeridos")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes aceptar los términos")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colores.gris,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 60,
                      color: Colores.verde,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Número de \nteléfono",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colores.verde),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Agrega tu número de teléfono",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colores.gris,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _telefonoController,
                  keyboardType:
                      TextInputType.phone, // Campo numérico de teléfono
                  decoration: const InputDecoration(
                    labelText: 'Número de teléfono',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(width: 1.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.only(
                    top: 290.0, // Ajusta este valor según tus necesidades
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          "En un futuro, te pediremos que verifiques tu número de teléfono",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colores.gris,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Map<String, String> datosCompletos = {
                            "nombre": widget.datosUsuario["nombre"]!,
                            "correo": widget.datosUsuario["correo"]!,
                            "telefono": _telefonoController.text,
                            "genero": widget.datosUsuario["genero"]!,
                          };
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PasswordUsuarioscren(
                                  datosUsuario: datosCompletos),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colores.verde, // Cambia el color de fondo a verde
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 16),
                        ),
                        child: Text(
                          'Siguiente',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
