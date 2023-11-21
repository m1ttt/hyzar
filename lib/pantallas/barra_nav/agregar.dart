import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PantallaAgregar extends StatefulWidget {
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
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Subiendo medicamento... ${(uploadProgress ?? 0.0) * 100}%'),
            ],
          ),
        );
      },
    );
  }

  Future<void> agregarMedicamento(
      String codigo, Map<String, dynamic> datos, File? imagen) async {
    try {
      if (imagen != null) {
        mostrarDialogoDeProgreso(context);
        final ref = FirebaseStorage.instance.ref().child(codigo);
        final uploadTask = ref.putFile(imagen);
        final taskSnapshot = uploadTask.snapshotEvents.listen((snapshot) {
          setState(() {
            uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        });
        await uploadTask.whenComplete(() => taskSnapshot.cancel());
        datos['imagen'] = await ref.getDownloadURL();
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
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext bc) {
                        return SafeArea(
                          child: Container(
                            child: Wrap(
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.photo_library),
                                  title:
                                      const Text('Seleccionar de la galería'),
                                  onTap: () {
                                    seleccionarImagen(ImageSource.gallery);
                                    Navigator.of(context).pop();
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.photo_camera),
                                  title: Text('Tomar foto'),
                                  onTap: () {
                                    seleccionarImagen(ImageSource.camera);
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
              if (_imageFile != null) Image.file(_imageFile!),
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
                  controller: descripcionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
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
                    'descripcion': descripcionController.text,
                    'existencias': int.parse(existenciasController.text),
                    'precio_farm': double.parse(precioFarmController.text),
                    'precio_pub': double.parse(precioPubController.text),
                    'eliminado': 0,
                  };
                  await agregarMedicamento(
                      codigoController.text, datosMedicamento, _imageFile);

                  // Vaciar los campos
                  codigoController.clear();
                  existenciasController.clear();
                  nombreController.clear();
                  descripcionController.clear();
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
