import 'package:flutter/material.dart';
import 'screens/admin_login_screen.dart';
import 'screens/cajero_login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/ventas_screen.dart';
import 'screens/inventario_screen.dart';
import 'screens/registro_producto_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      initialRoute: '/cajeroLogin',
      routes: {
        '/cajeroLogin': (context) => CajeroLoginScreen(),
        '/registerCajero': (context) => RegisterScreen(),
        '/adminAccess': (context) => AdminLoginScreen(),
        '/ventas': (context) => VentasScreen(),
        '/inventario': (context) => InventarioScreen(),
        '/registroProducto': (context) => RegistroProductoScreen(),
      },
    );
  }
}
