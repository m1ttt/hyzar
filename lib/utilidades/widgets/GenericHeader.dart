import 'package:flutter/material.dart';
import 'package:hyzar/estilos/Colores.dart';
import 'package:hyzar/utilidades/backend/user_notifier.dart';
import 'package:provider/provider.dart';

class GenericHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool mostrarImagen;
  final BoxShadow boxShadow; // Añade esta línea
  final EdgeInsets padding; // Añade esta línea

  const GenericHeader({
    Key? key,
    required this.icon,
    required this.title,
    this.mostrarImagen = false,
    this.boxShadow = const BoxShadow(
      // Añade esta línea
      color: const Color(0x33000000),
      spreadRadius: 5,
      blurRadius: 7,
      offset: Offset(0, 3),
    ), // Añade esta línea
    this.padding = const EdgeInsets.only(
        top: 50, left: 10, right: 10, bottom: 2), // Añade esta línea
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        boxShadow: [boxShadow], // Cambia esta línea
      ),
      child: Padding(
        padding: padding, // Cambia esta línea
        child: Row(
          children: [
            Icon(
              icon,
              size: 60,
              color: Colores.verde,
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colores.verde,
              ),
            ),
            const Spacer(),
            if (mostrarImagen)
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Material(
                  elevation: 5.0,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: FileImage(
                        Provider.of<UserNotifier>(context).getImage()),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
