import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:http/http.dart' as http;

class ConfirmacionVentaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> argumentos =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final cajero = argumentos['cajero'] as Map<String, dynamic>;
    final productos = argumentos['productos'] as List<Map<String, dynamic>>;

    // Calcula el total
    final total = productos.fold<double>(
      0,
      (sum, producto) => sum + (producto['cantidad'] * producto['precio']),
    );

    Future<void> _confirmarVenta() async {
      final Uri url = Uri.parse('http://localhost:3000/api/ventas');
      final body = {
        'id_cajero': cajero['id'],
        'total': total,
        'productos': productos.map((producto) {
          return {
            'id_producto': producto['id'],
            'cantidad': producto['cantidad'],
            'precio': producto['precio'],
          };
        }).toList(),
      };

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        if (response.statusCode == 201) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('¡Venta Exitosa!'),
              content: Text(
                'La venta ha sido registrada correctamente.\n\n'
                'El total de la venta es de \$${total.toStringAsFixed(2)}.\n\n'
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Cierra el diálogo
                    Navigator.popUntil(
                      context,
                      ModalRoute.withName('/consultaProducto'),
                    ); // Regresa al menú principal
                  },
                  child: Text(
                    'Regresar al Menu de Ventas',
                    style: TextStyle(color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          );

          // Muestra una alerta de confirmación
        } else {
          final error = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Error: ${error['mensaje'] ?? 'No se pudo registrar la venta'}",
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error de conexión: $e")),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Confirmación de Venta",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade900,
        leading: IconButton(
          icon: Icon(
            FeatherIcons.arrowLeft,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context); // Regresa a la pantalla anterior
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resumen de la venta
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Resumen de la Venta",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Lista de productos
            Text(
              "Productos en el carrito:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: productos.isEmpty
                  ? Center(
                      child: Text(
                        "No hay productos en el carrito",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    )
                  : ListView.builder(
                      itemCount: productos.length,
                      itemBuilder: (context, index) {
                        final producto = productos[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade900,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  FeatherIcons.box,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                            title: Text(
                              producto['nombre'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cantidad: ${producto['cantidad']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  'Precio unitario: \$${producto['precio'].toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              '\$${(producto['cantidad'] * producto['precio']).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Divider(),
            // Total de la venta
            Text(
              "Total: \$${total.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
              textAlign: TextAlign.end,
            ),
            SizedBox(height: 20),

            // Botón Confirmar Venta
            ElevatedButton.icon(
              onPressed: _confirmarVenta,
              icon: Icon(
                FeatherIcons.checkCircle,
                color: Colors.white,
              ),
              label: Text(
                "Confirmar Venta",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
