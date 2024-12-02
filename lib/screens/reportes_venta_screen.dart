import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:http/http.dart' as http;

class ReportesScreen extends StatefulWidget {
  @override
  _ReportesScreenState createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  bool isLoading = false;
  Map<String, dynamic>? reporte;
  String? selectedMonth;

  Future<void> _generarReporte(String mes) async {
    setState(() {
      isLoading = true;
      reporte = null;
    });

    final Uri url = Uri.parse("http://localhost:3000/api/reportes?mes=$mes");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ventasTotales'] == 0 || data.isEmpty) {
          _mostrarMensaje(
              "No hay ventas registradas para el mes seleccionado.");
        } else {
          setState(() {
            reporte = data;
          });
        }
      } else {
        _mostrarMensaje("Error al generar el reporte.");
      }
    } catch (e) {
      _mostrarMensaje("Error de conexión: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  String _formatearMes(String mes) {
    final meses = {
      "01": "Enero",
      "02": "Febrero",
      "03": "Marzo",
      "04": "Abril",
      "05": "Mayo",
      "06": "Junio",
      "07": "Julio",
      "08": "Agosto",
      "09": "Septiembre",
      "10": "Octubre",
      "11": "Noviembre",
      "12": "Diciembre",
    };
    return meses[mes] ?? "Mes desconocido";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Reportes de Ventas",
          style: TextStyle(
            fontSize: 25,
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Generar Reporte Mensual",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            SizedBox(height: 15),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Selecciona un mes",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(
                  FeatherIcons.calendar,
                  color: Colors.blue.shade900,
                ),
              ),
              value: selectedMonth,
              onChanged: (value) {
                setState(() {
                  selectedMonth = value;
                });
              },
              icon:
                  Container(), // Esto elimina el ícono desplegable por defecto del lado derecho
              items: [
                "01",
                "02",
                "03",
                "04",
                "05",
                "06",
                "07",
                "08",
                "09",
                "10",
                "11",
                "12"
              ]
                  .map((mes) => DropdownMenuItem(
                        value: mes,
                        child: Text(_formatearMes(mes)),
                      ))
                  .toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: selectedMonth != null
                ? () => _generarReporte(selectedMonth!)
                : null,
              icon: Icon(FeatherIcons.fileText, color: Colors.white),
              label: Text(
              "Generar Reporte",
              style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade900,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              ),
            ),
            SizedBox(height: 20),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (reporte != null)
              Expanded(
                child: SingleChildScrollView(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Card(
                      elevation: 4,
                      margin: EdgeInsets.only(bottom: 25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                          "Resumen del Mes",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                          ),
                          SizedBox(height: 10),
                          Text(
                          "Ventas Totales: \$${reporte!['ventasTotales'].toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                          Text(
                          "Total de Productos Vendidos: ${reporte!['totalProductosVendidos']}",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          ),
                        ],
                        ),
                      ),
                      ),
                      Text(
                        "Artículos Más Vendidos",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      SizedBox(height: 10),
                      reporte!['articulosMasVendidos'] != null &&
                              reporte!['articulosMasVendidos'].isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount:
                                  reporte!['articulosMasVendidos'].length,
                              itemBuilder: (context, index) {
                                final articulo =
                                    reporte!['articulosMasVendidos'][index];

                                return Card(
                                  margin: EdgeInsets.only(bottom: 10),
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      articulo['producto'] ??
                                          "Producto desconocido",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      "Cantidad Vendida: ${articulo['cantidadVendida'] ?? 0}\n"
                                      "Ventas: \$${(articulo['totalVentas'] ?? 0).toStringAsFixed(2)}",
                                    ),
                                    leading: Icon(
                                      FeatherIcons.tag,
                                      color: Colors.blue.shade900,
                                      size: 30,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                "No hay datos disponibles para los artículos más vendidos.",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                    ],
                  ),
                ),
              )
            else
              Center(
                child: Text(
                  "Selecciona un mes para generar un reporte",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
