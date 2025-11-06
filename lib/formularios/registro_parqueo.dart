class Registro {
  String placa;
  String modelo;
  String color;
  String horaIngreso;
  String horaSalida;
  String nombrePropietario;
  String identificacion;
  String tipoVehiculo;

  Registro({
    required String placa,
    required this.modelo,
    required this.color,
    this.horaSalida = '',
    required this.horaIngreso,
    required this.nombrePropietario,
    required this.identificacion,
    required this.tipoVehiculo,
  }) : placa = normalizarPlaca(placa);

  /// Constructor vacío para formularios
  factory Registro.vacio() => Registro(
    placa: '',
    modelo: '',
    color: '',
    horaIngreso: '',
    nombrePropietario: '',
    identificacion: '',
    tipoVehiculo: '',
  );

  /// Serializa el objeto a un mapa JSON
  Map<String, dynamic> toJson() => {
    'placa': placa,
    'modelo': modelo,
    'color': color,
    'horaIngreso': horaIngreso,
    'horaSalida': horaSalida,
    'nombrePropietario': nombrePropietario,
    'identificacion': identificacion,
    'tipoVehiculo': tipoVehiculo,
  };

  /// Crea un objeto Registro desde un mapa JSON
  factory Registro.fromJson(Map<String, dynamic> json) => Registro(
    placa: json['placa'] ?? '',
    modelo: json['modelo'] ?? '',
    color: json['color'] ?? '',
    horaIngreso: json['horaIngreso'] ?? '',
    horaSalida: json['horaSalida'] ?? '',
    nombrePropietario: json['nombrePropietario'] ?? '',
    identificacion: json['identificacion'] ?? '',
    tipoVehiculo: json['tipoVehiculo'] ?? '',
  );

  /// Normaliza la placa: mayúsculas, sin espacios, con guion
  static String normalizarPlaca(String input) {
    String texto = input.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (texto.length > 6) {
      texto = texto.substring(0, 6);
    }
    if (texto.length >= 6) {
      texto = '${texto.substring(0, 3)}-${texto.substring(3)}';
    }
    return texto;
  }

  /// Valida el formato de la placa según el tipo de vehículo
  bool placaValida() {
    final motoRegex = RegExp(r'^[A-Z]{3}-\d{2}[A-Z]$'); // Ej: ABC-12D
    final carroRegex = RegExp(r'^[A-Z]{3}-\d{3}$'); // Ej: ABC-123

    if (tipoVehiculo.toLowerCase() == 'moto') {
      return motoRegex.hasMatch(placa);
    }

    if (tipoVehiculo.toLowerCase() == 'carro') {
      return carroRegex.hasMatch(placa);
    }

    return false;
  }

  /// Compara carácter por carácter con otra placa
  bool esSimilarA(Registro otro) {
    final p1 = placa.replaceAll('-', '');
    final p2 = otro.placa.replaceAll('-', '');

    if (p1.length != p2.length) return false;

    int coincidencias = 0;
    for (int i = 0; i < p1.length; i++) {
      if (p1[i] == p2[i]) coincidencias++;
    }

    return coincidencias >= 5; // umbral configurable
  }

  /// Registra la hora de salida si no ha sido registrada
  bool registrarSalida(String hora) {
    if (horaSalida.isEmpty) {
      horaSalida = hora;
      return true;
    }
    return false;
  }

  /// Genera resumen para mostrar en historial
  String resumen() {
    return 'Placa: $placa\nTipo: $tipoVehiculo\nIngreso: $horaIngreso\nSalida: ${horaSalida.isEmpty ? "Pendiente" : horaSalida}';
  }
}
