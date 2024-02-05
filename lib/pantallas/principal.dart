import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hyzar/estilos/Colores.dart';
import 'package:hyzar/pantallas/navigator_admin/pedidos_admin/pedidos_admin.dart';
import 'package:hyzar/pantallas/navigator_admin/usuarios/Usuarios.dart';
import 'package:hyzar/utilidades/backend/user_notifier.dart';
import 'package:hyzar/utilidades/widgets/generic_header.dart';
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
    const PantallaUS(),
    const PantallaBusqueda(),
    const PantallaPedidos(),
  ];
  late List<Widget> _childrenAdmin = [
    const PantallaUS(),
    const PantallaBusqueda(),
    const PedidosAdmin(),
    UsuariosAdmin(),
    const PantallaAgregar(),
  ];
  final List<String> _titlesUsuario = ["Productos", "Búsqueda", "Pedidos"];
  final List<String> _titlesAdmin = [
    "Productos en linea",
    "Búsqueda de productos",
    "Pedidos actuales",
    "Deudas de usuarios",
    "Agregar productos",
  ];

  final List<IconData> _icons = [
    Icons.store,
    Icons.search,
    Icons.insert_invitation_rounded,
    Icons.people,
    Icons.add,
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
            const PantallaUS(),
            const PantallaBusqueda(),
            const PantallaPedidos(),
          ];
          _childrenAdmin = [
            const PantallaUS(),
            const PantallaBusqueda(),
            const PedidosAdmin(),
            UsuariosAdmin(),
            const PantallaAgregar(),
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
            appBar: PreferredSize(
                preferredSize: const Size.fromHeight(100),
                child: GenericHeader(
                  icon: _icons[_currentIndex],
                  title: titles[_currentIndex],
                  mostrarImagen: true,
                )),
            body: Padding(
              padding: const EdgeInsets.only(
                  bottom: kBottomNavigationBarHeight + 60),
              child: children[_currentIndex],
            ),
            extendBody: true,
            bottomNavigationBar: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy < 0) {
                  // Si el deslizamiento es hacia arriba
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => DraggableScrollableSheet(
                      initialChildSize: 0.5,
                      minChildSize: 0.5,
                      maxChildSize: 0.9,
                      builder: (BuildContext context, myscrollController) {
                        return ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          child: Container(
                            color: Theme.of(context).backgroundColor,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: 40,
                                  height: 5,
                                  margin:
                                      const EdgeInsets.only(top: 8, bottom: 8),
                                  decoration: const BoxDecoration(
                                    color: Colores.gris,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                ),
                                Expanded(
                                  child: PantallaPerfil(
                                      controller: myscrollController,
                                      onPrincipal:
                                          _cerrarSesion), // Pasa el controlador aquí
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      NavigationBar(
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
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom:
                                50), // Ajusta este valor según tus necesidades
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(top: 8, bottom: 8),
                          decoration: const BoxDecoration(
                            color: Colores.gris,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
