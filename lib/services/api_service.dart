import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String _baseUrl;

  ApiService()
    // : _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
    : _baseUrl = 'https://pawhealth-backend-184555083635.us-central1.run.app/api';

  Future<dynamic> get(String endpoint, {String? token}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    print('API RESPONSE FOR VETS: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to load $endpoint: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
    String? token,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create $endpoint: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
    String? token,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update $endpoint: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  Future<void> delete(String endpoint, String? token) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete $endpoint: ${response.body}');
    }
  }
  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body,
    String? token,
  ) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to patch $endpoint: ${response.body}');
    }

    if (response.body.isEmpty) return {};
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> multipartPost(
    String endpoint,
    String? token, {
    Map<String, String>? fields,
    http.MultipartFile? file,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl$endpoint'));
    
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';

    if (fields != null) {
      request.fields.addAll(fields);
    }
    if (file != null) {
      request.files.add(file);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed multipart request $endpoint: ${response.body}');
    }

    if (response.body.isEmpty) return {};
    return jsonDecode(response.body);
  }
}
