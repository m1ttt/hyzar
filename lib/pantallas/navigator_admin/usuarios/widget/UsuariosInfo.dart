import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UsuariosInfo extends StatefulWidget {
  final String idUsuario;
  final Map<String, dynamic> datosUsuario;

  UsuariosInfo({required this.idUsuario, required this.datosUsuario});

  @override
  _UsuariosInfoState createState() => _UsuariosInfoState();
}

class _UsuariosInfoState extends State<UsuariosInfo> {
  final _formKey = GlobalKey<FormState>();
  String? _tipoUsuario;
  String? _nombre;
  String? _telefono;

  @override
  void initState() {
    super.initState();
    _tipoUsuario = widget.datosUsuario['tipo'];
    _nombre = widget.datosUsuario['nombre'];
    _telefono = widget.datosUsuario['telefono'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información del usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('ID: ${widget.idUsuario}'),
              TextFormField(
                initialValue: _nombre,
                decoration: InputDecoration(labelText: 'Nombre'),
                onChanged: (value) {
                  _nombre = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
              ),
              Text('Correo: ${widget.datosUsuario['correo']}'),
              TextFormField(
                initialValue: _telefono,
                decoration: InputDecoration(labelText: 'Teléfono'),
                onChanged: (value) {
                  _telefono = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un teléfono';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _tipoUsuario,
                items: ['admin', 'usuario'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _tipoUsuario = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona un tipo de usuario';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await FirebaseDatabase.instance
                        .reference()
                        .child('usuarios/${widget.idUsuario}')
                        .update({
                      'tipo': _tipoUsuario,
                      'nombre': _nombre,
                      'telefono': _telefono,
                    });

                    SnackBar snackBar = SnackBar(
                      content: Text('Usuario actualizado'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
