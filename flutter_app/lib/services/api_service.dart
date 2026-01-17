import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// API Service for communicating with Artemis backend
class ApiService {
  // Default to localhost, can be configured via environment variables
  final String baseUrl;

  ApiService({String? baseUrl})
      : baseUrl = baseUrl ?? 'http://localhost:8000';

  /// Get health status of the API
  Future<Map<String, dynamic>> getHealth() async {
    final response = await http.get(Uri.parse('$baseUrl/health'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to get health status');
  }

  /// List all available modules
  Future<List<String>> listModules() async {
    final response = await http.get(Uri.parse('$baseUrl/modules'));
    if (response.statusCode == 200) {
      final List<dynamic> modules = json.decode(response.body);
      return modules.map((m) => m.toString()).toList();
    }
    throw Exception('Failed to list modules');
  }

  /// Get status of all modules
  Future<List<ModuleStatus>> getModulesStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/modules/status'));
    if (response.statusCode == 200) {
      final List<dynamic> statusList = json.decode(response.body);
      return statusList
          .map((s) => ModuleStatus.fromJson(s as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to get modules status');
  }

  /// Get status of a specific module
  Future<ModuleStatus> getModuleStatus(String moduleName) async {
    final response =
        await http.get(Uri.parse('$baseUrl/modules/$moduleName/status'));
    if (response.statusCode == 200) {
      return ModuleStatus.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to get module status');
  }

  /// Execute an action on a module
  Future<Map<String, dynamic>> executeModuleAction(
    String moduleName,
    ActionRequest request,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/modules/$moduleName/action'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to execute action');
  }
}
