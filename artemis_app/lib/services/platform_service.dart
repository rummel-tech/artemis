import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_services/shared_services.dart';
import '../config/app_config.dart';
import '../models/module.dart';
import '../models/widget_data.dart';

/// Service for the Artemis platform API (modules, dashboard, agent chat).
///
/// Uses shared [TokenStorage] for authentication and [ApiException] for
/// structured error handling. Raw [http.Client] is used directly because
/// several platform endpoints return JSON arrays which [BaseApiClient]
/// doesn't support out-of-the-box.
class PlatformService {
  final TokenStorage _storage;
  final ApiConfig _config;
  final http.Client _httpClient;

  PlatformService({
    required TokenStorage storage,
    ApiConfig? config,
    http.Client? httpClient,
  })  : _storage = storage,
        _config = config ?? AppConfig.platformConfig,
        _httpClient = httpClient ?? http.Client();

  Future<Map<String, String>> _headers() async {
    final token = await _storage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<ArtemisModule>> getModules() async {
    final headers = await _headers();
    final r = await _httpClient.get(
      Uri.parse('${_config.baseUrl}/modules'),
      headers: headers,
    );
    if (r.statusCode != 200) throw ApiException.fromResponse(r);
    final list = jsonDecode(r.body) as List;
    return list
        .map((j) => ArtemisModule.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getDashboard() async {
    final headers = await _headers();
    final r = await _httpClient.get(
      Uri.parse('${_config.baseUrl}/dashboard'),
      headers: headers,
    );
    if (r.statusCode != 200) throw ApiException.fromResponse(r);
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<List<DashboardWidget>> getDashboardWidgets() async {
    final data = await getDashboard();
    final rawWidgets = data['widgets'] as List? ?? [];
    return rawWidgets
        .map((w) => DashboardWidget.fromJson(w as Map<String, dynamic>))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getQuickActions() async {
    final headers = await _headers();
    final r = await _httpClient.get(
      Uri.parse('${_config.baseUrl}/dashboard/quick-actions'),
      headers: headers,
    );
    if (r.statusCode != 200) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(r.body) as List);
  }

  Future<Map<String, dynamic>> sendAgentMessage(
    String message, {
    List<Map<String, dynamic>>? history,
  }) async {
    final headers = await _headers();
    final r = await _httpClient.post(
      Uri.parse('${_config.baseUrl}/agent/chat'),
      headers: headers,
      body: jsonEncode({
        'message': message,
        if (history != null) 'history': history,
      }),
    );
    if (r.statusCode != 200) throw ApiException.fromResponse(r);
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  void dispose() => _httpClient.close();
}
