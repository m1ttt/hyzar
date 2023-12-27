import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibration/vibration.dart';
import 'detalle_medicamento.dart';

class PantallaBusqueda extends StatefulWidget {
  final String userType;
  const PantallaBusqueda({Key? key, required this.userType}) : super(key: key);
  @override
  _PantallaBusquedaState createState() => _PantallaBusquedaState();
}

class _PantallaBusquedaState extends State<PantallaBusqueda> {
  String bc_code_result = "";
  String searchText = "";
  final TextEditingController _controller = TextEditingController();
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
        if ((await Vibration.hasVibrator()) ?? false) {
          // Comprueba si el dispositivo tiene un vibrador
          Vibration.vibrate(); // Hace vibrar el dispositivo
        }
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

  void _handleTextChanged() {
    String text = _controller.text;
    if (text.isNotEmpty && text.length < 2) {
      _controller.text = text.toUpperCase();
      _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value.length > 0
                      ? value[0].toUpperCase() + value.substring(1)
                      : value;
                });
              },
              decoration: InputDecoration(
                labelText: "Buscar medicamento",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
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
                    builder: (context) => const SimpleBarcodeScannerPage(
                      appBarTitle: 'Escanear Código',
                      isShowFlashIcon: true,
                    ),
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
            child: StreamBuilder<QuerySnapshot>(
              stream: (searchText == "" || searchText == null)
                  ? FirebaseFirestore.instance
                      .collection("medicamentos")
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection("medicamentos")
                      .where('nombre', isGreaterThanOrEqualTo: searchText)
                      .where('nombre', isLessThan: searchText + '\uf8ff')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> medicamento =
                        document.data() as Map<String, dynamic>;
                    medicamento['codigo'] = document.id;
                    return Card(
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
                                'Descripción: ${medicamento['descripcion'] ?? 'No hay datos'}'),
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
                        onTap: () {
                          // Crear una copia del mapa de medicamentos y cambiar la clave 'codigo' a 'id'
                          Map<String, dynamic> medicamentoConId =
                              Map.from(medicamento);
                          medicamentoConId['id'] =
                              medicamentoConId.remove('codigo');

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetalleMedicamentoScreen(
                                medicamento: medicamentoConId,
                                userType: widget.userType,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
