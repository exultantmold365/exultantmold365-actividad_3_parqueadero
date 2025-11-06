import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app2/formularios/menu_principal.dart';
import 'package:app2/seguridad/auth_utility.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _claveController = TextEditingController();

  @override
  void initState() {
    super.initState();
    verificarSesion();
  }

  Future<void> verificarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final logueado = prefs.getBool('adminLogueado') ?? false;

    if (mounted && logueado) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MenuPrincipal()),
      );
    }
  }

  Future<void> guardarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adminLogueado', true);
  }

  void validarCredenciales() async {
    final usuario = _usuarioController.text.trim();
    final clave = _claveController.text.trim();
    final claveHash = hashPassword(clave);

    const hashAdmin =
        '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4'; // SHA-256 de "1234"

    if (usuario == 'admin' && compararSeguro(claveHash, hashAdmin)) {
      await guardarSesion();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MenuPrincipal()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales incorrectas')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ingreso al Parqueadero',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usuarioController,
                  decoration: const InputDecoration(labelText: 'Usuario'),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obligatorio'
                      : null,
                ),
                TextFormField(
                  controller: _claveController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obligatorio'
                      : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      validarCredenciales();
                    }
                  },
                  child: const Text('Ingresar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
