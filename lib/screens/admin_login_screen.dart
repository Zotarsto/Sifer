import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:http/http.dart' as http;

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _loginAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    final String correo = _emailController.text;
    final String contrasena = _passwordController.text;

    // Endpoint del backend
    final Uri url = Uri.parse("http://localhost:3000/api/admin/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "correo_electronico": correo,
          "contrasena": contrasena,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Login exitoso, redirigir a pantalla de inventario
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["mensaje"])),
        );
        Navigator.pushNamed(context, '/inventario');
      } else {
        // Manejo de errores
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error["mensaje"] ?? "Error en la autenticación")),
        );
      }
    } catch (e) {
      // Error de conexión o servidor
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título grande y subtítulo
              Container(
                padding: EdgeInsets.symmetric(vertical: 90),
                color: Colors.blueGrey.shade900,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SIFER',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Sistema Integral Ferretero',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Text(
                          "Acceso para Administradores",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade900,
                          ),
                        ),
                        SizedBox(height: 20),
                        // Campo de usuario
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Usuario',
                            prefixIcon: Icon(FeatherIcons.user),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese su usuario';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15),
                        // Campo de contraseña
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: Icon(FeatherIcons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese su contraseña';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: _loginAdmin,
                          icon: Icon(FeatherIcons.logIn, color: Colors.white),
                          label: Text(
                            "Ingresar",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey.shade900,
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/cajeroLogin');
                          },
                          child: Text(
                            '¿Eres Cajero? Ingresa aquí',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 98, 107, 120),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
