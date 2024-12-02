import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

String _formatearFecha(String fechaISO) {
  try {
    final DateTime fecha = DateTime.parse(fechaISO);
    final DateFormat formatter = DateFormat('dd/MM/yyyy, hh:mm a');
    return formatter.format(fecha);
  } catch (e) {
    return 'Fecha inválida'; // En caso de error, muestra un mensaje por defecto
  }
}

class ConsultaVentasScreen extends StatefulWidget {
  @override
  _ConsultaVentasScreenState createState() => _ConsultaVentasScreenState();
}

class _ConsultaVentasScreenState extends State<ConsultaVentasScreen> {
  List<Map<String, dynamic>> ventas = [];
  String selectedInterval = "Diario"; // Intervalo por defecto
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _obtenerVentas(intervalo: selectedInterval.toLowerCase());
  }

  Future<void> _obtenerVentas({String? intervalo = "diario"}) async {
    setState(() {
      isLoading = true;
    });

    final Uri url =
        Uri.parse("http://localhost:3000/api/ventas?intervalo=$intervalo");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          ventas = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al obtener las ventas")),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _mostrarDetallesVenta(Map<String, dynamic> venta) async {
    final Uri url =
        Uri.parse("http://localhost:3000/api/ventas/${venta['id_venta']}");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final productos = jsonDecode(response.body);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetalleVentaScreen(
              venta: {...venta, 'productos': productos},
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al obtener los detalles de la venta")),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Consulta de Ventas",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade900,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                selectedInterval = value;
              });
              _obtenerVentas(intervalo: value.toLowerCase());
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "Diario",
                child: Text("Diario"),
              ),
              PopupMenuItem(
                value: "Mensual",
                child: Text("Mensual"),
              ),
              PopupMenuItem(
                value: "Anual",
                child: Text("Anual"),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Row(
                children: [
                  Text(
                    selectedInterval,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Icon(
                    FeatherIcons.chevronDown,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
        leading: IconButton(
          icon: Icon(
            FeatherIcons.arrowLeft,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.grey[200], // Fondo claro para mejor contraste
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blue.shade900,
              ),
            )
          : ventas.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      FeatherIcons.fileText,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 20),
                    Text(
                      "No hay ventas registradas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: ventas.length,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  itemBuilder: (context, index) {
                    final venta = ventas[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 10),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(15),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.blue.shade900,
                          child: Icon(
                            FeatherIcons.shoppingBag,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        title: Text(
                          "Venta #${venta['id_venta'] ?? 'N/A'}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            "Fecha: ${_formatearFecha(venta['fecha_venta'])}\nTotal: \$${venta['total'].toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        trailing: Icon(
                          FeatherIcons.chevronRight,
                          color: Colors.grey,
                        ),
                        onTap: () => _mostrarDetallesVenta(venta),
                      ),
                    );
                  },
                ),
    );
  }
}

class DetalleVentaScreen extends StatelessWidget {
  final Map<String, dynamic> venta;

  DetalleVentaScreen({required this.venta});

  String _formatearFecha(String fecha) {
    try {
      final DateTime dateTime = DateTime.parse(fecha);
      return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Fecha inválida";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List productos = venta['productos'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detalles de la Venta",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                "Venta #${venta['id_venta']}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
                ),
                SizedBox(height: 10),
                Text(
                "Fecha: ${_formatearFecha(venta['fecha_venta'])}",
                style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                Text(
                "Total: \$${venta['total'].toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                ),
              ],
              ),
            ),
            SizedBox(height: 25),
            Text(
              "Productos:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: productos.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          FeatherIcons.box,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 20),
                        Text(
                          "No se encontraron productos para esta venta",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      itemCount: productos.length,
                      itemBuilder: (context, index) {
                        final producto = productos[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 10),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              children: [
                                Container(
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
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "Cantidad: ${producto['cantidad']}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      Text(
                                        "Precio Unitario: \$${producto['precio']}",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "\$${(producto['cantidad'] * producto['precio']).toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}