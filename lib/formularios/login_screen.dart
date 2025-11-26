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

  bool _ocultarClave = true; // Control para mostrar/ocultar contraseña
  bool _cargando = false; // Indicador de carga

  @override
  void initState() {
    super.initState();
    verificarSesion();
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _claveController.dispose();
    super.dispose();
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

  Future<void> validarCredenciales() async {
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
        final mensaje = usuario != 'admin'
            ? 'Usuario no válido'
            : 'Contraseña incorrecta';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text(mensaje),
              ],
            ),
            backgroundColor: Colors.red,
          ),
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
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ocultarClave ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _ocultarClave = !_ocultarClave;
                        });
                      },
                    ),
                  ),
                  obscureText: _ocultarClave,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.visiblePassword,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Campo obligatorio'
                      : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _cargando = true);
                      await validarCredenciales();
                      setState(() => _cargando = false);
                    }
                  },
                  child: _cargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Ingresar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
