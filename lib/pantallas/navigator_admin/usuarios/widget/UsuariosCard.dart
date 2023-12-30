import 'package:flutter/material.dart';

class UsuariosCard extends StatefulWidget {
  final String idUsuario;
  final String nombre;
  final double total;

  UsuariosCard(this.idUsuario, this.nombre, this.total);

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
                child: Icon(Icons.person, size: 30, color: Colors.white),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID Usuario: ${widget.idUsuario}',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Nombre: ${widget.nombre}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total: ${widget.total.toStringAsFixed(2)}',
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
                  onPressed: () {
                    // Acción al presionar el botón de mensaje
                  },
                ),
                IconButton(
                  icon: Icon(Icons.mail),
                  onPressed: () {
                    // Acción al presionar el botón de correo
                  },
                ),
                IconButton(
                  icon: Icon(Icons.phone),
                  onPressed: () {
                    // Acción al presionar el botón de llamada
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
