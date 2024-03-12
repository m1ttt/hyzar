// ignore_for_file: use_build_context_synchronously

import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyzar/estilos/Colores.dart';
import 'package:hyzar/pantallas/navigator_user/pedidos/funciones/pedido.dart';
import 'package:hyzar/pantallas/navigator_user/pedidos/pedidos_confirm.dart';
import 'package:hyzar/utilidades/backend/user_notifier.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../Detalles/detalle_medicamento.dart';

class PantallaUS extends StatefulWidget {
  const PantallaUS({super.key});

  @override
  _PantallaUSState createState() => _PantallaUSState();
}

class _PantallaUSState extends State<PantallaUS>
    with SingleTickerProviderStateMixin {
  late String userType;
  late String email;
  late String nombre;
  bool ordenarPorNombre = true;
  bool mostrarSoloEliminados = false;

  final ScrollController _scrollController = ScrollController();
  final Set<String> _selectedItems = <String>{};

  void _toggleSelection(String itemId) {
    if (userType == 'usuario') {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
      print(_selectedItems);
    }
  }

  void initUserType() async {
    userType = Provider.of<UserNotifier>(context, listen: false).getUserType();
    email = Provider.of<UserNotifier>(context, listen: false).getEmail();
    nombre = Provider.of<UserNotifier>(context, listen: false)
        .getNombre()
        .split(' ')[0];
  }

  @override
  void initState() {
    super.initState();
    initUserType();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _scrollController.animateTo(
              0.0,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 300),
            );
          });
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('medicamentos')
              .orderBy(ordenarPorNombre ? 'nombre' : 'existencias')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Algo salió mal');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Obteniendo productos..."),
                    SizedBox(height: 10),
                    CircularProgressIndicator(),
                  ],
                ),
              );
            }

            List<Widget> children = snapshot.data!.docs.where((document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return (mostrarSoloEliminados && data['eliminado'] == 1) ||
                  (!mostrarSoloEliminados && data['eliminado'] == 0);
            }).map((document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              data['id'] = document.id;
              int existencias = int.parse(data['existencias'].toString());
              Color color = Color.lerp(
                Colors.red,
                Colors.green,
                existencias / 100, // Asume que 100 es el máximo de existencias
              )!;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleMedicamentoScreen(
                          userType: userType, medicamento: data),
                    ),
                  );
                },
                onLongPress: () {
                  if (userType == 'usuario') {
                    setState(() {
                      _toggleSelection(data['id']);
                    });
                  }
                },
                child: Hero(
                  tag: 'detalle${data['id']}',
                  child: Container(
                    margin: const EdgeInsets.all(5.0),
                    color: _selectedItems.contains(data['id'])
                        ? Colors.blue
                        : null,
                    child: Card(
                      color: color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height:
                                120, // Ajusta esto a la altura que desees para la imagen
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15.0),
                              ),
                              image: DecorationImage(
                                image: (data['imagen'] == null ||
                                        data['imagen'] == '')
                                    ? const AssetImage(
                                        'lib/assets/NoImagen.png') // Reemplaza esto con la ruta a tu imagen predeterminada
                                    : CachedNetworkImageProvider(data['imagen'])
                                        as ImageProvider<Object>,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              color: Theme.of(context).colorScheme.background,
                              child: Center(
                                // Añadido el widget Center
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: ListTile(
                                    title: Text('${data['nombre']}'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList();
            return CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                      padding: const EdgeInsets.only(
                          top: 3, left: 20, right: 20, bottom: 10),
                      child: Column(
                        children: [
                          Text(
                            userType == 'admin'
                                ? "Modo administrador activado"
                                : "¿Qué vas a pedir hoy, ${nombre}?",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colores.gris,
                            ),
                          ),
                          userType == 'admin'
                              ? const Text(
                                  "Cuidado, tienes el control total desde ahora",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colores.gris,
                                      fontWeight: FontWeight.bold),
                                )
                              : Container(
                                  child: Column(
                                    children: const [
                                      Text(
                                        "Desliza hacia abajo para ver más productos o",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colores.gris,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "manten presionado un producto para seleccionarlo",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colores.gris,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                        ],
                      )),
                ),
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return children[index];
                    },
                    childCount: children.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (_selectedItems.isNotEmpty)
            FutureBuilder<List<DocumentSnapshot>>(
              // Obtener los datosPedidos aquí
              future: obtenerDatosDePedidos(_selectedItems.toList()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  List<DocumentSnapshot> datosPedidos = snapshot.data!;

                  return OpenContainer(
                    closedElevation: 6.0,
                    openElevation: 0.0,
                    closedShape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(56 / 2)),
                    ),
                    transitionDuration: const Duration(milliseconds: 500),
                    openBuilder: (BuildContext context, VoidCallback _) {
                      return PantallaPedidosConfirm(documentos: datosPedidos);
                    },
                    closedBuilder:
                        (BuildContext context, VoidCallback openContainer) {
                      return FloatingActionButton.extended(
                        heroTag: "FAB1",
                        onPressed: openContainer, // Abre el OpenContainer
                        label: const Text("Crear pedido"),
                        icon: const Icon(Icons.add_shopping_cart),
                      );
                    },
                  );
                } else {
                  // Manejar estados de carga o error aquí
                  return const CircularProgressIndicator();
                }
              },
            ),
          const SizedBox(height: 10), // Cambiado width a height
          FloatingActionButton.extended(
            heroTag: "FAB2",
            label: const Text('Ordenar'), // Agregado un label "Ordenar"
            onPressed: () {
              final RenderBox renderBox =
                  context.findRenderObject() as RenderBox;
              final size = renderBox.size;
              final offset = renderBox.localToGlobal(Offset.zero);
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                  offset.dx,
                  offset.dy + size.height,
                  offset.dx + size.width,
                  offset.dy,
                ),
                items: [
                  const PopupMenuItem(
                    value: 1,
                    child: Text("Ordenar por nombre o existencias"),
                  ),
                  const PopupMenuItem(
                    value: 2,
                    child: Text("Ver suspendidos"),
                  ),
                  const PopupMenuItem(
                    value: 3,
                    child: Text("Ver no suspendidos"),
                  ),
                ],
              ).then((value) {
                if (value != null) {
                  setState(() {
                    switch (value) {
                      case 1:
                        ordenarPorNombre = !ordenarPorNombre;
                        break;
                      case 2:
                        mostrarSoloEliminados = true;
                        break;
                      case 3:
                        mostrarSoloEliminados = false;
                        break;
                    }
                  });
                }
              });
            },
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
    );
  }
}
