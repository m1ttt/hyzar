import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PedidoCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    Map<String, dynamic> detallesProductos =
        detallesPedido['detalles_productos'];
    Map<String, dynamic> direccionPedido = detallesPedido['direccion_pedido'];
    bool pagado = detallesPedido['pagado'];
    String estado = detallesPedido['estado'];
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Pedido ID: $pedidoID',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            ...detallesProductos['productos'].entries.map((producto) {
              return ListTile(
                title: Text('Producto: ${producto.value['nombre']}'),
                trailing: Text('Cantidad: ${producto.value['cantidad']}'),
              );
            }),
            Divider(),
            ListTile(
              title: Text('Fecha Actual: ${detallesProductos['fechaActual']}'),
              trailing:
                  Text('Fecha del Pedido: ${detallesProductos['fechaPedido']}'),
            ),
            Divider(),
            ListTile(
              title: Text('Total: ${detallesPedido['total']}'),
            ),
            Divider(),
            ListTile(
              title: Row(
                children: <Widget>[
                  Text('Forma de pago: '),
                  Chip(
                    label: Text(
                      ' ${detallesPedido['forma_pago']}',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              title: Text(
                  'Dirección: ${direccionPedido['calle']}, ${direccionPedido['numero']}, ${direccionPedido['colonia']}, ${direccionPedido['ciudad']}, ${direccionPedido['zip_code']}'),
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
