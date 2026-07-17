import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  bool get _hasServer => AppConfig.hasServer;

  String get _baseUrl => AppConfig.serverUrl!;

  Future<Map<String, dynamic>> login(String email, String password) async {
    if (!_hasServer) return {'token': null, 'user': null};
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Login failed: ${response.body}');
    }
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    if (!_hasServer) return {'token': null, 'user': null};
    final response = await _client.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode != 200) {
      throw Exception('Register failed: ${response.body}');
    }
    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getMarketplaceCategories() async {
    if (!_hasServer) return [];
    final response =
        await _client.get(Uri.parse('$_baseUrl/marketplace/categories'));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getMarketplaceFeeds(
      String category, int page, int limit) async {
    if (!_hasServer) return {'feeds': [], 'total': 0};
    final response = await _client.get(
      Uri.parse(
          '$_baseUrl/marketplace/feeds?category=$category&page=$page&limit=$limit'),
    );
    return jsonDecode(response.body);
  }

  Future<String> proxyFeed(String url) async {
    if (!_hasServer) throw StateError('Proxy requires a configured server.');
    final response = await _client.get(Uri.parse('$_baseUrl/proxy/feed?url=$url'));
    return response.body;
  }

  Future<Map<String, dynamic>> syncState(
    String token, {
    required List<String> read,
    required List<String> starred,
  }) async {
    if (!_hasServer) return {};
    final response = await _client.post(
      Uri.parse('$_baseUrl/sync/state'),
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
    if (!_hasServer) return {'changes': []};
    final uri = Uri.parse('$_baseUrl/sync/changes').replace(queryParameters: {
      if (lastSync != null) 'lastSync': lastSync,
    });
    final response =
        await _client.get(uri, headers: {'Authorization': 'Bearer $token'});
    return jsonDecode(response.body);
  }
}
