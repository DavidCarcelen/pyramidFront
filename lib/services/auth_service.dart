import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);
      final token = body['token'] ?? body['accessToken'];
      if (token == null) {
        throw Exception('Login OK pero no se encontró token en la respuesta.');
      }
      await _storage.write(key: _tokenKey, value: token);
    } else {
      throw Exception('Failed to login: ${response.statusCode} ${response.body}');
    }
  }

  Future<String?> getSavedToken() async {
    return await _storage.read(key: _tokenKey);
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
    return headers;
  }

  Future<void> signupPlayer(String username, String email, String password) async {
    final url = Uri.parse('$baseUrl/signup/player');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to sign up player: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> signupStore(String storeName, String email, String password, String address) async {
    final url = Uri.parse('$baseUrl/signup/store');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'storeName': storeName,
        'email': email,
        'password': password,
        'address': address,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to sign up store: ${response.statusCode} ${response.body}');
    }
  }
}

