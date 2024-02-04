import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'widget/UsuariosCard.dart';
import 'widget/UsuariosInfo.dart';

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
              'tipo': data['tipo']
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
    for (var entry in datosPorUsuario.entries) {
      String idUsuario = entry.key;
      File? imagen = await obtenerImagen(idUsuario);
      if (imagen != null) {
        datosPorUsuario[idUsuario]!['imagen'] = imagen;
      }
    }

    return datosPorUsuario;
    // Si estadoFiltro es 'todos', no se hace ninguna acción específica aquí
  }

  Future<File?> obtenerImagen(String idUsuario) async {
    try {
      final ref =
          FirebaseStorage.instance.ref().child('user_images/$idUsuario');
      final url = await ref.getDownloadURL();
      final response = await http.get(Uri.parse(url));
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$idUsuario');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } catch (e) {
      // Si ocurre un error (por ejemplo, la imagen no existe), devolvemos null
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, Map<String, dynamic>>>(
        future: obtenerDatos(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text('Algo salió mal: ${snapshot.error}');
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Text('No hay datos disponibles');
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var entry = snapshot.data!.entries.elementAt(index);
              ImageProvider<Object>? imagen;
              if (entry.value['imagen'] != null) {
                imagen = FileImage(entry.value['imagen']);
              } else {
                // Si la imagen es null, no podemos mostrar un icono con ImageProvider
                // En su lugar, puedes usar una imagen predeterminada o dejarla en null
                imagen = null;
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UsuariosInfo(
                        idUsuario: entry.key,
                        datosUsuario: entry.value,
                      ),
                    ),
                  );
                },
                child: UsuariosCard(
                  entry.key,
                  entry.value['nombre'],
                  entry.value['total'] ?? 0.0,
                  entry.value['correo'],
                  entry.value['telefono'],
                  imagen,
                ),
              );
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
