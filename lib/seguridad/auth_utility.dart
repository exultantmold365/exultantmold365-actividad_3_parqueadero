import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Genera el hash SHA-256 de una contraseña
String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

/// Compara dos cadenas en tiempo constante
bool compararSeguro(String a, String b) {
  if (a.length != b.length) return false;

  int resultado = 0;
  for (int i = 0; i < a.length; i++) {
    resultado |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return resultado == 0;
}
