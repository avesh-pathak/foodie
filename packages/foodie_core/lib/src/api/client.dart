import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl, this.token});
  final String baseUrl;
  String? token;
  String? role;
  String? restaurantId;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<List<dynamic>> getList(String path) async {
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: _headers);
    if (res.statusCode != 200) throw Exception('GET $path failed: ${res.statusCode}');
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> getMap(String path) async {
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: _headers);
    if (res.statusCode != 200) throw Exception('GET $path failed: ${res.statusCode}');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(Uri.parse('$baseUrl$path'), headers: _headers, body: jsonEncode(body));
    if (res.statusCode >= 400) throw Exception('POST $path failed: ${res.statusCode} ${res.body}');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final res = await http.put(Uri.parse('$baseUrl$path'), headers: _headers, body: jsonEncode(body));
    if (res.statusCode >= 400) throw Exception('PUT $path failed: ${res.statusCode} ${res.body}');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> delete(String path) async {
    final res = await http.delete(Uri.parse('$baseUrl$path'), headers: _headers);
    if (res.statusCode >= 400) throw Exception('DELETE $path failed: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/login'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'username': username, 'password': password}));
    if (res.statusCode != 200) throw Exception('login failed');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    token = data['token'] as String;
    try {
      final me = await this.me();
      role = me['role'] as String?;
      restaurantId = me['restaurantId'] as String?;
    } catch (_) {
      // /auth/me may be unavailable; keep token-only session.
    }
    return data;
  }

  Future<Map<String, dynamic>> me() async {
    final res = await http.get(Uri.parse('$baseUrl/auth/me'), headers: _headers);
    if (res.statusCode != 200) throw Exception('GET /auth/me failed: ${res.statusCode}');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
