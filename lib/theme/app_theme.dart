import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Colors.blueGrey;

  static final themeData = ThemeData(
    primarySwatch: Colors.blueGrey,
    scaffoldBackgroundColor: Colors.white,
  );

  static final inputDecoration = InputDecoration(
    prefixIcon: const Icon(Icons.filter_list),
    suffixIcon: const Icon(Icons.close),
    labelText: 'Buscar',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
  );
}
