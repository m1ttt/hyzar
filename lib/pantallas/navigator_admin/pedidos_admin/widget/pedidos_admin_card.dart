// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyzar/pantallas/navigator/pdfscreen/funciones/generarpdf.dart';
import 'package:hyzar/utilidades/widgets/ModalDialog.dart';
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

Future<bool> actualizarExistencias(
    Map<String, dynamic> detallesPedido, BuildContext context) async {
  Map<String, dynamic> detallesProductos = detallesPedido['detalles_productos'];
  Map<String, dynamic> productos = detallesProductos['productos'];
  for (var entry in productos.entries) {
    String key = entry.key;
    dynamic value = entry.value;
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('medicamentos')
        .doc(key)
        .get();
    int existencias = doc.get('existencias');
    if (existencias < value['cantidad']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('No hay suficientes existencias para el producto $key')));
      return false;
    }
    await FirebaseFirestore.instance
        .collection('medicamentos')
        .doc(key)
        .update({'existencias': FieldValue.increment(-value['cantidad'])});
  }
  return true;
}

void incrementarExistencias(Map<String, dynamic> detallesPedido) async {
  Map<String, dynamic> detallesProductos = detallesPedido['detalles_productos'];
  Map<String, dynamic> productos = detallesProductos['productos'];
  for (var entry in productos.entries) {
    String key = entry.key;
    dynamic value = entry.value;
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('medicamentos')
        .doc(key)
        .get();
    if (!doc.exists) {
      continue;
    }
    int existencias = doc.get('existencias');
    if (existencias == 0) {
      continue;
    }
    await FirebaseFirestore.instance
        .collection('medicamentos')
        .doc(key)
        .update({'existencias': FieldValue.increment(value['cantidad'])});
  }
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
                        if (pagado) {
                          incrementarExistencias(detallesPedido);
                          await FirebaseFirestore.instance
                              .collection('pedidos')
                              .doc(idUsuario)
                              .update({'$pedidoID.pagado': !pagado});
                        } else {
                          bool success = await actualizarExistencias(
                              detallesPedido, context);
                          if (success) {
                            // Solo marcar como pagado si actualizarExistencias fue exitoso
                            await FirebaseFirestore.instance
                                .collection('pedidos')
                                .doc(idUsuario)
                                .update({'$pedidoID.pagado': !pagado});

                            // Obtener el total del pedido
                            DocumentSnapshot pedidoDoc = await FirebaseFirestore
                                .instance
                                .collection('pedidos')
                                .doc(idUsuario)
                                .get();
                            double totalPedido =
                                (pedidoDoc.get('$pedidoID.total') as num)
                                    .toDouble();

                            // Restar el total del pedido del total en la colección de pedidos
                            double totalPedidos =
                                (pedidoDoc.get('$pedidoID.total') as num)
                                    .toDouble();
                            await FirebaseFirestore.instance
                                .collection('pedidos')
                                .doc(idUsuario)
                                .update({
                              '$pedidoID.total': totalPedidos - totalPedido
                            });
                          } else {
                            // Si actualizarExistencias devolvió false, no hacer nada más
                            return;
                          }
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
                          avatar: Icon(
                            Icons.shopping_cart,
                            color: Theme.of(context).iconTheme.color,
                          ),
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
                          avatar: Icon(
                            Icons.print,
                            color: Theme.of(context).iconTheme.color,
                          ),
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
                          avatar: Icon(
                            Icons.location_on,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          label: const Text('Dirección'),
                          onPressed: () {
                            MessageDialog(context,
                                title: "Dirección de entrega",
                                description:
                                    '${detallesPedido['direccion_pedido']['calle']}, ${detallesPedido['direccion_pedido']['ciudad']}, ${detallesPedido['direccion_pedido']['colonia']}, ${detallesPedido['direccion_pedido']['numero']}, ${detallesPedido['direccion_pedido']['zip_code']}',
                                buttonText: "ABRIR EN GOOGLE MAPS",
                                onReadMore: () async {
                              final url =
                                  'https://www.google.com/maps/search/?api=1&query=${detallesPedido['direccion_pedido']['calle']}, ${detallesPedido['direccion_pedido']['ciudad']}, ${detallesPedido['direccion_pedido']['colonia']}, ${detallesPedido['direccion_pedido']['numero']}, ${detallesPedido['direccion_pedido']['zip_code']}';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'No se pudo abrir $url';
                              }
                            }, showCloseButton: false);
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: InputChip(
                          avatar: Icon(
                            Icons.receipt,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          label: const Text('Facturación'),
                          onPressed: () {
                            MessageDialog(context,
                                title: "Método de pago",
                                description:
                                    'Método de pago: ${detallesPedido['forma_pago']}',
                                buttonText: 'ACEPTAR',
                                onReadMore: () {},
                                showCloseButton: false);
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
                  title: Text(detallesPedido['total'] == 0
                      ? 'Total: (pagado)'
                      : 'Total: ${detallesPedido['total']}\$'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // background color
                    foregroundColor: Colors.white, // foreground color
                  ),
                  onPressed: () {
                    MessageDialog(context,
                        title: "Alerta",
                        description: detallesPedido["total"] == 0
                            ? "¿Estás seguro de querer eliminar el registro?\n NO SE PODRA RECUPERAR"
                            : "¿Estás seguro de querer cancelar?",
                        buttonText: "CANCELAR", onReadMore: () async {
                      FirebaseFirestore.instance
                          .collection('pedidos')
                          .doc(idUsuario)
                          .update({
                        pedidoID: FieldValue.delete(),
                      });
                      Navigator.of(context).pop();
                    }, buttonCancelText: "NO");
                  },
                  child: Text(detallesPedido['total'] == 0
                      ? 'Eliminar registro'
                      : 'Cancelar'),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
