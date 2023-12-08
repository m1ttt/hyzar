import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'barra_nav/busqueda.dart';
import 'barra_nav/inicio_us.dart';
import 'barra_nav/perfil.dart';
import 'barra_nav/agregar.dart';
import 'barra_nav_us/pedidos.dart';

class PrincipalUser extends StatefulWidget {
  final User user;
  const PrincipalUser({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _PrincipalUserState createState() => _PrincipalUserState();
}

class _PrincipalUserState extends State<PrincipalUser> {
  int _currentIndex = 0;
  String userName = "";
  String tipoUsuario = '';
  late Future<void> _loadUserTypeFuture;

  late List<Widget> _childrenUsuario = [
    PantallaUS(userType: tipoUsuario),
    PantallaBusqueda(
      userType: tipoUsuario,
    ),
    PantallaPedidos(),
  ];
  late List<Widget> _childrenAdmin = [
    PantallaUS(
      userType: tipoUsuario,
    ),
    PantallaBusqueda(
      userType: tipoUsuario,
    ),
    PantallaPedidos(),
    PantallaAgregar(),
  ];
  final List<String> _titlesUsuario = ["Productos", "Búsqueda", "Pedidos"];
  final List<String> _titlesAdmin = [
    "Productos",
    "Búsqueda",
    "Pedidos",
    "Agregar",
  ];
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    _loadUserTypeFuture = _loadUserType();
    super.initState();
  }

  Future<void> _loadUserType() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String userID = currentUser.uid;
        DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child("usuarios").child(userID);
        DatabaseEvent snapshot = await userRef.once();
        Map<dynamic, dynamic>? userData =
            snapshot.snapshot.value as Map<dynamic, dynamic>?;
        if (userData != null && userData["tipo"] != null) {
          setState(() {
            tipoUsuario = userData["tipo"];
            _currentIndex = 0; // Restablecer el índice a 0
          });
        }
      }
    } catch (e) {
      print("Error al cargar el tipo de usuario: $e");
    }
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
                print("Sesión cerrada correctamente");
              } catch (e) {
                print("Error al cerrar sesión: $e");
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
    return FutureBuilder(
      future: _loadUserTypeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _childrenUsuario = [
            PantallaUS(userType: tipoUsuario),
            PantallaBusqueda(
              userType: tipoUsuario,
            ),
            PantallaPedidos(),
          ];
          _childrenAdmin = [
            PantallaUS(
              userType: tipoUsuario,
            ),
            PantallaBusqueda(
              userType: tipoUsuario,
            ),
            PantallaPedidos(),
            PantallaAgregar(),
          ];
          List<Widget> _children =
              tipoUsuario == 'admin' ? _childrenAdmin : _childrenUsuario;
          List<String> _titles =
              tipoUsuario == 'admin' ? _titlesAdmin : _titlesUsuario;
          List<BottomNavigationBarItem> _items = [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Busqueda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_invitation_rounded),
              label: 'Pedidos',
            ),
          ];
          if (tipoUsuario == 'admin') {
            _items.add(
              BottomNavigationBarItem(
                icon: Icon(Icons.add),
                label: 'Agregar',
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading:
                  false, // Quitamos la flecha de retroceso
              title: Text(_titles[_currentIndex]),
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
                          builder: (context) =>
                              PantallaPerfil(user: widget.user),
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
            body: _children[_currentIndex],
            bottomNavigationBar: NavigationBar(
              onDestinationSelected: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              selectedIndex: _currentIndex,
              destinations: _items
                  .map((item) => NavigationDestination(
                        icon: item.icon,
                        label: item.label ?? '',
                      ))
                  .toList(),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error al cargar el tipo de usuario'));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
