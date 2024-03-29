//TODO: MANDARLO A TODO A PEDIDOS, YA ESTA EL JSON, MANDARLO A FIRESTORE Y CON SU ESTATUS.

// ignore_for_file: must_be_immutable, library_private_types_in_public_api, use_build_context_synchronously

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hyzar/estilos/Colores.dart';
import 'package:hyzar/pantallas/navigator_user/pedidos/pedido_ubicacion.dart';
import 'package:hyzar/utilidades/backend/user_notifier.dart';
import 'package:hyzar/utilidades/widgets/ModalDialog.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

class PantallaPedidosConfirm extends StatefulWidget {
  List<DocumentSnapshot> documentos;

  PantallaPedidosConfirm({super.key, required this.documentos});

  @override
  _PantallaPedidosConfirmState createState() => _PantallaPedidosConfirmState();
}

class _PantallaPedidosConfirmState extends State<PantallaPedidosConfirm> {
  final ScrollController _scrollController = ScrollController();
  String? formaPago;
  List<int> contador = [];
  TextEditingController fechaPedidoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    contador = List<int>.filled(widget.documentos.length, 1);
  }

  @override
  Widget build(BuildContext context) {
    final formasPago = ['Efectivo', 'Transferencia SPEI', 'TDC/TDD'];
    double total = 0;
    for (int i = 0; i < widget.documentos.length; i++) {
      final doc = widget.documentos[i];
      final data = doc.data() as Map<String, dynamic>;
      total += data['precio_farm'] * contador[i];
    }
    ;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear pedido',
          style: TextStyle(
            color: Colores.verde,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: widget.documentos.length + 1,
                  itemBuilder: (context, index) {
                    if (index < widget.documentos.length) {
                      final doc = widget.documentos[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return Column(children: [
                        ListTile(
                          leading: data['imagen'] != null &&
                                  data['imagen'].isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      25), // Ajusta el radio del borde redondeado aquí
                                  child: Image.network(
                                    data['imagen'],
                                    width: 50, // Ancho de la imagen
                                    height: 50, // Altura de la imagen
                                    fit: BoxFit
                                        .cover, // Para mantener la relación de aspecto de la imagen
                                  ),
                                )
                              : const Icon(Icons.warning, color: Colors.red),
                          title: Text(data['nombre']),
                          subtitle: Text('Precio: ${data['precio_farm']} MXN'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    contador[index]--;
                                    if (contador[index] == 0) {
                                      // Convierte las listas a listas de longitud variable si aún no lo son
                                      widget.documentos =
                                          List.from(widget.documentos);
                                      contador = List.from(contador);

                                      // Ahora puedes eliminar elementos de las listas
                                      widget.documentos.removeAt(index);
                                      contador.removeAt(index);
                                    }
                                  });
                                },
                              ),
                              Text('${contador[index]}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: contador[index] < data['existencias']
                                    ? () => setState(() => contador[index]++)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ]);
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colores.verde,
                                borderRadius: BorderRadius.circular(
                                    10), // Ajusta el radio del borde redondeado aquí
                              ),
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                '$total pesos',
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.white),
                              ),
                            ),
                            SizedBox(height: 30),
                            const Text(
                              '¿Cuándo se hizo el pedido?',
                              style: TextStyle(
                                  color: Colores.gris,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20),
                            DateTimeField(
                              format: DateFormat("yyyy-MM-dd HH:mm"),
                              initialValue: DateTime.now(),
                              decoration: const InputDecoration(
                                labelText: 'Fecha de pedido',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            20))), // Agrega esta línea
                              ),
                              enabled: false,
                              resetIcon: null,
                              onShowPicker: (context, currentValue) async {
                                final date = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1900),
                                    initialDate: currentValue ?? DateTime.now(),
                                    lastDate: DateTime(2100));
                                if (date != null) {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                        currentValue ?? DateTime.now()),
                                  );
                                  return DateTimeField.combine(date, time);
                                } else {
                                  return currentValue;
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              '¿Cuándo necesitarás el pedido?',
                              style: TextStyle(
                                  color: Colores.gris,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            DateTimeField(
                              controller: fechaPedidoController,
                              format: DateFormat("yyyy-MM-dd HH:mm"),
                              decoration: const InputDecoration(
                                labelText: 'Fecha de orden',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          20.0)), // Agrega esta línea
                                ),
                              ),
                              onShowPicker: (context, currentValue) async {
                                final date = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime.now(),
                                    initialDate: currentValue ?? DateTime.now(),
                                    lastDate: DateTime(2100));
                                if (date != null) {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(
                                        currentValue ?? DateTime.now()),
                                  );
                                  return DateTimeField.combine(date, time);
                                } else {
                                  return currentValue;
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Selecciona tu forma de pago',
                              style: TextStyle(
                                  color: Colores.gris,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            DropdownButtonFormField<String>(
                              value: formaPago,
                              hint: const Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Selecciona una forma de pago'),
                              ),
                              items: formasPago.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Row(
                                    children: <Widget>[
                                      // Agrega un icono basado en el valor
                                      if (value == 'Transferencia SPEI')
                                        Icon(Icons.transfer_within_a_station),
                                      if (value == 'Efectivo')
                                        Icon(Icons.money),
                                      if (value == 'TDC/TDD')
                                        Icon(Icons.credit_card),
                                      SizedBox(
                                          width:
                                              10), // Agrega un espacio entre el icono y el texto
                                      Text(value),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  formaPago = newValue;
                                });
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0)),
                                ),
                              ), // Agrega esta línea
                            ),
                            const SizedBox(height: 60),
                            ElevatedButton(
                              onPressed: () {
                                if (fechaPedidoController.text.isEmpty ||
                                    formaPago == null) {
                                  MessageDialog(context,
                                      title: "Alerta",
                                      description:
                                          "Llena todos los campos antes de continuar",
                                      buttonText: "ACEPTAR", onReadMore: () {
                                    Navigator.pop(context);
                                  }, showCloseButton: false);
                                } else {
                                  final nombreUsuario =
                                      Provider.of<UserNotifier>(context,
                                              listen: false)
                                          .getNombre();
                                  Map<String, dynamic> productos = {
                                    for (int index = 0;
                                        index < widget.documentos.length;
                                        index++)
                                      widget.documentos[index].id: {
                                        'cantidad': contador[index],
                                        'nombre': (widget.documentos[index]
                                                .data()
                                            as Map<String, dynamic>)['nombre'],
                                      }
                                  };
                                  Map<String, dynamic> detallesPedido = {
                                    'productos': productos,
                                    'fechaActual':
                                        DateFormat("yyyy-MM-dd HH:mm")
                                            .format(DateTime.now()),
                                    'fechaPedido': fechaPedidoController.text,
                                  };
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DireccionScreen(
                                        pedido: detallesPedido,
                                        formaPago: formaPago!,
                                        total: total,
                                        nombreUsuario: nombreUsuario,
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colores.verde,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.only(
                                    right: 20, left: 20, top: 10, bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text('Siguiente',
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              )
            ],
          )),
    );
  }
}
