import 'package:flutter/material.dart';
import 'package:hyzar/estilos/Colores.dart';
import 'package:image_picker/image_picker.dart';

class BottomSheetModel extends StatefulWidget {
  const BottomSheetModel({super.key});

  @override
  BottomSheetModelState createState() => BottomSheetModelState();
}

class BottomSheetModelState extends State<BottomSheetModel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text("Tap button \nbelow", textAlign: TextAlign.center),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "fab",
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 3,
        child: const Icon(
          Icons.arrow_upward,
          color: Colors.white,
        ),
        onPressed: () {
          MessageDialog(context,
              title: '', description: '', onReadMore: () {}, buttonText: '');
        },
      ),
    );
  }
}

void MessageDialog(
  BuildContext context, {
  required String title,
  required String description,
  required String buttonText,
  String buttonCancelText = "CANCELAR",
  required VoidCallback onReadMore,
  bool showCloseButton = true,
  Function()? onClose,
}) {
  onClose ??= () => Navigator.pop(context);
  showModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Wrap(
          spacing: 60,
          children: <Widget>[
            Container(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Container(height: 10),
            Text(
              description,
              style: const TextStyle(
                color: Colores.gris,
                fontSize: 18,
              ),
            ),
            Container(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                if (showCloseButton)
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.transparent),
                    onPressed: () {
                      onClose!();
                    },
                    child: Text(
                      buttonCancelText,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: onReadMore,
                  child: Text(
                    buttonText,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

// ignore: non_constant_identifier_names
void ImageSourceDialog(
  BuildContext context, {
  required Function(ImageSource) onSelectSource,
  Function()? onDelete,
}) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return Wrap(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 25, bottom: 5, right: 20),
            child: Text(
              'Seleccionar fuente de imagen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: ListTile(
              leading: const Icon(Icons.photo_library, color: Colores.gris),
              title:
                  const Text('Galería', style: TextStyle(color: Colores.gris)),
              onTap: () {
                onSelectSource(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: ListTile(
              leading: const Icon(Icons.photo_camera, color: Colores.gris),
              title: const Text(
                'Cámara',
                style: TextStyle(color: Colores.gris),
              ),
              onTap: () {
                onSelectSource(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 20, top: 0, bottom: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                onDelete != null
                    ? TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.transparent),
                        onPressed: () {
                          onDelete();
                          Navigator.pop(context);
                        },
                        child: Text(
                          "BORRAR IMAGEN",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      )
                    : Container(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(
                    'ACEPTAR',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
