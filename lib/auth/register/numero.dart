// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hyzar/auth/register/password.dart';
import 'package:hyzar/estilos/Colores.dart';
import 'package:hyzar/utilidades/widgets/ModalDialog.dart';

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
  final TextEditingController _telefonoController = TextEditingController();

  void enviarDatos() {
    if (_telefonoController.text.isEmpty) {
      MessageDialog(context,
          title: "Alerta",
          description: "El número no puede quedar vacio",
          buttonText: "ACEPTAR", onReadMore: () {
        Navigator.pop(context);
      }, showCloseButton: false);
    } else {
      Map<String, String> datosCompletos = {
        "nombre": widget.datosUsuario["nombre"]!,
        "correo": widget.datosUsuario["correo"]!,
        "telefono": _telefonoController.text,
        "genero": widget.datosUsuario["genero"]!,
        "imagen": widget.datosUsuario["imagen"]!,
      };
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PasswordUsuarioscren(datosUsuario: datosCompletos),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
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
                    SizedBox(
                        height:
                            20), // Espacio entre el título y el campo de texto
                    Center(
                      child: SvgPicture.asset(
                        'lib/assets/AgregarNumero.svg',
                        height: 250,
                        width: 400,
                        color: Colores.verde,
                      ), // Imagen
                    ),
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
                        top: 40.0, // Ajusta este valor según tus necesidades
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
                              enviarDatos();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colores
                                  .verde, // Cambia el color de fondo a verde
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
            )));
  }
}
