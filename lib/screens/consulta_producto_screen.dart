import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:http/http.dart' as http;

class ConsultaProductoScreen extends StatefulWidget {
  @override
  _ConsultaProductoScreenState createState() => _ConsultaProductoScreenState();
}

class _ConsultaProductoScreenState extends State<ConsultaProductoScreen> {
  List<Map<String, dynamic>> productos = [];
  List<Map<String, dynamic>> carrito = [];
  String query = '';

  @override
  void initState() {
    super.initState();
    _obtenerProductos(); // Carga inicial
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _obtenerProductos(); // Llamada al backend cada vez que se entra en la pantalla
  }

  Future<void> _obtenerProductos() async {
    final Uri url = Uri.parse("http://localhost:3000/api/productos");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          productos = List<Map<String, dynamic>>.from(data);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al obtener los productos")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  void _agregarAlCarrito(Map<String, dynamic> producto) {
    if (carrito.any((p) => p['id'] == producto['id'])) return;
    setState(() {
      carrito.add({...producto, 'cantidad': 1});
    });
  }

  void _eliminarDelCarrito(int id) {
    setState(() {
      carrito.removeWhere((producto) => producto['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productosFiltrados = productos
        .where((producto) =>
            producto['nombre'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            FeatherIcons.arrowLeft,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Productos",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Barra de búsqueda
            Container(
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Buscar producto",
                  prefixIcon: Icon(FeatherIcons.search, color: Colors.blue.shade900),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(15),
                ),
              ),
            ),
            // Lista de productos
            Expanded(
              child: productosFiltrados.isEmpty
                  ? Center(
                      child: Text(
                        "No se encontraron productos",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    )
                  : ListView.builder(
                      itemCount: productosFiltrados.length,
                      itemBuilder: (context, index) {
                        final producto = productosFiltrados[index];
                        final enCarrito =
                            carrito.any((p) => p['id'] == producto['id']);
                        final sinStock = producto['stock'] <= 0;

                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Opacity(
                            opacity: sinStock ? 0.5 : 1.0,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  Container(
                                    height: 60,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color: sinStock
                                          ? Colors.grey
                                          : Colors.blue.shade900,
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
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          producto['nombre'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          producto['descripcion'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "Precio: \$${producto['precio'].toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          FeatherIcons.plusCircle,
                                          color: sinStock || enCarrito
                                              ? Colors.grey
                                              : Colors.green,
                                        ),
                                        onPressed: sinStock || enCarrito
                                            ? null
                                            : () => _agregarAlCarrito(producto),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          FeatherIcons.trash,
                                          color: enCarrito ? Colors.red : Colors.grey,
                                        ),
                                        onPressed: enCarrito
                                            ? () => _eliminarDelCarrito(producto['id'])
                                            : null,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/ventas',
            arguments: carrito,
          );
        },
        backgroundColor: Colors.blue.shade900,
        child: Icon(
          FeatherIcons.shoppingCart,
          color: Colors.white,
        ),
      ),
    );
  }
}
