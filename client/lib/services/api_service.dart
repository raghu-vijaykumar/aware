import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://localhost:4000'; // Update for production

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Login failed: ${response.body}');
    }
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Register failed: ${response.body}');
    }
    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getMarketplaceCategories() async {
    final response =
        await http.get(Uri.parse('$baseUrl/marketplace/categories'));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getMarketplaceFeeds(
      String category, int page, int limit) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/marketplace/feeds?category=$category&page=$page&limit=$limit'),
    );
    return jsonDecode(response.body);
  }

  Future<String> proxyFeed(String url) async {
    final response = await http.get(Uri.parse('$baseUrl/proxy/feed?url=$url'));
    return response.body;
  }

  Future<Map<String, dynamic>> syncState(
    String token, {
    required List<String> read,
    required List<String> starred,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sync/state'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'read': read, 'starred': starred}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getSyncChanges(String token,
      {String? lastSync}) async {
    final uri = Uri.parse('$baseUrl/sync/changes').replace(queryParameters: {
      if (lastSync != null) 'lastSync': lastSync,
    });
    final response =
        await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    return jsonDecode(response.body);
  }
}
