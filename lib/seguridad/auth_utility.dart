import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Genera el hash SHA-256 de una contraseña.
/// Opcional: se puede añadir un 'salt' para mayor seguridad.
String hashPassword(String password, {String salt = ''}) {
  final bytes = utf8.encode(password + salt);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

/// Compara dos cadenas en tiempo constante para evitar ataques de timing.
bool compararSeguro(String a, String b) {
  if (a.length != b.length) return false;

  int resultado = 0;
  for (int i = 0; i < a.length; i++) {
    resultado |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return resultado == 0;
}

/// Genera un HMAC-SHA256 de la contraseña usando una clave secreta.
/// Útil para escenarios donde se requiere autenticación más robusta.
String hmacPassword(String password, String secretKey) {
  final key = utf8.encode(secretKey);
  final hmacSha256 = Hmac(sha256, key);
  final digest = hmacSha256.convert(utf8.encode(password));
  return digest.toString();
}
