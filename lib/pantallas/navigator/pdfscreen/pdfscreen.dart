import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:spelling_number/spelling_number.dart';

class PdfScreen extends StatefulWidget {
  final String pdfPath;
  final Map<String, dynamic> detallesPedido;
  final Map<String, dynamic> detallesProductos;
  final Map<String, dynamic> direccionPedido;
  final String nombreUsuario;
  final String pedidoID;

  PdfScreen({
    required this.pdfPath,
    required this.pedidoID,
    required this.detallesPedido,
    required this.detallesProductos,
    required this.direccionPedido,
    required this.nombreUsuario,
  });

  @override
  _PdfScreenState createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  final formatCurrency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  String? totalEnTexto;
  String? totalEnSpanish;
  String? pdfPath;
  Future<String>? pdfFuture;

  @override
  void initState() {
    super.initState();
    pdfFuture = createPdf();
  }

  Future<String> createPdf() async {
    String totalEnTexto =
        SpellingNumber(lang: 'es').convert(widget.detallesPedido['total']);
    final pdf = pdfWidgets.Document();

    final fontData =
        await rootBundle.load("lib/estilos/fonts/OpenSans-Medium.ttf");
    final ttf = pdfWidgets.Font.ttf(fontData);

    // Cargar el logo
    final logoData = await rootBundle.load('lib/assets/HyzarLogoWB.png');
    Uint8List logoImage = logoData.buffer.asUint8List();
    pdf.addPage(
      pdfWidgets.Page(
        build: (pdfWidgets.Context context) => pdfWidgets.Column(
          children: [
            pdfWidgets.Align(
              alignment: pdfWidgets.Alignment.topLeft,
              child: pdfWidgets.Padding(
                padding: pdfWidgets.EdgeInsets.only(top: 10, right: 10),
                child: pdfWidgets.Row(
                  mainAxisAlignment: pdfWidgets.MainAxisAlignment.end,
                  children: [
                    pdfWidgets.Text('Hyzar',
                        style: pdfWidgets.TextStyle(fontSize: 30, font: ttf)),
                    pdfWidgets.SizedBox(
                        width: 10), // Espacio entre el logo y el texto
                    pdfWidgets.Image(pdfWidgets.MemoryImage(logoImage),
                        width: 100),
                  ],
                ),
              ),
            ),
            pdfWidgets.Header(
              level: 0,
              child: pdfWidgets.Text('Pedido: ${widget.pedidoID}',
                  style: pdfWidgets.TextStyle(fontSize: 24, font: ttf)),
            ),
            pdfWidgets.Paragraph(
                text: 'Cliente: ${widget.nombreUsuario}',
                style: pdfWidgets.TextStyle(fontSize: 20, font: ttf)),
            pdfWidgets.Header(
              level: 1,
              child: pdfWidgets.Text('Productos:',
                  style: pdfWidgets.TextStyle(fontSize: 20, font: ttf)),
            ),
            pdfWidgets.Column(
              crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
              children: widget.detallesProductos['productos'].entries
                  .map<pdfWidgets.Paragraph>((producto) {
                return pdfWidgets.Paragraph(
                  text:
                      'Producto: ${producto.value['nombre'].toString()}, Cantidad: ${producto.value['cantidad'].toString()}',
                  style: pdfWidgets.TextStyle(fontSize: 20, font: ttf),
                );
              }).toList(),
            ),
            pdfWidgets.Header(
              level: 1,
              child: pdfWidgets.Text('Dirección de entrega:',
                  style: pdfWidgets.TextStyle(fontSize: 20, font: ttf)),
            ),
            pdfWidgets.Paragraph(
                text:
                    '${widget.direccionPedido['calle']} ${widget.direccionPedido['ciudad']} ${widget.direccionPedido['colonia']} ${widget.direccionPedido['numero']} ${widget.direccionPedido['zip_code']}',
                style: pdfWidgets.TextStyle(fontSize: 20, font: ttf)),
            pdfWidgets.Header(
              level: 1,
              child: pdfWidgets.Text('Total pagado:',
                  style: pdfWidgets.TextStyle(fontSize: 20, font: ttf)),
            ),
            pdfWidgets.Paragraph(
                text:
                    '\$${widget.detallesPedido['total']} (${totalEnTexto}) pesos',
                style: pdfWidgets.TextStyle(fontSize: 20, font: ttf)),
            pdfWidgets.Expanded(
              child: pdfWidgets.Align(
                alignment: pdfWidgets.Alignment.bottomCenter,
                child: pdfWidgets.Text('Gracias por su compra :)',
                    style: pdfWidgets.TextStyle(fontSize: 20, font: ttf)),
              ),
            ),
          ],
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
    return FutureBuilder<String>(
      future: pdfFuture,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Generando PDF...'),
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          pdfPath = snapshot.data;
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
      },
    );
  }
}
