import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class PdfScreen extends StatefulWidget {
  final String pdfPath;
  final Map<String, dynamic> detallesPedido;
  final Map<String, dynamic> detallesProductos;
  final Map<String, dynamic> direccionPedido;
  final String nombreUsuario;

  PdfScreen({
    required this.pdfPath,
    required this.detallesPedido,
    required this.detallesProductos,
    required this.direccionPedido,
    required this.nombreUsuario,
  });

  @override
  _PdfScreenState createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  String? pdfPath;

  @override
  void initState() {
    super.initState();
    createPdf().then((path) {
      setState(() {
        pdfPath = path;
      });
    });
  }

  Future<String> createPdf() async {
    final pdf = pdfWidgets.Document();

    final fontData =
        await rootBundle.load("lib/estilos/fonts/OpenSans-Medium.ttf");
    final ttf = pdfWidgets.Font.ttf(fontData);

    // Agrega los datos del pedido al PDF...
    pdf.addPage(
      pdfWidgets.Page(
        build: (pdfWidgets.Context context) => pdfWidgets.Center(
          child: pdfWidgets.Column(
            children: [
              pdfWidgets.Text('Pedido: ${widget.detallesPedido['id']}',
                  style: pdfWidgets.TextStyle(fontSize: 40, font: ttf)),
              pdfWidgets.Text('Usuario: ${widget.nombreUsuario}',
                  style: pdfWidgets.TextStyle(fontSize: 20, font: ttf)),
              pdfWidgets.Text('Productos:',
                  style: pdfWidgets.TextStyle(fontSize: 20, font: ttf)),
              pdfWidgets.Text(
                  'Dirección de entrega: ${widget.direccionPedido['direccion']}',
                  style: pdfWidgets.TextStyle(fontSize: 20, font: ttf)),
            ],
          ),
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/pedido.pdf");
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    if (pdfPath == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Nota de compra'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () async {
              final pdfBytes = File(pdfPath!).readAsBytesSync();
              await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async => pdfBytes,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Comparte el PDF...
              Share.shareXFiles([XFile(pdfPath!)]);
            },
          ),
        ],
      ),
      body: PDFView(
        filePath: pdfPath!,
        // Configura las opciones de PDFView...
      ),
    );
  }
}
