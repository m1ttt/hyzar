import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:hyzar/estilos/Colores.dart';
import 'package:hyzar/pantallas/principal.dart';
import 'package:hyzar/utilidades/backend/user_notifier.dart';
import 'package:hyzar/utilidades/widgets/ModalDialog.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';

const kGoogleApiKey =
    "AIzaSyDkI-wIVbRdbLU2vKot_f0qyT_BQ-ew4rU"; // Reemplaza con tu API Key

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class DireccionScreen extends StatefulWidget {
  final Map<String, dynamic> pedido;
  final String formaPago;
  final double total;
  final String nombreUsuario;

  DireccionScreen(
      {required this.pedido,
      required this.formaPago,
      required this.total,
      required this.nombreUsuario});
  @override
  _DireccionScreenState createState() => _DireccionScreenState();
}

class _DireccionScreenState extends State<DireccionScreen> {
  @override
  void initState() {
    super.initState();

    calleController.addListener(() {
      if (calleController.text.isNotEmpty) {
        setState(() {
          calle = calleController.text;
        });
      }
    });

    numeroController.addListener(() {
      if (numeroController.text.isNotEmpty) {
        setState(() {
          numero = numeroController.text;
        });
      }
    });

    coloniaController.addListener(() {
      if (coloniaController.text.isNotEmpty) {
        setState(() {
          colonia = coloniaController.text;
        });
      }
    });

    ciudadController.addListener(() {
      if (ciudadController.text.isNotEmpty) {
        setState(() {
          ciudad = ciudadController.text;
        });
      }
    });

    zip_codeController.addListener(() {
      if (zip_codeController.text.isNotEmpty) {
        setState(() {
          zip_code = zip_codeController.text;
        });
      }
    });

    campoExtraController.addListener(() {
      if (campoExtraController.text.isNotEmpty) {
        setState(() {
          campoExtra = campoExtraController.text;
        });
      }
    });
  }

  String direccion = '';
  String calle = '';
  String colonia = '';
  String ciudad = '';
  String numero = '';
  String zip_code = '';
  String campoExtra = '';

  // Controladores de texto para cada campo
  TextEditingController calleController = TextEditingController();
  TextEditingController numeroController = TextEditingController();
  TextEditingController coloniaController = TextEditingController();
  TextEditingController ciudadController = TextEditingController();
  TextEditingController zip_codeController = TextEditingController();
  TextEditingController campoExtraController = TextEditingController();

