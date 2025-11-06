import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app2/formularios/registro_parqueo.dart';

class RegistroService {
  static const String clave = 'registrosParqueo';

  static Future<void> guardar(List<Registro> registros) async {
    final prefs = await SharedPreferences.getInstance();
    final listaJson = registros.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(clave, listaJson);
  }

  static Future<List<Registro>> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final listaJson = prefs.getStringList(clave) ?? [];
    return listaJson.map((jsonStr) {
      final map = jsonDecode(jsonStr);
      return Registro.fromJson(map);
    }).toList();
  }

  static Future<void> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(clave);
  }

  static Future<String> exportarComoJson() async {
    final registros = await cargar();
    final listaMap = registros.map((r) => r.toJson()).toList();
    return jsonEncode(listaMap);
  }
}
