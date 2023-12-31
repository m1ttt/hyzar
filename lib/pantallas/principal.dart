import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hyzar/pantallas/navigator_admin/pedidos_admin/PedidosAdmin.dart';
import 'package:hyzar/pantallas/navigator_admin/usuarios/Usuarios.dart';
import 'package:hyzar/utilidades/backend/user_notifier.dart';
import 'package:provider/provider.dart';
import 'navigator/busqueda.dart';
import 'navigator/inicio/inicio.dart';
import 'navigator/perfil.dart';
import 'navigator/agregar/agregar.dart';
import 'navigator_user/pedidos/pedidos.dart';

class PrincipalUser extends StatefulWidget {
  const PrincipalUser({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PrincipalUserState createState() => _PrincipalUserState();
}

class _PrincipalUserState extends State<PrincipalUser> {
  int _currentIndex = 0;
  late Future<void> _loadUserTypeFuture;
  late String tipoUsuario;
  late String email;

  late List<Widget> _childrenUsuario = [
    PantallaUS(),
    PantallaBusqueda(),
    const PantallaPedidos(),
  ];
  late List<Widget> _childrenAdmin = [
    PantallaUS(),
    PantallaBusqueda(),
    PedidosAdmin(),
    UsuariosAdmin(),
    PantallaAgregar(),
  ];
  final List<String> _titlesUsuario = ["Productos", "Búsqueda", "Pedidos"];
  final List<String> _titlesAdmin = [
    "Productos en linea",
    "Búsqueda de productos",
    "Pedidos actuales",
    "Deudas de usuarios",
    "Agregar productos",
  ];

  @override
  void initState() {
    _loadUserTypeFuture = _loadUserType();
    super.initState();
  }

  Future<void> _loadUserType() async {
    tipoUsuario =
        Provider.of<UserNotifier>(context, listen: false).getUserType();
    email = Provider.of<UserNotifier>(context, listen: false).getEmail();
  }

  void _cerrarSesion() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Cerrar el diálogo
              try {
                await FirebaseAuth.instance.signOut();
                // ignore: use_build_context_synchronously
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (Route<dynamic> route) => false);
              } catch (e) {
                // Aquí puedes manejar cualquier error que pueda ocurrir al cerrar sesión
              }
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadUserTypeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _childrenUsuario = [
            PantallaUS(),
            PantallaBusqueda(),
            const PantallaPedidos(),
          ];
          _childrenAdmin = [
            PantallaUS(),
            PantallaBusqueda(),
            PedidosAdmin(),
            UsuariosAdmin(),
            PantallaAgregar(),
          ];
          List<Widget> children =
              tipoUsuario == 'admin' ? _childrenAdmin : _childrenUsuario;
          List<String> titles =
              tipoUsuario == 'admin' ? _titlesAdmin : _titlesUsuario;
          List<BottomNavigationBarItem> items = [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Busqueda',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.insert_invitation_rounded),
              label: 'Pedidos',
            ),
          ];
          if (tipoUsuario == 'admin') {
            items.add(
              const BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Usuarios',
              ),
            );
            items.add(
              const BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Agregar',
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading:
                  false, // Quitamos la flecha de retroceso
              title: Text(titles[_currentIndex]),
              actions: [
                PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'cerrarSesion') {
                      _cerrarSesion();
                    }
                    if (value == 'perfil') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PantallaPerfil(),
                        ),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem(
                        value: 'perfil',
                        child: Text('Perfil'),
                      ),
                      const PopupMenuItem(
                        value: 'cerrarSesion',
                        child: Text('Cerrar Sesión'),
                      ),
                    ];
                  },
                ),
              ],
            ),
            body: children[_currentIndex],
            bottomNavigationBar: NavigationBar(
              onDestinationSelected: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              selectedIndex: _currentIndex,
              destinations: items
                  .map((item) => NavigationDestination(
                        icon: item.icon,
                        label: item.label ?? '',
                      ))
                  .toList(),
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(
              child: Text('Error al cargar el tipo de usuario'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
