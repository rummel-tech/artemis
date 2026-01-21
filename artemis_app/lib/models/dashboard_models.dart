/// Dashboard models for Artemis Personal OS
library;

/// Quick action that can be performed from the dashboard
class QuickAction {
  final String id;
  final String label;
  final String action;
  final String? icon;

  QuickAction({
    required this.id,
    required this.label,
    required this.action,
    this.icon,
  });

  factory QuickAction.fromJson(Map<String, dynamic> json) {
    return QuickAction(
      id: json['id'] as String,
      label: json['label'] as String,
      action: json['action'] as String,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'action': action,
      'icon': icon,
    };
  }
}

/// Summary information for a single module
class ModuleSummary {
  final String name;
  final bool enabled;
  final bool healthy;
  final Map<String, dynamic> stats;
  final List<Map<String, dynamic>> recentItems;
  final List<QuickAction> quickActions;

  ModuleSummary({
    required this.name,
    required this.enabled,
    required this.healthy,
    this.stats = const {},
    this.recentItems = const [],
    this.quickActions = const [],
  });

  factory ModuleSummary.fromJson(Map<String, dynamic> json) {
    return ModuleSummary(
      name: json['name'] as String,
      enabled: json['enabled'] as bool,
      healthy: json['healthy'] as bool,
      stats: Map<String, dynamic>.from(json['stats'] ?? {}),
      recentItems: (json['recent_items'] as List<dynamic>?)
              ?.map((item) => Map<String, dynamic>.from(item))
              .toList() ??
          [],
      quickActions: (json['quick_actions'] as List<dynamic>?)
              ?.map((action) =>
                  QuickAction.fromJson(action as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'enabled': enabled,
      'healthy': healthy,
      'stats': stats,
      'recent_items': recentItems,
      'quick_actions': quickActions.map((a) => a.toJson()).toList(),
    };
  }
}

/// Dashboard summary containing all module summaries
class DashboardSummary {
  final List<ModuleSummary> modules;

  DashboardSummary({required this.modules});

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      modules: (json['modules'] as List<dynamic>)
          .map((m) => ModuleSummary.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modules': modules.map((m) => m.toJson()).toList(),
    };
  }

  /// Get summary for a specific module by name
  ModuleSummary? getModule(String name) {
    try {
      return modules.firstWhere((m) => m.name.toLowerCase() == name.toLowerCase());
    } catch (_) {
      return null;
    }
  }
}
