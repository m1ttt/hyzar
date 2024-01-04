//TODO: MANDARLO A TODO A PEDIDOS, YA ESTA EL JSON, MANDARLO A FIRESTORE Y CON SU ESTATUS.

// ignore_for_file: must_be_immutable, library_private_types_in_public_api

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hyzar/pantallas/navigator_user/pedidos/pedido_ubicacion.dart';
import 'package:hyzar/utilidades/backend/user_notifier.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

class PantallaPedidosConfirm extends StatefulWidget {
  List<DocumentSnapshot> documentos;

  PantallaPedidosConfirm({super.key, required this.documentos});

  @override
  _PantallaPedidosConfirmState createState() => _PantallaPedidosConfirmState();
}

class _PantallaPedidosConfirmState extends State<PantallaPedidosConfirm> {
  ScrollController _scrollController = ScrollController();
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
        title: Text('Confirmar pedido'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: widget.documentos.length + 1,
          itemBuilder: (context, index) {
            if (index < widget.documentos.length) {
              final doc = widget.documentos[index];
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  leading: data['imagen'] != null && data['imagen'].isNotEmpty
                      ? Image.network(
                          data['imagen'],
                          width: 50, // Ancho de la imagen
                          height: 50, // Altura de la imagen
                          fit: BoxFit
                              .cover, // Para mantener la relación de aspecto de la imagen
                        )
                      : Icon(Icons.warning, color: Colors.red),
                  title: Text(data['nombre']),
                  subtitle: Text('Precio: ${data['precio_farm']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            contador[index]--;
                            if (contador[index] == 0) {
                              // Convierte las listas a listas de longitud variable si aún no lo son
                              widget.documentos = List.from(widget.documentos);
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
                        icon: Icon(Icons.add),
                        onPressed: contador[index] < data['existencias']
                            ? () => setState(() => contador[index]++)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Chip(
                      label: Text('$total pesos',
                          style: TextStyle(fontSize: 15, color: Colors.white)),
                      backgroundColor: Colors.blue,
                      labelPadding: EdgeInsets.all(2.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    DateTimeField(
                      format: DateFormat("yyyy-MM-dd HH:mm"),
                      initialValue: DateTime.now(),
                      decoration: InputDecoration(
                        labelText: 'Fecha actual',
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
                    DateTimeField(
                      controller: fechaPedidoController,
                      format: DateFormat("yyyy-MM-dd HH:mm"),
                      decoration: InputDecoration(
                        labelText: 'Fecha en la que se necesita el pedido',
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
                    DropdownButton<String>(
                      value: formaPago,
                      hint: Text('Selecciona una forma de pago'),
                      items: formasPago.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          formaPago = newValue;
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Obtén el userId del UserNotifier

                        final nombreUsuario =
                            Provider.of<UserNotifier>(context, listen: false)
                                .getNombre();

                        Map<String, dynamic> productos = {
                          for (int index = 0;
                              index < widget.documentos.length;
                              index++)
                            widget.documentos[index].id: {
                              'cantidad': contador[index],
                              'nombre': (widget.documentos[index].data()
                                  as Map<String, dynamic>)['nombre'],
                            }
                        };

                        Map<String, dynamic> detallesPedido = {
                          'productos': productos,
                          'fechaActual': DateFormat("yyyy-MM-dd HH:mm")
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
                      },
                      child: Text('Confirmar pedido'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
