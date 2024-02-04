// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hyzar/auth/register/numero.dart';
import 'package:hyzar/estilos/Colores.dart';
import 'package:hyzar/utilidades/widgets/ModalDialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class RegistroUsuarioScreen extends StatefulWidget {
  const RegistroUsuarioScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistroUsuarioScreenState createState() => _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  final picker = ImagePicker();
  File? _imageFile;
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

              Navigator.pop(context); // Regresar a la pantalla anterior
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
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

  String imageToBase64(File imageFile) {
    final bytes = imageFile.readAsBytesSync();
    return base64Encode(bytes);
  }

  void guardarDatos() {
    String? imageBase64;
    if (_imageFile != null) {
      imageBase64 = imageToBase64(_imageFile!);
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NumeroUsuarioScreen(
        datosUsuario: {
          'nombre': _nombreController.text,
          'correo': _correoController.text,
          'genero': genero ??= '',
          'imagen': imageBase64 ?? '',
        },
      );
    }));
  }

  Future<void> seleccionarImagen(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);
      setState(() {
        if (pickedFile != null) {
          _imageFile = File(pickedFile.path);
        } else {
          print('No se seleccionó ninguna imagen.');
        }
      });
    } catch (e) {
      print('Error al seleccionar imagen: $e');
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
                      Icons.how_to_reg,
                      size: 60,
                      color: Colores.verde,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "¿Quién eres?",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colores.verde),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    ImageSourceDialog(
                      context,
                      onSelectSource: (source) async {
                        final pickedFile =
                            await ImagePicker().pickImage(source: source);
                        if (pickedFile != null) {
                          final croppedFile = await ImageCropper().cropImage(
                            sourcePath: pickedFile.path,
                            aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
                            compressQuality: 100,
                            maxWidth: 700,
                            maxHeight: 700,
                            compressFormat: ImageCompressFormat.jpg,
                          );
                          if (croppedFile != null) {
                            setState(() {
                              _imageFile = File(croppedFile.path);
                            });
                          }
                        }
                      },
                      onDelete: _imageFile != null
                          ? () {
                              setState(() {
                                _imageFile = null;
                              });
                            }
                          : null,
                    );
                  },
                  child: _imageFile == null
                      ? SvgPicture.asset(
                          'lib/assets/AgregarImagen.svg',
                          width: 150,
                          height: 150,
                          color: Colores.gris,
                        )
                      : Center(
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              image: DecorationImage(
                                image: FileImage(_imageFile!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "Cuentanos más acerca de ti...",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colores.gris),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(
                        color: Colores.gris, // Cambia el color del borde a gris
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(
                        color: Colores.gris, // Cambia el color del borde a gris
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _correoController,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(
                        color: Colores.gris, // Cambia el color del borde a gris
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(
                        color: Colores.gris, // Cambia el color del borde a gris
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  height: 60.0, // Ajusta este valor según tus necesidades
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: Colores.gris, // Cambia el color del borde a gris
                      width: 1.0,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Text('Género'),
                      value: genero,
                      items: const [
                        DropdownMenuItem(
                          value: "masculino",
                          child: Row(
                            children: [
                              Icon(Icons.male), // Icono de hombre
                              SizedBox(width: 8.0),
                              Text('Masculino'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: "femenino",
                          child: Row(
                            children: [
                              Icon(Icons.female), // Icono de mujer
                              SizedBox(width: 8.0),
                              Text('Femenino'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: "otro",
                          child: Row(
                            children: [
                              Icon(Icons.person), // Icono de persona
                              SizedBox(width: 8.0),
                              Text('Otro'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          genero = value!;
                        });
                      },
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      top: 70.0), // Ajusta este valor según tus necesidades
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nombreController.text.isEmpty ||
                          _correoController.text.isEmpty ||
                          (genero == null || genero!.isEmpty)) {
                        MessageDialog(context,
                            title: 'Alerta',
                            description: 'Todos los campos deben estar llenos',
                            onReadMore: () {
                          Navigator.pop(context);
                        }, buttonText: 'ACEPTAR', showCloseButton: false);
                      } else if (_imageFile == null) {
                        MessageDialog(
                          context,
                          title: 'Alerta',
                          description: '¿Estás seguro de continuar sin imagen?',
                          onReadMore: () {
                            guardarDatos();
                          },
                          buttonText: 'CONTINUAR',
                          showCloseButton: true,
                          buttonCancelText: "AGREGAR IMAGEN",
                          onClose: () {
                            Navigator.pop(context);
                          },
                        );
                      } else {
                        guardarDatos();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 31, 195, 146),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: Text(
                      'Siguiente',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
