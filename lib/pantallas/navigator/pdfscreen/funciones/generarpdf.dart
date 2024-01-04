import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../pdfscreen.dart';

class PdfUtils {
  static Future<void> generarPDF(
      Map<String, dynamic> detallesPedido, BuildContext context) async {
    final pdf = pw.Document();

    // Agrega los detalles del pedido al PDF...

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/pedido.pdf");
    await file.writeAsBytes(await pdf.save());

    // Navega a la nueva pantalla con la ruta del archivo PDF y los datos del pedido
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfScreen(
          pdfPath: file.path,
          detallesPedido: detallesPedido,
          detallesProductos: detallesPedido['detalles_productos'],
          direccionPedido: detallesPedido['direccion_pedido'],
          nombreUsuario: detallesPedido['nombreUsuario'],
        ),
      ),
    );
  }
}
