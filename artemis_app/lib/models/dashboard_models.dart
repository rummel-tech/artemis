library;

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

class DashboardCard {
  final String id;
  final String moduleName;
  final String widgetId;
  final String? name;
  final Map<String, dynamic> position;
  final Map<String, dynamic> config;

  DashboardCard({
    required this.id,
    required this.moduleName,
    required this.widgetId,
    this.name,
    required this.position,
    this.config = const {},
  });

  factory DashboardCard.fromJson(Map<String, dynamic> json) {
    return DashboardCard(
      id: json['id'] as String,
      moduleName: json['module_name'] as String,
      widgetId: json['widget_id'] as String,
      name: json['name'] as String?,
      position: Map<String, dynamic>.from(json['position'] ?? {}),
      config: Map<String, dynamic>.from(json['config'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module_name': moduleName,
      'widget_id': widgetId,
      'name': name,
      'position': position,
      'config': config,
    };
  }
}

class DashboardSummary {
  final List<DashboardCard> cards;

  DashboardSummary({required this.cards});

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final cardList = json['cards'] as List<dynamic>? ?? [];
    return DashboardSummary(
      cards: cardList
          .map((c) => DashboardCard.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cards': cards.map((c) => c.toJson()).toList(),
    };
  }

  List<String> get moduleNames =>
      cards.map((c) => c.moduleName).toSet().toList();
}

class ModuleSummary {
  final String name;
  final bool enabled;
  final bool healthy;
  final Map<String, dynamic> stats;
  final List<dynamic> recentItems;
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
      enabled: json['enabled'] as bool? ?? true,
      healthy: json['healthy'] as bool? ?? true,
      stats: Map<String, dynamic>.from(json['stats'] ?? {}),
      recentItems: json['recent_items'] as List<dynamic>? ?? [],
      quickActions: (json['quick_actions'] as List<dynamic>?)
              ?.map((a) => QuickAction.fromJson(a as Map<String, dynamic>))
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
