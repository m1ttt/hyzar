import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hyzar/pantallas/navigator_user/pedidos/funciones/pedido.dart';
import 'detalle_medicamento.dart';

class PantallaUS extends StatefulWidget {
  final String userType;
  const PantallaUS({Key? key, required this.userType}) : super(key: key);

  @override
  _PantallaUSState createState() => _PantallaUSState();
}

class _PantallaUSState extends State<PantallaUS>
    with SingleTickerProviderStateMixin {
  bool ordenarPorNombre = true;
  bool mostrarSoloEliminados = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final ScrollController _scrollController = ScrollController();
  final Set<String> _selectedItems =
      Set<String>(); // Nuevo: para almacenar los elementos seleccionados
  bool _showLabel = true;

  void _toggleSelection(String itemId) {
    if (widget.userType == 'usuario') {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
      print(_selectedItems);
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );

    _animationController.forward();

    _scrollController.addListener(() {
      if (_scrollController.offset <=
              _scrollController.position.minScrollExtent &&
          !_scrollController.position.outOfRange) {
        setState(() {
          _showLabel = true;
        });
      } else {
        if (_showLabel == true) {
          setState(() {
            _showLabel = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
              return Text('Algo salió mal');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
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
            return ListView.builder(
              controller: _scrollController,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = snapshot.data!.docs[index];
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                data['id'] = document.id;
                int existencias = int.parse(data['existencias'].toString());
                Color color = Color.lerp(
                  Colors.red,
                  Colors.green,
                  existencias /
                      100, // Asume que 100 es el máximo de existencias
                )!;
                if (mostrarSoloEliminados && data['eliminado'] == 0) {
                  return Container(height: 0, width: 0);
                } else if (!mostrarSoloEliminados && data['eliminado'] == 1) {
                  return Container(height: 0, width: 0);
                } else {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleMedicamentoScreen(
                              userType: widget.userType, medicamento: data),
                        ),
                      );
                    },
                    onLongPress: () {
                      if (widget.userType == 'usuario') {
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
                            leading: Icon(Icons.medication, size: 60),
                            title: Text('${data['nombre']}'),
                            subtitle:
                                Text('Existencias: ${data['existencias']}'),
                          ),
                        ),
                      ),
                    ),
                  );
                }
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
                onPressed: () async {
                  List<String> ids = _selectedItems.toList();
                  List<DocumentSnapshot> datosPedidos = await obtenerDatosDePedidos(ids);
                },
                label: Text("Crear pedido"),
                icon: Icon(Icons.add_shopping_cart)),
          SizedBox(height: 10), // Cambiado width a height
          FloatingActionButton.extended(
            label: Text('Ordenar'), // Agregado un label "Ordenar"
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
                  PopupMenuItem(
                    value: 1,
                    child: Text("Ordenar por nombre o existencias"),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text("Ver suspendidos"),
                  ),
                  PopupMenuItem(
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
            icon: Icon(Icons.sort),
          ),
        ],
      ),
    );
  }
}
