import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'widget/PedidosAdminCard.dart'; // Importa PedidosAdminCard.dart

class PedidosAdmin extends StatelessWidget {
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

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              print(data);
              return PedidosAdminCard(
                  data: data,
                  idUsuario:
                      document.id); // Pasa document.id a PedidosAdminCard
            }).toList(),
          );
        },
      ),
    );
  }
}
