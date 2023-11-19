import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'barra_nav/busqueda.dart';
import 'barra_nav/inicio_us.dart';
import 'barra_nav/perfil.dart';
import 'barra_nav/agregar.dart';

class PrincipalUser extends StatefulWidget {
  const PrincipalUser({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PrincipalUserState createState() => _PrincipalUserState();
}

class _PrincipalUserState extends State<PrincipalUser> {
  int _currentIndex = 0;
  String userName = "";
  List<Widget> _children = [
    PantallaUS(),
    PantallaBusqueda(),
    PantallaAgregar(),
  ];
  final List<String> _titles = [
    "Lista de productos",
    "Búsqueda",
    "Agregar",
    "Perfil"
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    _loadUserName();
    super.initState();
  }

  Future<String> _loadUserName() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String userID = currentUser.uid;
        DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child("usuarios").child(userID);
        DataSnapshot snapshot = (await userRef.once()) as DataSnapshot;
        Map<dynamic, dynamic>? userData =
            snapshot.value as Map<dynamic, dynamic>?;
        if (userData != null && userData["nombre"] != null) {
          setState(() {
            userName = userData["nombre"];
            print(userName);
          });
        }
      }
    } catch (e) {
      print("Error al cargar el nombre del usuario: $e");
    }
    return userName; // Devuelve el nombre del usuario
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Quitamos la flecha de retroceso
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
      body: IndexedStack(
        index: _currentIndex,
        children: _children,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Busqueda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Agregar',
          ),
        ],
      ),
    );
  }
}
