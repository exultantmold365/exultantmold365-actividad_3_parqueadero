import 'package:flutter/material.dart';
import 'package:app2/formularios/registro_parqueo.dart';

class FormularioParqueadero extends StatefulWidget {
  final void Function(Registro) onGuardar;
  final bool Function(Registro)? validarDuplicado;

  const FormularioParqueadero({
    super.key,
    required this.onGuardar,
    this.validarDuplicado,
  });

  @override
  State<FormularioParqueadero> createState() => FormularioParqueaderoState();
}

class FormularioParqueaderoState extends State<FormularioParqueadero> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  String? tipoSeleccionado;
  Registro registro = Registro.vacio();

  @override
  void initState() {
    super.initState();
    _placaController.addListener(() {
      final texto = Registro.normalizarPlaca(_placaController.text);
      _placaController.text = texto;
      _placaController.selection = TextSelection.collapsed(
        offset: texto.length,
      );
      registro.placa = texto;
    });
  }

  void limpiarCampos() {
    setState(() {
      registro = Registro.vacio();
      tipoSeleccionado = null;
      _placaController.clear();
      _modeloController.clear();
      _colorController.clear();
      _nombreController.clear();
      _idController.clear();
    });
  }

  @override
  void dispose() {
    _placaController.dispose();
    _modeloController.dispose();
    _colorController.dispose();
    _nombreController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: _nombreController,
            decoration: const InputDecoration(
              labelText: 'Nombre del conductor',
            ),
            onChanged: (value) => registro.nombrePropietario = value,
            validator: (value) =>
                value == null || value.isEmpty ? 'Campo obligatorio' : null,
          ),
          TextFormField(
            controller: _idController,
            decoration: const InputDecoration(labelText: 'Identificación'),
            onChanged: (value) => registro.identificacion = value,
            validator: (value) =>
                value == null || value.isEmpty ? 'Campo obligatorio' : null,
          ),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Tipo de vehículo'),
            initialValue: tipoSeleccionado,
            items: ['Moto', 'Carro']
                .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                .toList(),
            onChanged: (value) {
              setState(() {
                tipoSeleccionado = value;
                registro.tipoVehiculo = value ?? '';
              });
            },
            validator: (value) =>
                value == null || value.isEmpty ? 'Seleccione un tipo' : null,
          ),
          TextFormField(
            controller: _placaController,
            decoration: const InputDecoration(labelText: 'Placa'),
            maxLength: 8,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Campo obligatorio';
              if (registro.tipoVehiculo.isEmpty) {
                return 'Seleccione el tipo de vehículo antes de ingresar la placa';
              }
              if (!registro.placaValida()) {
                return 'Formato inválido para ${registro.tipoVehiculo.toLowerCase()}';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _modeloController,
            decoration: const InputDecoration(labelText: 'Modelo'),
            onChanged: (value) => registro.modelo = value,
          ),
          TextFormField(
            controller: _colorController,
            decoration: const InputDecoration(labelText: 'Color'),
            onChanged: (value) => registro.color = value,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            child: const Text('Registrar ingreso'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                registro.horaIngreso = TimeOfDay.now().format(context);

                if (widget.validarDuplicado != null &&
                    widget.validarDuplicado!(registro)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Ya existe un registro con esta placa o identificación',
                      ),
                    ),
                  );
                  return;
                }

                widget.onGuardar(registro);
              }
            },
          ),
        ],
      ),
    );
  }
}
