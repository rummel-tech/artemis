import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../models/dashboard_models.dart';
import '../config/env_config.dart';

class ApiService {
  final String baseUrl;

  ApiService({String? baseUrl})
      : baseUrl = baseUrl ?? EnvConfig.apiBaseUrl;

  Future<Map<String, dynamic>> getHealth() async {
    final response = await http.get(Uri.parse('$baseUrl/health'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception(
        'Failed to get health status: ${response.statusCode} - ${response.body}');
  }

  Future<List<ModuleManifest>> getModuleManifests() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/v1/modules/manifests'));
    if (response.statusCode == 200) {
      final List<dynamic> list = json.decode(response.body);
      return list
          .map((m) => ModuleManifest.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    throw Exception(
        'Failed to get module manifests: ${response.statusCode} - ${response.body}');
  }

  Future<ModuleManifest> getModuleManifest(String moduleName) async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/v1/modules/$moduleName/manifest'));
    if (response.statusCode == 200) {
      return ModuleManifest.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception(
        'Failed to get module manifest: ${response.statusCode} - ${response.body}');
  }

  Future<ModuleStatus> getModuleStatus(String moduleName) async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/v1/modules/$moduleName/status'));
    if (response.statusCode == 200) {
      return ModuleStatus.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception(
        'Failed to get module status: ${response.statusCode} - ${response.body}');
  }

  Future<Map<String, dynamic>> executeModuleAction(
    String moduleName,
    ActionRequest request,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/modules/$moduleName/action'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception(
        'Failed to execute action: ${response.statusCode} - ${response.body}');
  }

  Future<DashboardSummary> getDashboard() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/v1/dashboard'));
    if (response.statusCode == 200) {
      return DashboardSummary.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception(
        'Failed to get dashboard: ${response.statusCode} - ${response.body}');
  }

  Future<List<Map<String, dynamic>>> getDailySchedule(
      {String? date}) async {
    final uri = Uri.parse('$baseUrl/api/v1/activities/daily')
        .replace(queryParameters: date != null ? {'target_date': date} : null);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }
    throw Exception(
        'Failed to get daily schedule: ${response.statusCode} - ${response.body}');
  }

  Future<List<Map<String, dynamic>>> getUpcomingActivities() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/v1/activities/upcoming'));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }
    throw Exception(
        'Failed to get upcoming activities: ${response.statusCode} - ${response.body}');
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/v1/notifications'));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }
    throw Exception(
        'Failed to get notifications: ${response.statusCode} - ${response.body}');
  }

  Future<List<Map<String, dynamic>>> getCalendarEvents() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/v1/calendar/events'));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }
    throw Exception(
        'Failed to get calendar events: ${response.statusCode} - ${response.body}');
  }
}
