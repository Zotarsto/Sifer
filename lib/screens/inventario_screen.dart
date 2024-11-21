import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:http/http.dart' as http;

class InventarioScreen extends StatefulWidget {
  @override
  _InventarioScreenState createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  List<dynamic> productos = [];

  @override
  void initState() {
    super.initState();
    _obtenerProductos();
  }

  void _mostrarAlertaConfirmacion(BuildContext context, int productoId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirmar eliminación"),
        content: Text("¿Estás seguro de que deseas eliminar este producto?"),
        actions: [
          TextButton(
            child: Text("Cancelar"),
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
            },
          ),
          TextButton(
            child: Text("Eliminar", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo
              _eliminarProducto(productoId); // Llama a la función de eliminación
            },
          ),
        ],
      );
    },
  );
}


  // Obtener productos desde el backend
  Future<void> _obtenerProductos() async {
    final Uri url = Uri.parse("http://localhost:3000/api/productos");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          productos = data;
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

  // Eliminar producto desde el backend
  Future<void> _eliminarProducto(int id) async {
    final Uri url = Uri.parse("http://localhost:3000/api/productos/$id");

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Producto eliminado con éxito")),
        );
        _obtenerProductos(); // Actualizar la lista después de eliminar
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al eliminar el producto")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  void _irARegistrarProducto(BuildContext context) {
    Navigator.pushNamed(context, '/registroProducto').then((_) => _obtenerProductos());
  }

  void _menuSeleccionado(BuildContext context, String opcion) {
    if (opcion == 'ventas') {
      Navigator.pushNamed(context, '/ventas');
    } else if (opcion == 'cajeros') {
      Navigator.pushNamed(context, '/cajeroLogin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Inventario",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade900,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              FeatherIcons.menu,
              color: Colors.white,
            ),

            onSelected: (opcion) => _menuSeleccionado(context, opcion),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'ventas',
                child: Text('Ir a Ventas'),
              ),
              PopupMenuItem(
                value: 'cajeros',
                child: Text('Ir a Cajeros'),
              ),
            ],
          ),
        ],
        leading: IconButton(
          icon: Icon(
            FeatherIcons.arrowLeft,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context); // Retrocede a la pantalla anterior
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: productos.isEmpty
            ? Center(
                child: Text(
                  "No hay productos disponibles",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              )
            : ListView.builder(
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final producto = productos[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(
                        FeatherIcons.box,
                        color: Colors.blue.shade900,
                      ),
                      title: Text(
                        producto['nombre'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Descripción: ${producto['descripcion']}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                          Text(
                            'Precio: \$${producto['precio'].toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                          Text(
                            'Stock: ${producto['stock']} unidades',
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          FeatherIcons.trash,
                          color: Colors.red,
                        ),
                        onPressed: () => _mostrarAlertaConfirmacion(context, producto['id']),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _irARegistrarProducto(context),
        backgroundColor: Colors.blue.shade900,
        child: Icon(
          FeatherIcons.plusCircle,
          color: Colors.white,
        ),
      ),
    );
  }
}
