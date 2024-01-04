import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../../../utilidades/backend/user_notifier.dart';
import 'widgets/PedidoCard.dart';

enum EstadoFiltro { todos, pagado, noPagado }

class PantallaPedidos extends StatefulWidget {
  const PantallaPedidos({Key? key}) : super(key: key);

  @override
  _PantallaPedidosState createState() => _PantallaPedidosState();
}

class _PantallaPedidosState extends State<PantallaPedidos> {
  bool mostrarSoloPagados = false;
  EstadoFiltro estadoFiltro = EstadoFiltro.todos;
  ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!_isScrolling) {
          setState(() {
            _isScrolling = true;
          });
        }
      }
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (_isScrolling) {
          setState(() {
            _isScrolling = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userID = Provider.of<UserNotifier>(context).getUserID();
    print('ID del usuario: $userID');
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          color: Colors.white,
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pedidos')
                .doc(userID)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              DocumentSnapshot<Object?>? pedido = snapshot.data;
              Map<String, dynamic> datosPedido =
                  pedido?.data() as Map<String, dynamic>;

              if (datosPedido.isEmpty) {
                return Center(child: Text('No haz hecho ningún pedido'));
              }

              return ListView.builder(
                controller: _scrollController,
                itemCount: datosPedido.length,
                itemBuilder: (context, index) {
                  String pedidoID = datosPedido.keys.elementAt(index);
                  Map<String, dynamic> detallesPedido = datosPedido[pedidoID];
                  if (estadoFiltro == EstadoFiltro.pagado &&
                      !detallesPedido['pagado']) {
                    return Container();
                  } else if (estadoFiltro == EstadoFiltro.noPagado &&
                      detallesPedido['pagado']) {
                    return Container();
                  }
                  return PedidoCard(
                      detallesPedido: detallesPedido,
                      pedidoID: pedidoID,
                      userID: userID);
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(child: child, scale: animation);
        },
        child: _isScrolling
            ? FloatingActionButton(
                key: ValueKey(1),
                onPressed: () {
                  setState(() {
                    estadoFiltro = EstadoFiltro.values[
                        (estadoFiltro.index + 1) % EstadoFiltro.values.length];
                  });
                },
                child: Icon(Icons.filter_list),
              )
            : AnimatedContainer(
                key: ValueKey(2),
                duration: Duration(milliseconds: 200),
                width: _isScrolling ? 56 : null,
                child: FloatingActionButton.extended(
                  label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      estadoFiltro == EstadoFiltro.todos
                          ? 'Filtrar por pagado'
                          : estadoFiltro == EstadoFiltro.pagado
                              ? 'Filtrar por no pagado'
                              : 'Mostrar todos',
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      estadoFiltro = EstadoFiltro.values[
                          (estadoFiltro.index + 1) %
                              EstadoFiltro.values.length];
                    });
                  },
                  icon: Icon(Icons.filter_list),
                ),
              ),
      ),
    );
  }
}
