import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app2/formularios/registro_parqueo.dart';

class RegistroService {
  static const String baseUrl = 'http://localhost:3000/registros';

  /// Obtiene todos los registros desde la API
  static Future<List<Registro>> cargar() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Registro.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar registros');
    }
  }

  /// Guarda un nuevo registro en la API (POST)
  static Future<void> guardar(Registro registro) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(registro.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al guardar registro');
    }
  }

  /// Actualiza un registro existente en la API (PUT)
  static Future<void> actualizar(String placa, Registro registro) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$placa'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(registro.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar registro');
    }
  }

  /// Elimina un registro de la API (DELETE)
  static Future<void> eliminar(String placa) async {
    final response = await http.delete(Uri.parse('$baseUrl/$placa'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar registro');
    }
  }

  /// Exporta todos los registros como JSON (útil para respaldos)
  static Future<String> exportarComoJson() async {
    final registros = await cargar();
    final listaMap = registros.map((r) => r.toJson()).toList();
    return jsonEncode(listaMap);
  }
}
