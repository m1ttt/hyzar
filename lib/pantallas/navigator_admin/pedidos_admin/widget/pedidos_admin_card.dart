// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyzar/pantallas/navigator/pdfscreen/funciones/generarpdf.dart';
import 'package:url_launcher/url_launcher.dart';

class PedidosAdminCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String idUsuario;

  const PedidosAdminCard(
      {super.key, required this.data, required this.idUsuario});

  @override
  // ignore: library_private_types_in_public_api
  _PedidosAdminCardState createState() => _PedidosAdminCardState();
}

void actualizarExistencias(Map<String, dynamic> detallesPedido) {
  Map<String, dynamic> detallesProductos = detallesPedido['detalles_productos'];
  Map<String, dynamic> productos = detallesProductos['productos'];
  productos.forEach((key, value) async {
    await FirebaseFirestore.instance
        .collection('medicamentos')
        .doc(key)
        .update({'existencias': FieldValue.increment(-value['cantidad'])});
  });
}

void incrementarExistencias(Map<String, dynamic> detallesPedido) {
  Map<String, dynamic> detallesProductos = detallesPedido['detalles_productos'];
  Map<String, dynamic> productos = detallesProductos['productos'];
  productos.forEach((key, value) async {
    await FirebaseFirestore.instance
        .collection('medicamentos')
        .doc(key)
        .update({'existencias': FieldValue.increment(value['cantidad'])});
  });
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
        bool pagado = detallesPedido['pagado'];
        String estado = detallesPedido['estado'];
        String nombreUsuario = detallesPedido['nombreUsuario'];
        String idUsuario = widget.idUsuario;

        estadoSeleccionado = estado;

        return Card(
          margin: const EdgeInsets.all(10),
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
                          style: const TextStyle(
                              fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Nombre: $nombreUsuario',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: <Widget>[
                        const Text('Estado: '),
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

                        if (pagado) {
                          incrementarExistencias(detallesPedido);
                        } else {
                          actualizarExistencias(detallesPedido);
                        }
                      },
                      child: Icon(
                        pagado ? Icons.check_circle : Icons.cancel,
                        color: pagado ? Colors.green : Colors.red,
                      ),
                    )),
                const Divider(),
                ListTile(
                  title: Text(
                    'ID Pedido: $pedidoID',
                  ),
                ),
                const Divider(),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: InputChip(
                          avatar: const Icon(Icons.shopping_cart),
                          label: const Text('Productos'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    title: const Text('Productos adquiridos'),
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
                          avatar: const Icon(Icons.print),
                          label: const Text('Imprimir PDF'),
                          onPressed: () {
                            PdfUtils.generarPDF(
                                detallesPedido, pedidoID, context);
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: InputChip(
                          avatar: const Icon(Icons.location_on),
                          label: const Text('Dirección'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Dirección de entrega'),
                                  content: Text(
                                      '${detallesPedido['direccion_pedido']['calle']}, ${detallesPedido['direccion_pedido']['ciudad']}, ${detallesPedido['direccion_pedido']['colonia']}, ${detallesPedido['direccion_pedido']['numero']}, ${detallesPedido['direccion_pedido']['zip_code']}'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Abrir en Google Maps'),
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
                          avatar: const Icon(Icons.receipt),
                          label: const Text('Facturación'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Facturación'),
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
                const Divider(),
                ListTile(
                  title:
                      Text('Fecha Actual: ${detallesProductos['fechaActual']}'),
                  trailing: Text(
                      'Fecha del Pedido: ${detallesProductos['fechaPedido']}'),
                ),
                const Divider(),
                ListTile(
                  title: Text('Total: ${detallesPedido['total']}\$'),
                ),
                ElevatedButton(
                  child: const Text('Cancelar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // background color
                    foregroundColor: Colors.white, // foreground color
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirmación'),
                          content: const Text('¿Seguro que quieres cancelar?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Sí'),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('pedidos')
                                    .doc(idUsuario)
                                    .update({
                                  pedidoID: FieldValue.delete(),
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('No'),
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
