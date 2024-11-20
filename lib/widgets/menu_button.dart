import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final void Function(String?) onMenuItemSelected;

  const MenuButton({Key? key, required this.onMenuItemSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showMenu(
          context: context,
          position: const RelativeRect.fromLTRB(100, 100, 0, 0),
          items: const [
            PopupMenuItem(
              value: 'añadir_producto',
              child: ListTile(
                leading: Icon(Icons.add_circle_outline),
                title: Text('Añadir producto'),
              ),
            ),
            PopupMenuItem(
              value: 'inventario',
              child: ListTile(
                leading: Icon(Icons.inventory),
                title: Text('Inventario'),
              ),
            ),
            PopupMenuItem(
              value: 'inicio_sesion',
              child: ListTile(
                leading: Icon(Icons.login),
                title: Text('Inicio de sesión'),
              ),
            ),
            PopupMenuItem(
              value: 'ventas',
              child: ListTile(
                leading: Icon(Icons.point_of_sale),
                title: Text('Ventas'),
              ),
            ),
          ],
        ).then(onMenuItemSelected);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blueGrey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 5),
            Text('Acciones', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
