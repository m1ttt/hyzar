import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UsuariosCard extends StatefulWidget {
  final String idUsuario;
  final String nombre;
  final double total;
  final String correo;
  final String telefono;
  final ImageProvider? imagen;

  UsuariosCard(this.idUsuario, this.nombre, this.total, this.correo,
      this.telefono, this.imagen);

  @override
  _UsuariosCardState createState() => _UsuariosCardState();
}

class _UsuariosCardState extends State<UsuariosCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey,
                backgroundImage: widget.imagen != null ? widget.imagen : null,
                child: widget.imagen == null
                    ? Icon(Icons.person, size: 30, color: Colors.white)
                    : null,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID Usuario: ${widget.idUsuario}',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${widget.nombre}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  widget.total == 0
                      ? SizedBox.shrink() // Widget vacío que no ocupa espacio
                      : Text(
                          'Total: ${widget.total.toStringAsFixed(2)}\$',
                          style: TextStyle(fontSize: 16),
                        ),
                ],
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.comment),
                  onPressed: () async {
                    // Acción al presionar el botón de mensaje
                    String url = 'sms:${widget.telefono}';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'No se encontró ninguna aplicación de mensajes'),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.mail),
                  onPressed: () async {
                    // Acción al presionar el botón de correo
                    String url = 'mailto:${widget.correo}';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'No se encontró ninguna aplicación de correo'),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.phone),
                  onPressed: () async {
                    // Acción al presionar el botón de llamada
                    String url = 'tel:${widget.telefono}';
                    print(url);
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'No se encontró ninguna aplicación de télefono'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
