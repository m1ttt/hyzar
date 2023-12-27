import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PantallaPerfil extends StatefulWidget {
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
    return Scaffold(
      appBar: AppBar(
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
        padding: const EdgeInsets.all(10),
        children: <Widget>[
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
                  : Text(''),
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
        ],
      ),
    );
  }
}
