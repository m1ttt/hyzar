// ignore_for_file: deprecated_member_use, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyzar/estilos/Colores.dart';
import 'package:hyzar/pantallas/navigator/pdfscreen/funciones/generarpdf.dart';
import 'package:hyzar/utilidades/widgets/ModalDialog.dart';
import 'package:url_launcher/url_launcher.dart';

class PedidoCard extends StatefulWidget {
  final Map<String, dynamic> detallesPedido;
  final String pedidoID;
  final String userID;

  const PedidoCard(
      {super.key,
      required this.detallesPedido,
      required this.pedidoID,
      required this.userID});

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
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Pedido ID: $pedidoID',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
              subtitle: Row(
                children: <Widget>[
                  const Text('Estado: '),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colores.verde,
                      borderRadius: BorderRadius.circular(
                          10), // Ajusta el radio del borde redondeado aquí
                    ),
                    child: Text(
                      estado,
                      style:
                          TextStyle(color: Theme.of(context).backgroundColor),
                    ),
                  ),
                ],
              ),
              trailing: Icon(
                pagado ? Icons.check_circle : Icons.cancel,
                color: pagado ? Colors.green : Colors.red,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  InputChip(
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
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  InputChip(
                    avatar: Icon(Icons.print,
                        color: Theme.of(context).iconTheme.color),
                    label: const Text('Imprimir PDF'),
                    onPressed: () async {
                      PdfUtils.generarPDF(detallesPedido, pedidoID, context);
                    },
                  ),
                  const SizedBox(width: 10),
                  InputChip(
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
                  const SizedBox(width: 10),
                  InputChip(
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
                ],
              ),
            ),
            const Divider(color: Colores.gris),
            ListTile(
              leading: const Icon(Icons.attach_money), // Icono de dinero
              title: Text('${detallesPedido['total']}'),
            ),
            if (!pagado)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colores.azul, // background color
                  foregroundColor: Colors.white, // foreground color
                ),
                onPressed: () {
                  MessageDialog(context,
                      title: "Confirmación",
                      description:
                          "¿Estas seguro que deseas cancelar el pedido?",
                      buttonText: "CANCELAR", onReadMore: () async {
                    FirebaseFirestore.instance
                        .collection('pedidos')
                        .doc(userID)
                        .update({
                      pedidoID: FieldValue.delete(),
                    });
                    Navigator.pop(context);
                  }, buttonCancelText: "NO");
                },
                child: const Text('Cancelar'),
              ),
          ],
        ),
      ),
    );
  }
}
