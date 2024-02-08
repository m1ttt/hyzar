import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'widget/pedidos_admin_card.dart'; // Importa PedidosAdminCard.dart

class PedidosAdmin extends StatelessWidget {
  const PedidosAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pedidos').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Algo salió mal');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Cargando");
          }

          if (snapshot.data!.docs
              .every((doc) => (doc.data() as Map<String, dynamic>).isEmpty)) {
            print("No hay datos");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'lib/assets/Empty.svg',
                    height: 300,
                  ),
                  const SizedBox(height: 20), // Añade un espacio (20px
                  const Text(
                    'No hay pedidos creados',
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey,
                        fontWeight:
                            FontWeight.bold), // Ajusta el estilo como quieras
                  ),
                ],
              ),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              print("Creando ListView"); // Agrega esta línea
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
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
