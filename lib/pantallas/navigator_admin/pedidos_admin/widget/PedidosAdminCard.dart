import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyzar/pantallas/navigator/pdfscreen/funciones/generarpdf.dart';

import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../navigator/pdfscreen/pdfscreen.dart';

class PedidosAdminCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String idUsuario;

  PedidosAdminCard({required this.data, required this.idUsuario});

  @override
  _PedidosAdminCardState createState() => _PedidosAdminCardState();
}

class _PedidosAdminCardState extends State<PedidosAdminCard> {
  String? estadoSeleccionado;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.data.entries.map((entry) {
        String pedidoID = entry.key;
        Map<String, dynamic> detallesPedido = entry.value;
        Map<String, dynamic> detallesProductos =
            detallesPedido['detalles_productos'];
        Map<String, dynamic> direccionPedido =
            detallesPedido['direccion_pedido'];
        bool pagado = detallesPedido['pagado'];
        String estado = detallesPedido['estado'];
        String nombreUsuario = detallesPedido['nombreUsuario'];
        String idUsuario = widget.idUsuario;

        estadoSeleccionado = estado;

        return Card(
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID Usuario: ${widget.idUsuario}',
                        style:
                            TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Nombre: $nombreUsuario',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: <Widget>[
                      Text('Estado: '),
                      DropdownButton<String>(
                        value: estadoSeleccionado,
                        items: <String>[
                          'pendiente',
                          'entregado',
                          'en transporte'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            estadoSeleccionado = newValue;
                            FirebaseFirestore.instance
                                .collection('pedidos')
                                .doc(widget.idUsuario)
                                .update(
                                    {'$pedidoID.estado': estadoSeleccionado});
                          });
                        },
                      ),
                    ],
                  ),
                  trailing: InkWell(
                    onTap: () async {
                      await FirebaseFirestore.instance
                          .collection('pedidos')
                          .doc(idUsuario)
                          .update({'$pedidoID.pagado': !pagado});
                    },
                    child: Icon(
                      pagado ? Icons.check_circle : Icons.cancel,
                      color: pagado ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    'ID Pedido: $pedidoID',
                  ),
                ),
                Divider(),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: InputChip(
                          avatar: Icon(Icons.shopping_cart),
                          label: Text('Productos'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    title: Text('Productos adquiridos'),
                                    content: Column(
                                      children: detallesProductos['productos']
                                          .entries
                                          .map<Widget>((producto) {
                                        return ListTile(
                                          title: Text(
                                              'Producto: ${producto.value['nombre']}'),
                                          trailing: Text(
                                              'Cantidad: ${producto.value['cantidad']}'),
                                        );
                                      }).toList(),
                                    ));
                              },
                            );
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: InputChip(
                          avatar: Icon(Icons.print),
                          label: Text('Imprimir PDF'),
                          onPressed: () {
                            PdfUtils.generarPDF(
                                detallesPedido, pedidoID, context);
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: InputChip(
                          avatar: Icon(Icons.location_on),
                          label: Text('Dirección'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Dirección de entrega'),
                                  content: Text(
                                      '${detallesPedido['direccion_pedido']['calle']}, ${detallesPedido['direccion_pedido']['ciudad']}, ${detallesPedido['direccion_pedido']['colonia']}, ${detallesPedido['direccion_pedido']['numero']}, ${detallesPedido['direccion_pedido']['zip_code']}'),
                                  actions: [
                                    TextButton(
                                      child: Text('Abrir en Google Maps'),
                                      onPressed: () async {
                                        final url =
                                            'https://www.google.com/maps/search/?api=1&query=${detallesPedido['direccion_pedido']['calle']}, ${detallesPedido['direccion_pedido']['ciudad']}, ${detallesPedido['direccion_pedido']['colonia']}, ${detallesPedido['direccion_pedido']['numero']}, ${detallesPedido['direccion_pedido']['zip_code']}';
                                        if (await canLaunch(url)) {
                                          await launch(url);
                                        } else {
                                          throw 'No se pudo abrir $url';
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: InputChip(
                          avatar: Icon(Icons.receipt),
                          label: Text('Facturación'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Facturación'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                          'Método de pago: ${detallesPedido['forma_pago']}'),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  title:
                      Text('Fecha Actual: ${detallesProductos['fechaActual']}'),
                  trailing: Text(
                      'Fecha del Pedido: ${detallesProductos['fechaPedido']}'),
                ),
                Divider(),
                ListTile(
                  title: Text('Total: ${detallesPedido['total']}\$'),
                ),
                ElevatedButton(
                  child: Text('Cancelar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // background color
                    foregroundColor: Colors.white, // foreground color
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirmación'),
                          content: Text('¿Seguro que quieres cancelar?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Sí'),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('pedidos')
                                    .doc(idUsuario)
                                    .update({
                                  '$pedidoID': FieldValue.delete(),
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('No'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
