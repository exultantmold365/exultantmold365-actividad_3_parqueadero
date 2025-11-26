import 'package:flutter/material.dart';
import 'registro_parqueo.dart';

class HistorialParqueadero extends StatelessWidget {
  final List<Registro> registros;
  final void Function(Registro) onRegistrarSalida;

  const HistorialParqueadero({
    super.key,
    required this.registros,
    required this.onRegistrarSalida,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Clientes')),
      body: registros.isEmpty
          ? const Center(
              child: Text(
                'No hay registros disponibles',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: registros.length,
              itemBuilder: (_, index) {
                final r = registros[index];
                final yaSalio = r.horaSalida.isNotEmpty;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                      r.nombrePropietario,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${r.resumen()}\n'
                      '${yaSalio ? "Estado: Salió a las ${r.horaSalida}" : "Estado: En parqueadero"}',
                    ),
                    trailing: yaSalio
                        ? const Icon(Icons.check, color: Colors.green)
                        : ElevatedButton(
                            onPressed: () => onRegistrarSalida(r),
                            child: const Text('Registrar salida'),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
