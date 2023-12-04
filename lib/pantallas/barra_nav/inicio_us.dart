import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'DetalleMedicamentoScreen.dart';

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
    if (widget.userType == 'usuari') {
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
              return Text("Cargando");
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
      floatingActionButton: PopupMenuButton<int>(
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Text("Ordenar por nombre"),
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
        onSelected: (value) {
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
        },
        icon: Icon(Icons.sort),
      ),
    );
  }
}
