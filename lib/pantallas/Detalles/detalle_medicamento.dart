import 'dart:io';
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hyzar/estilos/Colores.dart';
import 'package:image_picker/image_picker.dart';

class DetalleMedicamentoScreen extends StatefulWidget {
  final Map<String, dynamic> medicamento;
  final String userType;

  const DetalleMedicamentoScreen(
      {super.key, required this.medicamento, required this.userType});

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

  File? _imageFile;

  Future<void> _updateMedicamento() async {
    try {
      String? imageUrl;
      if (_imageFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('medicamentos')
            .child(widget.medicamento['id']);
        await ref.putFile(_imageFile!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('medicamentos')
          .doc(widget.medicamento['id'])
          .update({
        'nombre': nombreController.text,
        'descripcion': descripcionController.text,
        'existencias': int.parse(existenciasController.text),
        'precio_farm': double.parse(precioFarmController.text),
        'precio_pub': double.parse(precioPubController.text),
        'eliminado': eliminado,
        if (imageUrl != null) 'imagen': imageUrl, // Agrega esta línea
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Datos actualizados correctamente")),
      );
    } catch (e) {
      print('Error al actualizar los datos: $e');
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Seleccionar de la galería'),
            onTap: () async {
              final pickedFile =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {
                setState(() {
                  _imageFile = File(pickedFile.path);
                });
              }
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Tomar foto'),
            onTap: () async {
              final pickedFile =
                  await ImagePicker().pickImage(source: ImageSource.camera);
              if (pickedFile != null) {
                setState(() {
                  _imageFile = File(pickedFile.path);
                });
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

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
        title: const Text("Detalles del producto",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colores.verde)),
        elevation: 0,
        actions: <Widget>[
          if (widget.userType == 'admin')
            IconButton(
              icon: Icon(editing ? Icons.save : Icons.edit),
              onPressed: () async {
                if (editing) {
                  try {
                    String? imageUrl;
                    if (_imageFile != null) {
                      final ref = FirebaseStorage.instance
                          .ref()
                          .child('medicamentos')
                          .child(widget.medicamento['id']);
                      await ref.putFile(_imageFile!);
                      imageUrl = await ref.getDownloadURL();
                    }

                    await FirebaseFirestore.instance
                        .collection('medicamentos')
                        .doc(widget.medicamento['id'])
                        .update({
                      'nombre': capitalize(nombreController.text),
                      'descripcion': descripcionController.text,
                      'existencias': int.parse(existenciasController.text),
                      'precio_farm': double.parse(precioFarmController.text),
                      'precio_pub': double.parse(precioPubController.text),
                      'eliminado': eliminado,
                      if (imageUrl != null)
                        'imagen': imageUrl, // Agrega esta línea
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
            return const Text('Cargando');
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Container(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                      child: Column(
                    children: [
                      Text(
                        "Estos son los detalles del producto",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colores.gris,
                            fontSize: 22),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text("Desliza hacia abajo para ver más detalles",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colores.gris,
                              fontSize: 14)),
                    ],
                  )),
                  SizedBox(
                    height: 12,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: editing
                        ? GestureDetector(
                            onTap: _pickImage,
                            child: _imageFile != null
                                ? Image.file(_imageFile!)
                                : const Text(
                                    'Haz clic para seleccionar una imagen'),
                          )
                        : data['imagen'] != null
                            ? Image.network(
                                data['imagen'],
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Text(
                                      'Error al cargar la imagen');
                                },
                              )
                            : const Text('No hay imagen disponible'),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text("Nombre del medicamento",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colores.gris,
                          fontWeight: FontWeight.bold)),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.medication),
                      title: editing
                          ? TextField(controller: nombreController)
                          : Text(
                              '${data['nombre']}',
                              style: const TextStyle(fontSize: 24),
                            ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text("Descripción",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colores.gris,
                          fontWeight: FontWeight.bold)),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.description),
                      title: editing
                          ? TextField(controller: descripcionController)
                          : Text(
                              '${data['descripcion']}',
                              style: const TextStyle(fontSize: 24),
                            ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text("Existencias",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colores.gris,
                          fontWeight: FontWeight.bold)),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.inventory),
                      title: editing
                          ? TextField(controller: existenciasController)
                          : Text(
                              '${data['existencias']} unidades',
                              style: const TextStyle(fontSize: 20),
                            ),
                    ),
                  ),
                  if (widget.userType == 'admin')
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.money),
                        title: editing
                            ? TextField(controller: precioFarmController)
                            : Text(
                                'Precio Farmacia: ${data['precio_farm']}',
                                style: const TextStyle(fontSize: 20),
                              ),
                      ),
                    ),
                  SizedBox(height: 12),
                  Text("Precio",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colores.gris,
                          fontWeight: FontWeight.bold)),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.money),
                      title: editing
                          ? TextField(controller: precioPubController)
                          : Text(
                              '\$${data['precio_pub']} mxn',
                              style: const TextStyle(fontSize: 20),
                            ),
                    ),
                  ),
                  if (widget.userType == 'admin')
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.delete_forever),
                        title: editing
                            ? DropdownButton<int>(
                                value: eliminado,
                                items: const [
                                  DropdownMenuItem(
                                    value: 0,
                                    child: Text('No'),
                                  ),
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text('Sí'),
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
                                style: const TextStyle(fontSize: 20),
                              ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
