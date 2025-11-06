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

  Future<void> cargarRegistros() async {
    final lista = await RegistroService.cargar();
    setState(() {
      registros = lista;
      mostrarHistorial = registros.isNotEmpty;
    });
  }

  void registrarVehiculo(Registro nuevo) {
    setState(() {
      registros.add(nuevo);
      mostrarHistorial = true;
    });

    RegistroService.guardar(registros);
    mostrarDialogo('Registro exitoso', nuevo.resumen());
    _formularioKey.currentState?.limpiarCampos();
  }

  bool validarDuplicado(Registro nuevo) {
    final placaIgual = registros.any((r) => r.placa == nuevo.placa);
    final idIgual = registros.any(
      (r) => r.identificacion == nuevo.identificacion,
    );
    return placaIgual || idIgual;
  }

  void registrarSalida(Registro r) {
    final horaActual = TimeOfDay.now().format(context);
    final salidaRegistrada = r.registrarSalida(horaActual);

    final mensaje = salidaRegistrada
        ? 'Salida registrada para ${r.placa}'
        : 'Este vehículo ya salió';

    if (salidaRegistrada) {
      RegistroService.guardar(registros);
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adminLogueado', false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void mostrarDialogo(String titulo, String mensaje) {
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
          Container(
            height: 43,
            width: double.infinity,
            color: const Color.fromARGB(255, 37, 182, 68),
            alignment: Alignment.center,
            child: const Text(
              'registro de vehiculos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
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

                  cargarRegistros(); // recarga la lista actualizada
                },
                child: const Text('Ver historial'),
              ),
            ),
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
