import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:http/http.dart' as http;

class RegistroProductoScreen extends StatefulWidget {
  @override
  _RegistroProductoScreenState createState() => _RegistroProductoScreenState();
}

class _RegistroProductoScreenState extends State<RegistroProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  Map<String, dynamic>? producto; // Para editar producto

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Obtiene los datos del producto si fueron enviados
    producto = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (producto != null) {
      _nombreController.text = producto!['nombre'];
      _descripcionController.text = producto!['descripcion'];
      _precioController.text = producto!['precio'].toString();
      _stockController.text = producto!['stock'].toString();
    }
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    final String nombre = _nombreController.text;
    final String descripcion = _descripcionController.text;
    final double? precio = double.tryParse(_precioController.text);
    final int? stock = int.tryParse(_stockController.text);

    if (precio == null || stock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Precio o stock no válido")),
      );
      return;
    }

    final Uri url = producto == null
        ? Uri.parse("http://localhost:3000/api/productos") // Crear nuevo producto
        : Uri.parse("http://localhost:3000/api/productos/${producto!['id']}"); // Actualizar producto existente

    try {
      final response = await (producto == null
          ? http.post(
              url,
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "nombre": nombre,
                "descripcion": descripcion,
                "precio": precio,
                "stock": stock,
              }),
            )
          : http.put(
              url,
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                "nombre": nombre,
                "descripcion": descripcion,
                "precio": precio,
                "stock": stock,
              }),
            ));

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(producto == null ? "Producto registrado con éxito" : "Producto actualizado con éxito")),
        );
        Navigator.pop(context);
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error["mensaje"] ?? "Error al guardar el producto")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String titulo = producto == null ? "Registrar Producto" : "Editar Producto";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titulo,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade900,
        leading: IconButton(
          icon: Icon(FeatherIcons.arrowLeft, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del Producto',
                    prefixIcon: Icon(FeatherIcons.box),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre del producto es obligatorio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _descripcionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(FeatherIcons.fileText),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La descripción es obligatoria';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _precioController,
                  decoration: InputDecoration(
                    labelText: 'Precio',
                    prefixIcon: Icon(FeatherIcons.dollarSign),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El precio es obligatorio';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Ingrese un precio válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _stockController,
                  decoration: InputDecoration(
                    labelText: 'Stock',
                    prefixIcon: Icon(FeatherIcons.archive),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El stock es obligatorio';
                    }
                    if (int.tryParse(value) == null || int.parse(value) < 0) {
                      return 'Ingrese un stock válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _guardarProducto,
                  icon: Icon(
                    producto == null ? FeatherIcons.plusCircle : FeatherIcons.save,
                    color: Colors.white,
                  ),
                  label: Text(
                    producto == null ? "Registrar Producto" : "Guardar Cambios",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}