import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hyzar/estilos/Colores.dart';
import 'package:hyzar/utilidades/backend/user_notifier.dart';
import 'package:hyzar/utilidades/widgets/ModalDialog.dart';
import 'package:hyzar/utilidades/widgets/generic_header.dart';
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
      body: ListView(
        controller: widget.controller,
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          GenericHeader(
            icon: Icons.dataset,
            title: "Opciones",
            mostrarImagen: false,
            boxShadow: BoxShadow(
              color: Theme.of(context).colorScheme.background,
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
            padding:
                const EdgeInsets.only(top: 0, left: 5, right: 5, bottom: 10),
          ),
          ListTile(
            title: Center(
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.file(
                        image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.warning,
                      color: Colors.yellow,
                      size: 24.0,
                    ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.mail),
              title: _estaEditando
                  ? TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Correo del usuario',
                      ),
                    )
                  : Text(user),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: _estaEditando
                  ? TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Correo del usuario',
                      ),
                    )
                  : Text(nombre),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.assignment_ind_outlined),
              title: _estaEditando
                  ? TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Correo del usuario',
                      ),
                    )
                  : Text(
                      userID,
                      style: const TextStyle(
                        fontSize:
                            12, // Ajusta este valor para cambiar el tamaño del texto
                      ),
                    ),
            ),
          ),
          if (_estaEditando)
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock),
                title: TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    hintText: 'Contraseña',
                  ),
                  obscureText: true,
                ),
              ),
            ),
          const SizedBox(height: 40),
          const Center(
            child: Text(
              "Más opciones de configuracion proximamente...",
              style: TextStyle(
                  color: Colores.gris,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          if (widget.onPrincipal != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colores.verde,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () {
                MessageDialog(
                  context,
                  title: "Alerta",
                  description: "¿Estás seguro que quieres cerrar sesión?",
                  buttonText: "CERRAR SESIÓN",
                  onReadMore: () {
                    widget.onPrincipal!();
                  },
                );
              },
              child: const Text('Cerrar sesión'),
            ),
        ],
      ),
    );
  }
}
