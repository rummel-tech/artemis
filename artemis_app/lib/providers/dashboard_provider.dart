import 'package:flutter/foundation.dart';
import '../models/dashboard_models.dart';
import '../services/api_service.dart';

enum DashboardState { initial, loading, loaded, error }

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService;

  DashboardState _state = DashboardState.initial;
  DashboardSummary? _summary;
  String? _error;

  DashboardProvider(this._apiService);

  DashboardState get state => _state;
  DashboardSummary? get summary => _summary;
  String? get error => _error;
  bool get isLoading => _state == DashboardState.loading;
  bool get hasData => _summary != null;

  Future<void> loadDashboard() async {
    _state = DashboardState.loading;
    _error = null;
    notifyListeners();

    try {
      _summary = await _apiService.getDashboard();
      _state = DashboardState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = DashboardState.error;
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}