  Future<void> _handlePressButton() async {
    await Future.delayed(Duration(milliseconds: 100));

    try {
      // ignore: use_build_context_synchronously
      Prediction? p = await PlacesAutocomplete.show(
          context: context,
          apiKey: kGoogleApiKey,
          mode: Mode.overlay,
          language: "es",
          components: [Component(Component.country, "mx")],
          types: ['address'],
          offset: 0,
          radius: 1000,
          strictbounds: false,
          region: "mx",
          hint: "Buscar dirección",
          startText: direccion == "" ? "" : direccion);

      if (p != null && p.placeId != null) {
        calleController.clear();
        numeroController.clear();
        coloniaController.clear();
        ciudadController.clear();
        calle = '';
        numero = '';
        colonia = '';
        ciudad = '';
        PlacesDetailsResponse detail =
            await _places.getDetailsByPlaceId(p.placeId!);

        if (detail.result.geometry != null) {
          double lat = detail.result.geometry!.location.lat;
          double lng = detail.result.geometry!.location.lng;

          print(lat);
          print(lng);

          for (AddressComponent component in detail.result.addressComponents) {
            if (component.types.contains('street_number')) {
              numero = component.longName;
              numeroController.text = numero;
            } else if (component.types.contains('route')) {
              calle = component.longName;
              calleController.text = calle;
            } else if (component.types.contains('sublocality_level_1')) {
              colonia = component.longName;
              coloniaController.text = colonia;
            } else if (component.types.contains('locality')) {
              ciudad = component.longName;
              ciudadController.text = ciudad;
            } else if (component.types.contains('postal_code')) {
              zip_code = component.longName;
              zip_codeController.text = zip_code;
            }
          }

          setState(() {
            direccion = p.description ?? '';
          });
        } else {
          print('No se encontró la geometría para esta ubicación');
        }
      }
    } catch (e) {
      print('Ocurrió un error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dirección del pedido',
          style: TextStyle(
            color: Colores.verde,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Calle',
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              calle.isEmpty ? Colors.red : Colors.transparent)),
                ),
                child: TextField(
                  onTap: _handlePressButton,
                  controller: calleController,
                ),
              ),
            ),
            ListTile(
              title: InputDecorator(
                decoration: InputDecoration(
                    labelText: 'Número',
                    filled: true,
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: numero.isEmpty
                                ? Colors.red
                                : Colors.transparent))),
                child: TextField(
                  controller: numeroController,
                ),
              ),
            ),
            ListTile(
              title: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Colonia',
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: colonia.isEmpty
                              ? Colors.red
                              : Colors.transparent)),
                ),
                child: TextField(
                  controller: coloniaController,
                ),
              ),
            ),
            ListTile(
              title: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Ciudad',
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: ciudad.isEmpty
                              ? Colors.red
                              : Colors.transparent)),
                ),
                child: TextField(
                  controller: ciudadController,
                ),
              ),
            ),
            ListTile(
              title: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Código postal',
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: zip_code.isEmpty
                              ? Colors.red
                              : Colors.transparent)),
                ),
                child: TextField(
                  controller: zip_codeController,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding:
                  EdgeInsets.all(8.0), // Ajusta el valor según tus necesidades
              child: Text(
                "Al realizar un pedido, este se procesará y se enviará a la dirección proporcionada.",
                style: TextStyle(color: Colores.gris),
              ),
            ),
            SizedBox(height: 5),
            ElevatedButton(
              onPressed: () async {
                MessageDialog(context,
                    title: "Confirmación",
                    description: "¿Estás seguro que quieres hacer el pedido?",
                    buttonText: "ACEPTAR", onReadMore: () async {
                  if (calle.isNotEmpty &&
                      numero.isNotEmpty &&
                      colonia.isNotEmpty &&
                      ciudad.isNotEmpty &&
                      zip_code.isNotEmpty) {
                    // Combina los detalles del pedido y la dirección en un solo mapa
                    Uuid uuid = Uuid();
                    String pedidoUID = uuid.v4();
                    Map<String, dynamic> pedidoCompleto = {
                      pedidoUID: {
                        'detalles_productos': widget.pedido,
                        'direccion_pedido': {
                          'calle': calle,
                          'numero': numero,
                          'colonia': colonia,
                          'ciudad': ciudad,
                          'zip_code': zip_code,
                        },
                        'total': widget.total,
                        'forma_pago': widget.formaPago,
                        'nombreUsuario': widget.nombreUsuario,
                        'estado': 'pendiente',
                        'pagado': false,
                      }
                    };

                    // Obtiene el userID
                    String userID =
                        Provider.of<UserNotifier>(context, listen: false)
                            .getUserID();

                    // Comprueba si ya existe un documento con el mismo userID
                    DocumentSnapshot docSnap = await FirebaseFirestore.instance
                        .collection('pedidos')
                        .doc(userID)
                        .get();

                    if (docSnap.exists) {
                      // Si el documento ya existe, agrega el nuevo pedido al documento
                      await FirebaseFirestore.instance
                          .collection('pedidos')
                          .doc(userID)
                          .update(pedidoCompleto);
                    } else {
                      // Si el documento no existe, crea un nuevo documento con el userID y el pedido
                      await FirebaseFirestore.instance
                          .collection('pedidos')
                          .doc(userID)
                          .set(pedidoCompleto);
                    }

                    // Muestra un mensaje de éxito
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Pedido realizado con éxito')),
                    );

                    // Regresa a PantallaUS
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => PrincipalUser()),
                      (Route<dynamic> route) => false,
                    );
                  } else {
                    MessageDialog(context,
                        title: "Error",
                        description: "Por favor, rellena todos los campos",
                        buttonText: "ACEPTAR", onReadMore: () {
                      Navigator.pop(context);
                    });
                  }
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.shopping_cart), // Ícono de carrito de compras
                  SizedBox(width: 10), // Espacio entre el ícono y el texto
                  Text(
                    'Realizar pedido',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colores.verde,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
