import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyzar/pantallas/navigator/pdfscreen/funciones/generarpdf.dart';
import 'package:url_launcher/url_launcher.dart';

class PedidoCard extends StatefulWidget {
  final Map<String, dynamic> detallesPedido;
  final String pedidoID;
  final String userID;

  const PedidoCard(
      {Key? key,
      required this.detallesPedido,
      required this.pedidoID,
      required this.userID})
      : super(key: key);

  @override
  _PedidoCardState createState() => _PedidoCardState();
}

class _PedidoCardState extends State<PedidoCard> {
  bool filtrarPagado = false;
  late Map<String, dynamic> detallesPedido;
  late String pedidoID;
  late String userID;

  @override
  void initState() {
    super.initState();
    detallesPedido = widget.detallesPedido;
    pedidoID = widget.pedidoID;
    userID = widget.userID;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> detallesProductos =
        detallesPedido['detalles_productos'];
    bool pagado = detallesPedido['pagado'];
    String estado = detallesPedido['estado'];
    if (filtrarPagado && !pagado) {
      return Container();
    }
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Pedido ID: $pedidoID',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              subtitle: Row(
                children: <Widget>[
                  Text('Estado: '),
                  Chip(
                    label: Text(
                      '$estado',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                ],
              ),
              trailing: Icon(
                pagado ? Icons.check_circle : Icons.cancel,
                color: pagado ? Colors.green : Colors.red,
              ),
            ),

            Divider(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  InputChip(
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
                            ),
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(width: 10),
                  InputChip(
                    avatar: Icon(Icons.print),
                    label: Text('Imprimir PDF'),
                    onPressed: () async {
                      PdfUtils.generarPDF(detallesPedido, pedidoID, context);
                    },
                  ),
                  SizedBox(width: 10),
                  InputChip(
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
                  SizedBox(width: 10),
                  InputChip(
                    avatar: Icon(Icons.receipt),
                    label: Text('Facturación'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Método de pago'),
                            content: Text(
                                'Método de pago: ${detallesPedido['forma_pago']}'),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
// ...
            Divider(),
            ListTile(
              title: Text('Total: ${detallesPedido['total']}'),
            ),

            if (!pagado)
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
                                  .doc(userID)
                                  .update({
                                pedidoID: FieldValue.delete(),
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
  }
}
