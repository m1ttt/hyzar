import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utilidades/backend/user_notifier.dart';
import 'widgets/PedidoCard.dart';

class PantallaPedidos extends StatelessWidget {
  const PantallaPedidos({super.key});
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
                itemCount: datosPedido.length,
                itemBuilder: (context, index) {
                  String pedidoID = datosPedido.keys.elementAt(index);
                  Map<String, dynamic> detallesPedido = datosPedido[pedidoID];
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
    );
  }
}
