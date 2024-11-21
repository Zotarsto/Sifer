import 'package:flutter/material.dart';

class VentasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menú de Ventas'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Center(
        child: Text(
          '¡Bienvenido al sistema de ventas!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
