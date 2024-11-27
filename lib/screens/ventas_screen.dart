import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class VentasScreen extends StatefulWidget {
  @override
  _VentasScreenState createState() => _VentasScreenState();
}

class _VentasScreenState extends State<VentasScreen> {
  late List<Map<String, dynamic>> carrito;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    carrito = ModalRoute.of(context)!.settings.arguments
        as List<Map<String, dynamic>>;
  }

  void _mostrarAlertaStockInsuficiente() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('¡Lo sentimos!'),
          content: Text(
            'No tenemos suficiente stock para añadir más de este producto. '
            'Por favor, reduce la cantidad o elige otro producto.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el cuadro de diálogo
              },
              child: Text(
                'Entendido',
                style: TextStyle(color: Colors.blue.shade900),
              ),
            ),
          ],
        );
      },
    );
  }

  void _incrementarCantidad(int id) {
    setState(() {
      final producto = carrito.firstWhere((producto) => producto['id'] == id);

      if (producto['cantidad'] < producto['stock']) {
        producto['cantidad']++;
      } else {
        _mostrarAlertaStockInsuficiente();
      }
    });
  }

  void _decrementarCantidad(int id) {
    setState(() {
      final producto = carrito.firstWhere((producto) => producto['id'] == id);
      if (producto['cantidad'] > 1) {
        producto['cantidad']--;
      }
    });
  }

  double _calcularTotal() {
    return carrito.fold(
      0.0,
      (total, producto) => total + (producto['precio'] * producto['cantidad']),
    );
  }

  int _calcularCantidadTotal() {
    return carrito.fold(
      0,
      (total, producto) => total + (producto['cantidad'] as int),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalCantidad = _calcularCantidadTotal();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            FeatherIcons.arrowLeft,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context); // Retrocede a la pantalla anterior
          },
        ),
        title: Text(
          "Carrito de Ventas",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: carrito.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FeatherIcons.shoppingCart,
                      size: 80,
                      color: Colors.blue.shade900,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Tu carrito está vacío",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Agrega productos para continuar con la compra.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: carrito.length,
                      itemBuilder: (context, index) {
                        final producto = carrito[index];
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(9.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade900,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      FeatherIcons.box,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        producto['nombre'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Precio: \$${producto['precio'].toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: const Color.fromARGB(255, 68, 68, 68),
                                        ),
                                      ),
                                      Text(
                                        'Descripción: ${producto['descripcion']}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: const Color.fromARGB(255, 92, 92, 92),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        FeatherIcons.plusCircle,
                                        color: Colors.green,
                                      ),
                                      onPressed: () =>
                                          _incrementarCantidad(producto['id']),
                                    ),
                                    Text(
                                      '${producto['cantidad']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        FeatherIcons.minusCircle,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _decrementarCantidad(producto['id']),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(),
                  Text(
                    'Total: \$${_calcularTotal().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  Text(
                    'Productos diferentes: ${carrito.length} '
                    '(${totalCantidad} unidades totales)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/confirmacionVenta',
                        arguments: {
                          'cajero': {
                            'id': 1,
                            'nombre': 'Nombre del Cajero',
                          },
                          'productos': carrito,
                        },
                      );
                    },
                    child: Text(
                      "Confirmar Venta",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
