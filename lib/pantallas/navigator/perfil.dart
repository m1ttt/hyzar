import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hyzar/estilos/Colores.dart';
import 'package:hyzar/utilidades/backend/user_notifier.dart';
import 'package:provider/provider.dart';

class PantallaPerfil extends StatefulWidget {
  final ScrollController controller;
  final Function? onPrincipal;
  const PantallaPerfil({
    Key? key,
    required this.controller,
    this.onPrincipal,
  }) : super(key: key);

  @override
  _PantallaPerfilState createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _estaEditando = false;

  // void _actualizarPerfil() async {
  //   try {
  //     await widget.user.updateEmail(_emailController.text);
  //     await widget.user.updatePassword(_passwordController.text);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Perfil actualizado con éxito'),
  //       ),
  //     );
  //     setState(() {
  //       _estaEditando = false;
  //     });
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error al actualizar el perfil: $e'),
  //       ),
  //     );
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // _emailController.text = widget.user.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserNotifier>(context).getEmail();
    var userID = Provider.of<UserNotifier>(context).getUserID();
    var nombre = Provider.of<UserNotifier>(context).getNombre();
    File? image = Provider.of<UserNotifier>(context).getImage();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Agrega esta línea
        title: Text('Perfil'),
        actions: <Widget>[
          IconButton(
            icon: Icon(_estaEditando ? Icons.check : Icons.edit),
            onPressed: () {
              if (_estaEditando) {
                // _actualizarPerfil();
              } else {
                setState(() {
                  _estaEditando = true;
                });
              }
            },
          ),
        ],
      ),
      body: ListView(
        controller: widget.controller,
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          ListTile(
            title: image != null
                ? Image.file(
                    image,
                    width: 100, // puedes ajustar el ancho como prefieras
                    height: 100, // puedes ajustar la altura como prefieras
                  )
                : Text('No se ha cargado ninguna imagen'),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.person),
              title: _estaEditando
                  ? TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Correo del usuario',
                      ),
                    )
                  : Text(user),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.person),
              title: _estaEditando
                  ? TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Correo del usuario',
                      ),
                    )
                  : Text(nombre),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.person),
              title: _estaEditando
                  ? TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Correo del usuario',
                      ),
                    )
                  : Text(
                      userID,
                      style: TextStyle(
                        fontSize:
                            12, // Ajusta este valor para cambiar el tamaño del texto
                      ),
                    ),
            ),
          ),
          if (_estaEditando)
            Card(
              child: ListTile(
                leading: Icon(Icons.lock),
                title: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                  ),
                  obscureText: true,
                ),
              ),
            ),
          SizedBox(height: 20),
          if (widget.onPrincipal != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colores.verde,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () {
                widget.onPrincipal!();
              },
              child: const Text(
                'Cerrar sesión',
              ),
            ),
        ],
      ),
    );
  }
}
