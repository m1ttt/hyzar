import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaAgregar extends StatefulWidget {
  @override
  _PantallaAgregarState createState() => _PantallaAgregarState();
}

class _PantallaAgregarState extends State<PantallaAgregar> {
  bool ordenarPorNombre = true;
  String bc_code_result = "";
  Map<String, dynamic> medicamentoData = {};

  final codigoController = TextEditingController();
  final existenciasController = TextEditingController();
  final nombreController = TextEditingController();
  final precioFarmController = TextEditingController();
  final precioPubController = TextEditingController();

  String capitalize(String s) =>
      s[0].toUpperCase() + s.substring(1).toLowerCase();

  Future<void> agregarMedicamento(
      String codigo, Map<String, dynamic> datos) async {
    await FirebaseFirestore.instance
        .collection('medicamentos')
        .doc(codigo)
        .set(datos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(
                      255, 0, 105, 243), // background color
                  onPrimary: Colors.white, // foreground color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () async {
                  var res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SimpleBarcodeScannerPage(),
                      ));
                  if (res is String) {
                    codigoController.text = res;
                  }
                },
                child: const Text(
                  'Escanear Código',
                ),
              ),
              Card(
                child: TextField(
                  controller: codigoController,
                  decoration: InputDecoration(
                    labelText: 'Código',
                  ),
                ),
              ),
              Card(
                child: TextField(
                  controller: existenciasController,
                  decoration: InputDecoration(
                    labelText: 'Existencias',
                  ),
                ),
              ),
              Card(
                child: TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                  ),
                ),
              ),
              Card(
                child: TextField(
                  controller: precioFarmController,
                  decoration: InputDecoration(
                    labelText: 'Precio Farmacia',
                  ),
                ),
              ),
              Card(
                child: TextField(
                  controller: precioPubController,
                  decoration: InputDecoration(
                    labelText: 'Precio Público',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Map<String, dynamic> datosMedicamento = {
                    'nombre': capitalize(nombreController.text),
                    'existencias': int.parse(existenciasController.text),
                    'precio_farm': double.parse(precioFarmController.text),
                    'precio_pub': double.parse(precioPubController.text),
                    'eliminado': 0,
                  };
                  await agregarMedicamento(
                      codigoController.text, datosMedicamento);

                  // Vaciar los campos
                  codigoController.clear();
                  existenciasController.clear();
                  nombreController.clear();
                  precioFarmController.clear();
                  precioPubController.clear();

                  // Mostrar un mensaje
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Medicamento subido con éxito'),
                    ),
                  );
                },
                child: const Text(
                  'Subir',
                ),
              ),
            ],
          )),
    );
  }
}
