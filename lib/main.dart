import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app2/formularios/login_screen.dart';
import 'package:app2/formularios/menu_principal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final logueado = prefs.getBool('adminLogueado') ?? false;

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: logueado ? const MenuPrincipal() : const LoginScreen(),
    ),
  );
}
