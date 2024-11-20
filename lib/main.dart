import 'package:flutter/material.dart';
//Importamos las screen que vamos a utilizar
import 'screens/create_product_screen.dart'; 
import 'screens/login_screen.dart';
import 'screens/inventory_screen.dart'; 
//Importamos el tema y los widgets que vamos a utilizar
import 'theme/app_theme.dart'; 
import 'widgets/menu_button.dart'; // Widget separado para el botón del menú

void main() {
  runApp(SiferApp());
}

class SiferApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIFER - Punto de Venta',
      theme: AppTheme.themeData,
      initialRoute: '/login',
      routes: {
        '/': (context) => SiferHome(),
        '/add-product': (context) => CreateProductScreen(),
        '/inventory': (context) => InventoryScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}

class SiferHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //Color del nvabar
        backgroundColor: const Color.fromARGB(255, 29, 136, 189),
        title: const Text(
          'SIFER',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Acción al presionar el icono de configuración
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('(0)', style: TextStyle(fontSize: 16)),
                MenuButton(
                  onMenuItemSelected: (value) {
                    if (value != null) {
                      if (value == 'añadir_producto') {
                        Navigator.pushNamed(context, '/add-product');
                      } else if (value == 'inventario') {
                        Navigator.pushNamed(context, '/inventory');
                      } else if (value == 'inicio_sesion') {
                        Navigator.pushNamed(context, '/login');
                      }
                      // Agrega más rutas según sea necesario
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: AppTheme.inputDecoration,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.sort_by_alpha),
                  onPressed: () {
                    // Acción para ordenar de A a Z
                  },
                ),
              ],
            ),
            const Spacer(),
            //Contenido del body de la pantalla principal
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 100,
                    color: const Color.fromARGB(255, 49, 65, 71).withOpacity(0.5),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Vacío',
                    style: TextStyle(
                      fontSize: 24,
                      color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción al presionar el botón de cámara
        },
        backgroundColor: const Color.fromARGB(255, 29, 136, 189),
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
