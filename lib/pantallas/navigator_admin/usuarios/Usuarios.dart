import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'widget/UsuariosCard.dart';

class UsuariosAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pedidos').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Algo salió mal');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Cargando");
          }

          // Agrupar pedidos por usuario y sumar los totales
          Map<String, Map<String, dynamic>> datosPorUsuario = {};
          for (var doc in snapshot.data!.docs) {
            String idUsuario = doc.id;
            Map<String, dynamic> pedidosUsuario =
                doc.data() as Map<String, dynamic>;
            for (var pedido in pedidosUsuario.values) {
              double totalPedido = pedido['total'];
              String nombreUsuario = pedido['nombreUsuario'];
              if (datosPorUsuario.containsKey(idUsuario)) {
                datosPorUsuario[idUsuario]!['total'] += totalPedido;
              } else {
                datosPorUsuario[idUsuario] = {
                  'nombre': nombreUsuario,
                  'total': totalPedido
                };
              }
            }
          }

          return ListView.builder(
            itemCount: datosPorUsuario.length,
            itemBuilder: (context, index) {
              var entry = datosPorUsuario.entries.elementAt(index);
              return UsuariosCard(
                  entry.key, entry.value['nombre'], entry.value['total']);
            },
          );
        },
      ),
    );
  }
}
