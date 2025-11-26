import 'package:flutter/material.dart';
import 'package:app2/formularios/formulario_parqueadero.dart';
import 'package:app2/formularios/historial.dart';
import 'package:app2/formularios/registro_parqueo.dart';
import 'package:app2/servicios/registro_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app2/formularios/login_screen.dart';

class MenuPrincipal extends StatefulWidget {
  const MenuPrincipal({super.key});

  @override
  State<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  bool mostrarHistorial = false;
  List<Registro> registros = [];

  final GlobalKey<FormularioParqueaderoState> _formularioKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    cargarRegistros();
  }

  /// Carga registros desde la API
  Future<void> cargarRegistros() async {
    final lista = await RegistroService.cargar();
    if (!mounted) return; // ✅ seguridad
    setState(() {
      registros = lista;
      mostrarHistorial = registros.isNotEmpty;
    });
  }

  /// Registra un nuevo vehículo
  Future<void> registrarVehiculo(Registro nuevo) async {
    await RegistroService.guardar(nuevo); // 🔹 POST a la API
    if (!mounted) return;
    mostrarDialogo('Registro exitoso', nuevo.resumen());
    _formularioKey.currentState?.limpiarCampos();
    cargarRegistros(); // 🔹 recargar lista desde API
  }

  /// Valida duplicados por placa o identificación
  bool validarDuplicado(Registro nuevo) {
    final placaIgual = registros.any((r) => r.placa == nuevo.placa);
    final idIgual = registros.any(
      (r) => r.identificacion == nuevo.identificacion,
    );
    return placaIgual || idIgual;
  }

  /// Registra la salida de un vehículo
  Future<void> registrarSalida(Registro r) async {
    final horaActual = TimeOfDay.now().format(context);
    final salidaRegistrada = r.registrarSalida(horaActual);

    final mensaje = salidaRegistrada
        ? 'Salida registrada para ${r.placa}'
        : 'Este vehículo ya salió';

    if (salidaRegistrada) {
      await RegistroService.actualizar(r.placa, r); // 🔹 PUT a la API
      if (!mounted) return;
      cargarRegistros();
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  /// Cierra sesión y vuelve al login
  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adminLogueado', false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  /// Muestra un diálogo informativo
  void mostrarDialogo(String titulo, String mensaje) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Encabezado
          Container(
            height: 43,
            width: double.infinity,
            color: const Color.fromARGB(255, 37, 182, 68),
            alignment: Alignment.center,
            child: const Text(
              'Registro de vehículos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // Formulario
          Expanded(
            child: Center(
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 230, 221, 221),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FormularioParqueadero(
                  key: _formularioKey,
                  onGuardar: registrarVehiculo,
                  validarDuplicado: validarDuplicado,
                ),
              ),
            ),
          ),
          // Botón historial
          if (mostrarHistorial)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistorialParqueadero(
                        registros: registros,
                        onRegistrarSalida: registrarSalida,
                      ),
                    ),
                  );
                  if (!mounted) return;
                  cargarRegistros();
                },
                child: const Text('Ver historial'),
              ),
            ),
          // Botón cerrar sesión
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: cerrarSesion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 214, 230, 74),
              ),
              child: const Text('Cerrar sesión'),
            ),
          ),
        ],
      ),
    );
  }
}
