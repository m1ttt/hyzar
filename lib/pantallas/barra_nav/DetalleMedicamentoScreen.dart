import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetalleMedicamentoScreen extends StatefulWidget {
  final Map<String, dynamic> medicamento;

  DetalleMedicamentoScreen({required this.medicamento});

  @override
  _DetalleMedicamentoScreenState createState() =>
      _DetalleMedicamentoScreenState();
}

class _DetalleMedicamentoScreenState extends State<DetalleMedicamentoScreen> {
  bool mostrarDropdown = false;
  int eliminado = 0;
  late TextEditingController nombreController;
  late TextEditingController descripcionController;
  late TextEditingController existenciasController;
  late TextEditingController precioFarmController;
  late TextEditingController precioPubController;
  bool editing = false;

  String capitalize(String s) =>
      s[0].toUpperCase() + s.substring(1).toLowerCase();

  @override
  void initState() {
    super.initState();
    nombreController =
        TextEditingController(text: widget.medicamento['nombre']);
    descripcionController =
        TextEditingController(text: widget.medicamento['descripcion']);
    existenciasController = TextEditingController(
        text: widget.medicamento['existencias'].toString());
    precioFarmController = TextEditingController(
        text: widget.medicamento['precio_farm'].toString());
    precioPubController = TextEditingController(
        text: widget.medicamento['precio_pub'].toString());
    eliminado = widget.medicamento['eliminado'] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicamento['nombre']),
        actions: <Widget>[
          IconButton(
            icon: Icon(editing ? Icons.save : Icons.edit),
            onPressed: () async {
              if (editing) {
                try {
                  await FirebaseFirestore.instance
                      .collection('medicamentos')
                      .doc(widget.medicamento['id'])
                      .update({
                    'nombre': nombreController.text,
                    'descripcion': descripcionController.text,
                    'existencias': int.parse(existenciasController.text),
                    'precio_farm': double.parse(precioFarmController.text),
                    'precio_pub': double.parse(precioPubController.text),
                    'eliminado': eliminado, // Agrega esta línea
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Datos actualizados correctamente")),
                  );
                } catch (e) {
                  print('Error al actualizar los datos: $e');
                }
              }
              setState(() {
                editing = !editing;
                mostrarDropdown = !mostrarDropdown;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('medicamentos')
            .doc(widget.medicamento['id'])
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Cargando');
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  child: ListTile(
                    leading: Icon(Icons.medication),
                    title: editing
                        ? TextField(controller: nombreController)
                        : Text(
                            '${data['nombre']}',
                            style: TextStyle(fontSize: 24),
                          ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.description),
                    title: editing
                        ? TextField(controller: descripcionController)
                        : Text(
                            '${data['descripcion']}',
                            style: TextStyle(fontSize: 24),
                          ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.inventory),
                    title: editing
                        ? TextField(controller: existenciasController)
                        : Text(
                            'Existencias: ${data['existencias']}',
                            style: TextStyle(fontSize: 20),
                          ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.money),
                    title: editing
                        ? TextField(controller: precioFarmController)
                        : Text(
                            'Precio Farmacia: ${data['precio_farm']}',
                            style: TextStyle(fontSize: 20),
                          ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.money),
                    title: editing
                        ? TextField(controller: precioPubController)
                        : Text(
                            'Precio Público: ${data['precio_pub']}',
                            style: TextStyle(fontSize: 20),
                          ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.delete_forever),
                    title: editing
                        ? DropdownButton<int>(
                            value: eliminado,
                            items: [
                              DropdownMenuItem(
                                child: Text('No'),
                                value: 0,
                              ),
                              DropdownMenuItem(
                                child: Text('Sí'),
                                value: 1,
                              ),
                            ],
                            onChanged: (int? newValue) {
                              setState(() {
                                eliminado = newValue!;
                              });
                            },
                          )
                        : Text(
                            'Suspendido: ${data['eliminado'] == 1 ? 'Sí' : 'No'}',
                            style: TextStyle(fontSize: 20),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
