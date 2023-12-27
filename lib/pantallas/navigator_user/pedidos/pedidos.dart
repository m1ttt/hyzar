import 'package:flutter/material.dart';

class PantallaPedidos extends StatelessWidget {
  const PantallaPedidos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: const Center(child: Text('Current Pedidos')),
      ),
    );
  }
}
