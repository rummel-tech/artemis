import 'package:flutter/foundation.dart';
import '../models/dashboard_models.dart';
import '../services/api_service.dart';

/// State for the dashboard
enum DashboardState { initial, loading, loaded, error }

/// Provider for managing dashboard state
class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService;

  DashboardState _state = DashboardState.initial;
  DashboardSummary? _summary;
  String? _error;

  DashboardProvider(this._apiService);

  /// Current state of the dashboard
  DashboardState get state => _state;

  /// Dashboard summary data
  DashboardSummary? get summary => _summary;

  /// Error message if state is error
  String? get error => _error;

  /// Whether the dashboard is loading
  bool get isLoading => _state == DashboardState.loading;

  /// Whether the dashboard has data
  bool get hasData => _summary != null;

  /// Load or refresh dashboard data
  Future<void> loadDashboard() async {
    _state = DashboardState.loading;
    _error = null;
    notifyListeners();

    try {
      _summary = await _apiService.getDashboardSummary();
      _state = DashboardState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = DashboardState.error;
    }

    notifyListeners();
  }

  /// Refresh dashboard data
  Future<void> refresh() async {
    await loadDashboard();
  }

  /// Get summary for a specific module
  ModuleSummary? getModuleSummary(String moduleName) {
    return _summary?.getModule(moduleName);
  }
}
