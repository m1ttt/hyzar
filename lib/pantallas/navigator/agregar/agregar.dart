import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PantallaAgregar extends StatefulWidget {
  const PantallaAgregar({super.key});

  @override
  _PantallaAgregarState createState() => _PantallaAgregarState();
}

class _PantallaAgregarState extends State<PantallaAgregar> {
  final picker = ImagePicker();
  File? _imageFile;
  double? uploadProgress;
  bool ordenarPorNombre = true;
  String bc_code_result = "";
  Map<String, dynamic> medicamentoData = {};

  final codigoController = TextEditingController();
  final descripcionController = TextEditingController();
  final existenciasController = TextEditingController();
  final nombreController = TextEditingController();
  final precioFarmController = TextEditingController();
  final precioPubController = TextEditingController();

  String capitalize(String s) =>
      s[0].toUpperCase() + s.substring(1).toLowerCase();

  void mostrarDialogoDeProgreso(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text('Subiendo medicamento... ${(uploadProgress ?? 0.0) * 100}%'),
            ],
          ),
        );
      },
    );
  }

  Future<String> subirImagen(File imagen, String codigo) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('$codigo');
      final uploadTask = ref.putFile(imagen);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      final taskSnapshot = await uploadTask;
      final imageUrl = await taskSnapshot.ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Error al subir imagen: $e');
      throw e;
    }
  }

  Future<void> agregarMedicamento(
      String codigo, Map<String, dynamic> datos, File? imagen) async {
    try {
      if (imagen != null) {
        mostrarDialogoDeProgreso(context);
        datos['imagen'] = await subirImagen(imagen, codigo);
        Navigator.of(context).pop(); // Cierra el cuadro de diálogo

        setState(() {
          _imageFile = null; // Elimina la imagen de la pantalla
        });
      }
      await FirebaseFirestore.instance
          .collection('medicamentos')
          .doc(codigo)
          .set(datos);
    } catch (e) {
      print('Error al agregar medicamento: $e');
    }
  }

  Future<void> seleccionarImagen(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);
      setState(() {
        if (pickedFile != null) {
          _imageFile = File(pickedFile.path);
        } else {
          print('No se seleccionó ninguna imagen.');
        }
      });
    } catch (e) {
      print('Error al seleccionar imagen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Card(
                child: TextField(
                  controller: codigoController,
                  decoration: const InputDecoration(
                    labelText: 'Código de barras',
                    prefixIcon: Icon(Icons.qr_code_scanner),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 18, 136, 185),
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
              const SizedBox(height: 10),
              Card(
                child: TextField(
                  controller: existenciasController,
                  decoration: const InputDecoration(
                    labelText: 'Existencias',
                    prefixIcon: Icon(Icons.add_shopping_cart),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              Card(
                child: TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del producto',
                    prefixIcon: Icon(Icons.medication_rounded),
                  ),
                ),
              ),
              Card(
                child: TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
              ),
              Card(
                child: TextField(
                  controller: precioFarmController,
                  decoration: const InputDecoration(
                    labelText: 'Precio Farmacia',
                    prefixIcon: Icon(Icons.monetization_on),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              Card(
                child: TextField(
                  controller: precioPubController,
                  decoration: const InputDecoration(
                    labelText: 'Precio Público',
                    prefixIcon: Icon(Icons.monetization_on),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceEvenly, // Centra los botones en la fila
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          Map<String, dynamic> datosMedicamento = {
                            'nombre': capitalize(nombreController.text),
                            'descripcion': descripcionController.text,
                            'existencias':
                                int.parse(existenciasController.text),
                            'precio_farm':
                                double.parse(precioFarmController.text),
                            'precio_pub':
                                double.parse(precioPubController.text),
                            'eliminado': 0,
                          };
                          await agregarMedicamento(codigoController.text,
                              datosMedicamento, _imageFile);

                          // Vaciar los campos
                          codigoController.clear();
                          existenciasController.clear();
                          nombreController.clear();
                          descripcionController.clear();
                          precioFarmController.clear();
                          precioPubController.clear();

                          // Mostrar un mensaje
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Medicamento subido con éxito'),
                            ),
                          );
                        },
                        child: const Text(
                          'Subir',
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext bc) {
                                return SafeArea(
                                  child: Container(
                                    child: Wrap(
                                      children: <Widget>[
                                        ListTile(
                                          leading:
                                              const Icon(Icons.photo_library),
                                          title: const Text(
                                              'Seleccionar de la galería'),
                                          onTap: () {
                                            seleccionarImagen(
                                                ImageSource.gallery);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        ListTile(
                                          leading:
                                              const Icon(Icons.photo_camera),
                                          title: const Text('Tomar foto'),
                                          onTap: () {
                                            seleccionarImagen(
                                                ImageSource.camera);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        child: const Text('Seleccionar imagen'),
                      ),
                    ),
                  ),
                ],
              ),
              if (_imageFile != null) Image.file(_imageFile!),
            ],
          )),
    );
  }
}
