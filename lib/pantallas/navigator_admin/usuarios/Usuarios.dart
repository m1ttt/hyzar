import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'widget/UsuariosCard.dart';

enum EstadoFiltro { firestore, realtime }

class UsuariosAdmin extends StatefulWidget {
  @override
  _UsuariosAdminState createState() => _UsuariosAdminState();
}

class _UsuariosAdminState extends State<UsuariosAdmin> {
  EstadoFiltro estadoFiltro = EstadoFiltro.firestore;

  Future<Map<String, Map<String, dynamic>>> obtenerDatos() async {
    Map<String, Map<String, dynamic>> datosPorUsuario = {};

    if (estadoFiltro == EstadoFiltro.firestore) {
      // Lógica para obtener datos de Firestore
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('pedidos').get();
      for (var doc in snapshot.docs) {
        String idUsuario = doc.id;
        Map<String, dynamic> pedidosUsuario =
            doc.data() as Map<String, dynamic>;
        for (var pedido in pedidosUsuario.values) {
          double totalPedido = pedido['total'];
          if (datosPorUsuario.containsKey(idUsuario)) {
            if (datosPorUsuario[idUsuario] != null) {
              datosPorUsuario[idUsuario]!['total'] += totalPedido;
            }
          } else {
            datosPorUsuario[idUsuario] = {
              'nombre': pedido[
                  'nombreUsuario'], // Asumiendo que el nombre del usuario está en el pedido
              'total': totalPedido,
              'correo': '', // Asumiendo que el correo no está disponible aquí
              'telefono':
                  '', // Asumiendo que el teléfono no está disponible aquí
            };
          }
        }
      }
    } else if (estadoFiltro == EstadoFiltro.realtime) {
      // Lógica para obtener datos de Realtime Database
      DatabaseReference ref = FirebaseDatabase.instance.ref().child('usuarios');
      DataSnapshot dataSnapshot = await ref.get();
      if (dataSnapshot.exists) {
        Map<dynamic, dynamic> users =
            dataSnapshot.value as Map<dynamic, dynamic>;
        users.forEach((key, value) {
          datosPorUsuario[key] = Map<String, dynamic>.from(value);
        });
      }
    }

    // Si estadoFiltro es 'todos', no se hace ninguna acción específica aquí

    return datosPorUsuario;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, Map<String, dynamic>>>(
        future: obtenerDatos(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Text('Algo salió mal: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Text('No hay datos disponibles');
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var entry = snapshot.data!.entries.elementAt(index);
              return UsuariosCard(
                  entry.key,
                  entry.value['nombre'],
                  entry.value['total'] ?? 0.0,
                  entry.value['correo'],
                  entry.value['telefono']);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            estadoFiltro = estadoFiltro == EstadoFiltro.firestore
                ? EstadoFiltro.realtime
                : EstadoFiltro.firestore;
          });
        },
        label: Text(estadoFiltro == EstadoFiltro.firestore
            ? 'Todos los usuarios'
            : 'Deudores'),
        icon: Icon(Icons.swap_horiz),
      ),
    );
  }
}
