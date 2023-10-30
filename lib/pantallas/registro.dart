import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RegistroUsuarioScreen extends StatefulWidget {
  @override
  _RegistroUsuarioScreenState createState() => _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child("usuarios");

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isMasculino = true;
  bool _aceptoTerminos = false;

  void _registrarUsuario() async {
    String genero = _isMasculino ? "masculino" : "femenino";

    if (_aceptoTerminos) {
      if (_nombreController.text.isNotEmpty &&
          _correoController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty) {
        if (_passwordController.text == _confirmPasswordController.text) {
          try {
            UserCredential userCredential =
                await _auth.createUserWithEmailAndPassword(
              email: _correoController.text.trim(),
              password: _passwordController.text,
            );

            if (userCredential.user != null) {
              String userID = userCredential.user!.uid;

              await _databaseReference.child(userID).set({
                "nombre": _nombreController.text,
                "correo": _correoController.text,
                "telefono": _telefonoController.text,
                "genero": genero,
                "tipo": "usuario",
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Usuario registrado correctamente")),
              );

              Navigator.pop(context); // Regresar a la pantalla anterior
            }
          } catch (e) {
            print(e);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Autenticación fallida")),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Las contraseñas no coinciden")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Todos los campos son requeridos")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Debes aceptar los términos")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context)
                  .pop(); // Navegar hacia atrás al presionar el botón de flecha
            },
          ),
        ),
        body: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 40),
                  Row(
                    children: [
                      Icon(
                        Icons.how_to_reg,
                        size: 60,
                        color: Color.fromARGB(255, 0, 105, 243),
                      ),
                      SizedBox(width: 16),
                      Text(
                        "Regístrate",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 105, 243),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          borderSide: BorderSide(width: 1.0),
                        )),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _correoController,
                    decoration: InputDecoration(
                      labelText: 'Correo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(width: 1.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _telefonoController,
                    decoration: InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(width: 1.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Radio(
                        value: true,
                        groupValue: _isMasculino,
                        onChanged: (value) {
                          setState(() {
                            _isMasculino = value!;
                          });
                        },
                      ),
                      Text('Masculino'),
                      Radio(
                        value: false,
                        groupValue: _isMasculino,
                        onChanged: (value) {
                          setState(() {
                            _isMasculino = value!;
                          });
                        },
                      ),
                      Text('Femenino'),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(width: 1.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(width: 1.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _aceptoTerminos,
                        onChanged: (value) {
                          setState(() {
                            _aceptoTerminos = value!;
                          });
                        },
                      ),
                      Text('Acepto los términos'),
                    ],
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _registrarUsuario,
                    child: Text('Registrar Usuario'),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 0, 105, 243),
                      textStyle: TextStyle(
                        fontSize: 18,
                        color:
                            Colors.white, // Aquí estableces el color del texto
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ));
  }
}
