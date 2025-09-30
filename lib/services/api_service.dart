import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://ec2-18-207-118-50.compute-1.amazonaws.com:8080';

  static Future<Map<String, dynamic>> _getUserDataAndToken() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString == null) {
      throw Exception('No hay datos de usuario en memoria local');
    }
    final userData = jsonDecode(userDataString);
    final token = userData['token'];
    if (token == null) {
      throw Exception('Falta token de autorización');
    }
    return {'token': token, 'userData': userData};
  }

  static Uri _buildUrl(String endpoint, {String? id, Map<String, dynamic>? queryParams}) {
    final String fullEndpoint = '$_baseUrl$endpoint${id != null ? '/$id' : ''}';

    if (queryParams != null && queryParams.isNotEmpty) {
      return Uri.parse(fullEndpoint).replace(queryParameters: queryParams);
    }

    return Uri.parse(fullEndpoint);
  }

  static Future<dynamic> getWithAuth({
    required String endpoint,
    String? id,
    Map<String, dynamic>? queryParams,
  }) async {
    final data = await _getUserDataAndToken();
    final token = data['token'];

    final url = _buildUrl(endpoint, id: id, queryParams: queryParams);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=utf-8', // Añade charset
      },
    );

    debugPrint(url.toString());
    debugPrint("Response body: ${response.body}"); // Para diagnóstico

    if (response.statusCode == 200) {
      // Fuerza la codificación UTF-8 al decodificar
      return jsonDecode(utf8.decode(response.bodyBytes)); // Usa bodyBytes en lugar de body
    } else if (response.statusCode == 204) {
      return <dynamic>[];
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Error en GET');
    }
  }

  static Future<Map<String, dynamic>> postWithAuth({
    required String endpoint,
    Map<String, dynamic>? body,
    String? id,
  }) async {
    final data = await _getUserDataAndToken();
    final token = data['token'];
    debugPrint('Todas las respuestas: ${token}');

    final url = _buildUrl(endpoint, id: id);
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body ?? {}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Error en POST');
    }
  }

  static Future<Map<String, dynamic>> putWithAuth({
    required String endpoint,
    required Map<String, dynamic> body,
    String? id,
  }) async {
    final data = await _getUserDataAndToken();
    final token = data['token'];

    final url = _buildUrl(endpoint, id: id);
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Error en PUT');
    }
  }

  static Future<void> deleteWithAuth({
    required String endpoint,
    String? id,
  }) async {
    final data = await _getUserDataAndToken();
    final token = data['token'];

    final url = _buildUrl(endpoint, id: id);
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Error en DELETE');
    }
  }
  static Future<dynamic> postWithoutAuth({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en la conexión: $e');
    }
  }
}
