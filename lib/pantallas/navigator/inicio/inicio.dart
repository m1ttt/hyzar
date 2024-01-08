// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  }

  @override
  void initState() {
    super.initState();
    initUserType();
  }

  @override
  void dispose() {
    super.dispose();
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

            List<Widget> children = snapshot.data!.docs.map((document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              data['id'] = document.id;
              int existencias = int.parse(data['existencias'].toString());
              Color color = Color.lerp(
                Colors.red,
                Colors.green,
                existencias / 100, // Asume que 100 es el máximo de existencias
              )!;
              if (mostrarSoloEliminados && data['eliminado'] == 0) {
                return const SizedBox(height: 0, width: 0);
              } else if (!mostrarSoloEliminados && data['eliminado'] == 1) {
                return const SizedBox(height: 0, width: 0);
              } else {
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
                        child: ListTile(
                          leading:
                              (data['imagen'] == null || data['imagen'] == '')
                                  ? const Icon(
                                      Icons.warning,
                                      size: 60,
                                      color: Colors.yellow,
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(20.0),
                                      child: CachedNetworkImage(
                                        imageUrl: data['imagen'],
                                        width: 60,
                                        height: 60,
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    ),
                          title: Text('${data['nombre']}'),
                          subtitle: Text('Existencias: ${data['existencias']}'),
                        ),
                      ),
                    ),
                  ),
                );
              }
            }).toList();

            return ListView.builder(
              controller: _scrollController,
              itemCount: children.length,
              itemBuilder: (context, index) {
                return children[index];
              },
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (_selectedItems.isNotEmpty)
            FloatingActionButton.extended(
              heroTag: "FAB1",
              onPressed: () async {
                List<String> ids = _selectedItems.toList();
                List<DocumentSnapshot> datosPedidos =
                    await obtenerDatosDePedidos(ids);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PantallaPedidosConfirm(documentos: datosPedidos),
                  ),
                ).then((_) {
                  // Limpia _selectedItems después de navegar a PantallaPedidosConfirm
                  setState(() {
                    _selectedItems.clear();
                  });
                });
              },
              label: const Text("Crear pedido"),
              icon: const Icon(Icons.add_shopping_cart),
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
