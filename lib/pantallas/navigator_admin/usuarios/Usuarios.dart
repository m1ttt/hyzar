import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'widget/UsuariosCard.dart';

enum EstadoFiltro { todos, deudores }

class UsuariosAdmin extends StatefulWidget {
  @override
  _UsuariosAdminState createState() => _UsuariosAdminState();
}

class _UsuariosAdminState extends State<UsuariosAdmin> {
  EstadoFiltro estadoFiltro = EstadoFiltro.todos;
  Future<Map<String, Map<String, dynamic>>> agruparPedidos() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('pedidos').get();
    Map<String, Map<String, dynamic>> datosPorUsuario = {};
    for (var doc in snapshot.docs) {
      String idUsuario = doc.id;
      Map<String, dynamic> pedidosUsuario = doc.data() as Map<String, dynamic>;
      for (var pedido in pedidosUsuario.values) {
        double totalPedido = pedido['total'];
        String nombreUsuario = pedido['nombreUsuario'];
        if (datosPorUsuario.containsKey(idUsuario)) {
          datosPorUsuario[idUsuario]!['total'] += totalPedido;
        } else {
          DatabaseReference ref = FirebaseDatabase.instance
              .ref()
              .child('usuarios')
              .child(idUsuario);
          DataSnapshot dataSnapshot = await ref.get();
          Map<String, dynamic> data = Map<String, dynamic>.from(
              dataSnapshot.value as Map<dynamic, dynamic>);
          datosPorUsuario[idUsuario] = {
            'nombre': data['nombre'],
            'total': totalPedido,
            'correo': data['correo'],
            'telefono': data['telefono'],
          };
        }
      }
    }
    return datosPorUsuario;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, Map<String, dynamic>>>(
        future: agruparPedidos(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Text('Algo salió mal');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Cargando");
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var entry = snapshot.data!.entries.elementAt(index);
              if (estadoFiltro == EstadoFiltro.deudores &&
                  (entry.value['total'] == null || entry.value['total'] <= 0)) {
                return Container(); // No mostrar usuarios que no deben
              }
              return UsuariosCard(
                  entry.key,
                  entry.value['nombre'],
                  entry.value['total'],
                  entry.value['correo'],
                  entry.value['telefono']);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            estadoFiltro = estadoFiltro == EstadoFiltro.todos
                ? EstadoFiltro.deudores
                : EstadoFiltro.todos;
          });
        },
        label: Text(estadoFiltro == EstadoFiltro.todos
            ? 'Mostrar solo deudores'
            : 'Mostrar todos'),
        icon: Icon(Icons.filter_list),
      ),
    );
  }
}
