import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // <-- añadido

class AuthService {
  static const String baseUrl = 'http://localhost:8080/pyramid/auth';
  static const String _tokenKey = 'jwt_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    debugPrint('login response: ${response.body}'); // ahora antes de parsear

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);
      // buscar token en varias claves comunes
      final token = body['token'] ?? body['accessToken'] ?? body['jwt'] ?? body['access_token'];
      debugPrint('parsed token: $token'); // imprimir token después de obtenerlo
      if (token == null) {
        throw Exception('Login OK pero no se encontró token en la respuesta.');
      }
      await _storage.write(key: _tokenKey, value: token);
    } else {
      debugPrint('Login failed: ${response.statusCode} ${response.body}');
      throw Exception('Failed to login: ${response.statusCode} ${response.body}');
    }
  }

  Future<String?> getSavedToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Extrae la entidad/rol del payload del JWT y lo normaliza a 'STORE' o 'PLAYER'
  Future<String?> getEntityFromToken() async {
    final token = await getSavedToken();
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> map = jsonDecode(decoded);

      // Prioridad: role -> roles -> entity
      dynamic roleVal = map['role'] ?? map['roles'] ?? map['entity'];
      if (roleVal == null) return null;

      // role puede ser "ROLE_STORE" o ["ROLE_STORE"] u otros
      String roleStr;
      if (roleVal is List && roleVal.isNotEmpty) {
        roleStr = roleVal.first.toString();
      } else {
        roleStr = roleVal.toString();
      }

      // Normalizar: "ROLE_STORE" -> "STORE", "ROLE_PLAYER" -> "PLAYER"
      roleStr = roleStr.toUpperCase();
      if (roleStr.startsWith('ROLE_')) {
        roleStr = roleStr.substring(5);
      }

      // Si el backend usa 'STORE'/'PLAYER' ya queda bien; devolver la cadena final
      return roleStr;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getSavedToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    debugPrint('Headers sent: $headers');
    return headers;
  }

  // Cambiado: ahora usa "nickname" en el JSON (antes enviaba "username")
  Future<void> signupPlayer(String email, String password,String nickname) async {
    final url = Uri.parse('$baseUrl/signup/player');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'nickname': nickname,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to sign up player: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> signupStore(String email, String password, String nickname, String address) async {
    final url = Uri.parse('$baseUrl/signup/store');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'nickname': nickname,
        'address': address,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to sign up store: ${response.statusCode} ${response.body}');
    }
  }
}

