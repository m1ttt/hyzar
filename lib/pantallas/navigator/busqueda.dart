// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:hyzar/estilos/Colores.dart';
import 'package:hyzar/utilidades/backend/user_notifier.dart';
import 'package:provider/provider.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibration/vibration.dart';
import '../Detalles/detalle_medicamento.dart';

class PantallaBusqueda extends StatefulWidget {
  const PantallaBusqueda({super.key});

  @override
  _PantallaBusquedaState createState() => _PantallaBusquedaState();
}

class _PantallaBusquedaState extends State<PantallaBusqueda> {
  late String userType;
  late String email;

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

  void initUserType() async {
    userType = Provider.of<UserNotifier>(context, listen: false).getUserType();
    email = Provider.of<UserNotifier>(context, listen: false).getEmail();
  }

  @override
  void initState() {
    super.initState();
    initUserType();
    _controller.addListener(_handleTextChanged);
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> stream;

    if (searchText.isNotEmpty && bc_code_result.isNotEmpty) {
      stream = FirebaseFirestore.instance
          .collection("medicamentos")
          .where('nombre',
              isGreaterThanOrEqualTo: searchText,
              isLessThan: searchText + '\uf8ff')
          .where('codigo', isEqualTo: bc_code_result)
          .snapshots();
    } else if (searchText.isNotEmpty) {
      stream = FirebaseFirestore.instance
          .collection("medicamentos")
          .where('nombre',
              isGreaterThanOrEqualTo: searchText,
              isLessThan: searchText + '\uf8ff')
          .snapshots();
    } else if (bc_code_result.isNotEmpty) {
      stream = FirebaseFirestore.instance
          .collection("medicamentos")
          .where('codigo', isEqualTo: bc_code_result)
          .snapshots();
    } else {
      stream = Stream.empty();
    }

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 3), // Añade un espacio (20px)
          const Text(
            "Prueba buscando algún producto",
            style: TextStyle(
                fontSize: 20, color: Colores.gris, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10), // Añade un espacio (20px)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value.isNotEmpty
                      ? value[0].toUpperCase() + value.substring(1)
                      : value;
                });
              },
              decoration: InputDecoration(
                labelText: "Buscar producto",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colores.gris,
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
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Text(
            'Resultado del escaner: $bc_code_result',
            style: const TextStyle(
                fontSize: 14, color: Colores.gris, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return ListView(
                  children:
                      snapshot.data?.docs.map((DocumentSnapshot document) {
                            Map<String, dynamic> medicamento =
                                document.data() as Map<String, dynamic>;
                            medicamento['codigo'] = document.id;
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.medication_liquid),
                                title: Text(
                                  '${medicamento['nombre'] ?? 'No hay datos'}',
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
                                    userType == 'admin'
                                        ? Text(
                                            'Precio Farmacia: ${medicamento['precio_farm'] ?? 'No hay datos'}')
                                        : SizedBox.shrink(),
                                    Text(
                                      userType == 'admin'
                                          ? 'Precio Público: ${medicamento['precio_pub'] ?? 'No hay datos'}'
                                          : 'Precio: ${medicamento['precio_pub'] ?? 'No hay datos'}',
                                    ),
                                    userType == 'admin'
                                        ? Text(medicamento['eliminado'] == 1
                                            ? 'Suspendido'
                                            : 'No suspendido')
                                        : SizedBox.shrink(),
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
                                      builder: (context) =>
                                          DetalleMedicamentoScreen(
                                              medicamento: medicamentoConId,
                                              userType: userType),
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList() ??
                          [],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
