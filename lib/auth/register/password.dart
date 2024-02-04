import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hyzar/estilos/Colores.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PasswordUsuarioscren extends StatefulWidget {
  final Map<String, String> datosUsuario;

  const PasswordUsuarioscren({
    Key? key,
    required this.datosUsuario,
  }) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _PasswordUsuarioState createState() => _PasswordUsuarioState();
}

class _PasswordUsuarioState extends State<PasswordUsuarioscren> {
  final picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child("usuarios");
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? genero;

  Future<String> subirImagen(File imagen, String codigo) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('user_images/$codigo');
      final uploadTask = ref.putFile(imagen);

      final taskSnapshot = await uploadTask;
      final imageUrl = await taskSnapshot.ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Error al subir imagen: $e');
      throw e;
    }
  }

  Future<File> base64ToFile(String base64Image) async {
    final decodedBytes = base64Decode(base64Image);
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    final file = File('$path/image.jpg');
    await file.writeAsBytes(decodedBytes);
    return file;
  }

  void _registrarUsuario() async {
    Map<String, String> datosCompletos = {
      ...widget.datosUsuario,
      'password': _passwordController.text,
    };
    print(datosCompletos);
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: datosCompletos["correo"]!.trim(),
              password: datosCompletos["password"]!);

      if (userCredential.user != null) {
        String userID = userCredential.user!.uid;

        await _databaseReference.child(userID).set({
          "nombre": datosCompletos["nombre"],
          "correo": datosCompletos["correo"],
          "telefono": datosCompletos["telefono"],
          "genero": datosCompletos["genero"],
          "tipo": "usuario",
        });

        if (datosCompletos["imagen"] != null) {
          File imagen = await base64ToFile(datosCompletos["imagen"]!);
          String url = await subirImagen(imagen, userID);
          await _databaseReference.child(userID).update({"imagen": url});
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario registrado correctamente")),
        );

        Navigator.of(context).pushNamed('/login');
      }
    } catch (e) {
      print(datosCompletos);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
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
              color: Colores.gris, // Cambia el color del icono a gris
            ),
            onPressed: () {
              Navigator.of(context)
                  .pop(); // Navegar hacia atrás al presionar el botón de flecha
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
                      Icons.password,
                      size: 60,
                      color: Colores.verde,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Confirma tu \ncontraseña",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colores.verde),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Text(
                  "Ingresa una contraseña de mínimo 8 caracteres",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colores.gris,
                  ),
                  textAlign: TextAlign.justify,
                ),

                const SizedBox(height: 16),
                // TextField(
                //   controller: _telefonoController,
                //   decoration: const InputDecoration(
                //     labelText: 'Teléfono',
                //     enabledBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.all(Radius.circular(20.0)),
                //       borderSide: BorderSide(
                //         color: Colores.gris, // Cambia el color del borde a gris
                //         width: 1.0,
                //       ),
                //     ),
                //     focusedBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.all(Radius.circular(20.0)),
                //       borderSide: BorderSide(
                //         color: Colores.gris, // Cambia el color del borde a gris
                //         width: 2.0,
                //       ),
                //     ),
                //   ),
                // ),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(width: 1.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "Confirma tu contraseña",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colores.gris),
                ),

                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(width: 1.0),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    top: 150.0, // Ajusta este valor según tus necesidades
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                            bottom: 20.0), // Margen inferior
                        child: Text(
                          "Al registrarte aceptas los términos y condiciones de la aplicación",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colores.gris,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _registrarUsuario,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colores.verde,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 16),
                        ),
                        child: Text(
                          'Registrarse',
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
