import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hyzar/estilos/Colores.dart';
import 'package:hyzar/utilidades/widgets/ModalDialog.dart';
import 'package:image_cropper/image_cropper.dart';
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
      MessageDialog(context,
          title: "Error",
          description: "Error al agregar el medicamento $e",
          buttonText: "ACEPTAR", onReadMore: () {
        Navigator.pop(context);
      }, showCloseButton: false);
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
              GestureDetector(
                onTap: () {
                  ImageSourceDialog(
                    context,
                    onSelectSource: (source) async {
                      final pickedFile =
                          await ImagePicker().pickImage(source: source);
                      if (pickedFile != null) {
                        final croppedFile = await ImageCropper().cropImage(
                          sourcePath: pickedFile.path,
                          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
                          compressQuality: 100,
                          maxWidth: 700,
                          maxHeight: 700,
                          compressFormat: ImageCompressFormat.jpg,
                        );
                        if (croppedFile != null) {
                          setState(() {
                            _imageFile = File(croppedFile.path);
                          });
                        }
                      }
                    },
                    onDelete: _imageFile != null
                        ? () {
                            setState(() {
                              _imageFile = null;
                            });
                          }
                        : null,
                  );
                },
                child: _imageFile == null
                    ? SvgPicture.asset(
                        'lib/assets/AgregarImagen.svg',
                        width: 150,
                        height: 150,
                        color: Colores.gris,
                      )
                    : Center(
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            image: DecorationImage(
                              image: FileImage(_imageFile!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
              ),
              SizedBox(height: 20),
              Text("Agregar medicamento",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colores.gris)),
              SizedBox(height: 5),
              Text("Continua deslizando para ver más opciones",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colores.gris)),
              SizedBox(height: 20),
              Card(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      codigoController.text = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Código",
                    prefixIcon: IconButton(
                      icon: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colores.gris,
                      ),
                      onPressed: () async {
                        var res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SimpleBarcodeScannerPage(
                                appBarTitle: 'Escanear Código',
                                isShowFlashIcon: true,
                              ),
                            ));
                        if (res is String) {
                          codigoController.text = res;
                        }
                      },
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              Card(
                child: TextField(
                  controller: existenciasController,
                  decoration: InputDecoration(
                    labelText: 'Existencias',
                    prefixIcon: Icon(Icons.add_shopping_cart),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              Card(
                child: TextField(
                  controller: nombreController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nombre del producto',
                    prefixIcon: Icon(Icons.medication_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
              Card(
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  controller: descripcionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
              Card(
                child: TextField(
                  controller: precioFarmController,
                  decoration: InputDecoration(
                    labelText: 'Precio Farmacia',
                    prefixIcon: Icon(Icons.monetization_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              Card(
                child: TextField(
                  controller: precioPubController,
                  decoration: InputDecoration(
                    labelText: 'Precio Público',
                    prefixIcon: Icon(Icons.monetization_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
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
                        padding: EdgeInsets.all(8.0), child: Container()),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text("Vista previa de la imagen",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colores.gris)),
              if (_imageFile != null) Image.file(_imageFile!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (nombreController.text.isEmpty ||
                      descripcionController.text.isEmpty ||
                      existenciasController.text.isEmpty ||
                      precioFarmController.text.isEmpty ||
                      precioPubController.text.isEmpty) {
                    MessageDialog(context,
                        title: "Error",
                        description: "Por favor, rellene todos los campos",
                        buttonText: "ACEPTAR", onReadMore: () {
                      Navigator.pop(context);
                    }, showCloseButton: false);
                  } else {
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
                    MessageDialog(context,
                        title: "Éxito",
                        description: "Medicamento subido con éxito",
                        buttonText: "ACEPTAR", onReadMore: () {
                      Navigator.pop(context);
                    }, showCloseButton: false);
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                      (states) => Colores.verde),
                  foregroundColor: MaterialStateProperty.resolveWith(
                      (states) => Colors.white),
                ),
                child: const Text(
                  'Cargar medicamento',
                ),
              ),
            ],
          )),
    );
  }
}
