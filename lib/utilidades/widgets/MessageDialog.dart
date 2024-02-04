import 'package:flutter/material.dart';
import 'package:hyzar/utilidades/Colores.dart';

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
  required VoidCallback onReadMore,
  bool showCloseButton = true,
}) {
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
              style: TextStyle(
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
                      Navigator.pop(context);
                    },
                    child: Text(
                      "CERRAR",
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
