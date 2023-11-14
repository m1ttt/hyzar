import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class PantallaBusqueda extends StatefulWidget {
  @override
  _PantallaBusquedaState createState() => _PantallaBusquedaState();
}

class _PantallaBusquedaState extends State<PantallaBusqueda> {
  String bc_code_result = "";

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
              setState(() {
                if (res is String) {
                  bc_code_result = res;
                }
              });
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Card(
                  child: ListTile(
                    leading: Icon(Icons.album),
                    title: Text('Placeholder'),
                    subtitle: Text('Placeholder para una tarjeta'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
