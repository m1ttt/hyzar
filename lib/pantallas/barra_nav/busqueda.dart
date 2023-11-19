import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'DetalleMedicamentoScreen.dart';

class PantallaBusqueda extends StatefulWidget {
  @override
  _PantallaBusquedaState createState() => _PantallaBusquedaState();
}

class _PantallaBusquedaState extends State<PantallaBusqueda> {
  String bc_code_result = "";
  List<Map<String, dynamic>> medicamentosEscaneados = [];
  Future<void> obtenerDatosMedicamento(String codigo) async {
    if (codigo == "-1") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sin nada por escanear'),
        ),
      );
      return;
    }

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('medicamentos')
          .doc(codigo)
          .get();
      if (doc.exists) {
        setState(() {
          Map<String, dynamic> medicamento = doc.data() as Map<String, dynamic>;
          medicamento['codigo'] =
              codigo; // Agregar el código al mapa de datos del medicamento
          medicamentosEscaneados.add(medicamento);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No existe el medicamento en la base de datos'),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 0, 105, 243),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            onPressed: () async {
              var res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SimpleBarcodeScannerPage(),
                  ));
              if (res is String) {
                bc_code_result = res;
                obtenerDatosMedicamento(bc_code_result);
              }
            },
            child: const Text(
              'Escanear Código',
            ),
          ),
          Text(
            'Resultado del escaner: $bc_code_result',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: medicamentosEscaneados.length,
              itemBuilder: (context, index) {
                final medicamento = medicamentosEscaneados[
                    medicamentosEscaneados.length - index - 1];
                return GestureDetector(
                  onTap: () {
                    // Crear una copia del mapa de medicamentos y cambiar la clave 'codigo' a 'id'
                    Map<String, dynamic> medicamentoConId =
                        Map.from(medicamento);
                    medicamentoConId['id'] = medicamentoConId.remove('codigo');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleMedicamentoScreen(
                            medicamento: medicamentoConId),
                      ),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      leading: Icon(Icons.medication_liquid),
                      title: Text(
                        'Medicamento: ${medicamento['nombre'] ?? 'No hay datos'}',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Código: ${medicamento['codigo'] ?? 'No hay datos'}'),
                          Text(
                              'Existencias: ${medicamento['existencias'] ?? 'No hay datos'}'),
                          Text(
                              'Precio Farmacia: ${medicamento['precio_farm'] ?? 'No hay datos'}'),
                          Text(
                              'Precio Público: ${medicamento['precio_pub'] ?? 'No hay datos'}'),
                          Text(medicamento['eliminado'] == 1
                              ? 'Suspendido'
                              : 'No suspendido')
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
