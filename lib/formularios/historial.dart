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
      body: ListView.builder(
        itemCount: registros.length,
        itemBuilder: (_, index) {
          final r = registros[index];
          final yaSalio = r.horaSalida.isNotEmpty;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.nombrePropietario,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(r.resumen()),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        yaSalio ? 'Estado: Salió' : 'Estado: En parqueadero',
                        style: TextStyle(
                          color: yaSalio ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: yaSalio ? null : () => onRegistrarSalida(r),
                        child: const Text('Registrar salida'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
