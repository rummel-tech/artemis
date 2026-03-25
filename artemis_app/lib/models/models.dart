library;

class ModuleStatus {
  final String name;
  final String status;

  ModuleStatus({
    required this.name,
    required this.status,
  });

  factory ModuleStatus.fromJson(Map<String, dynamic> json) {
    return ModuleStatus(
      name: json['name'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
    };
  }

  bool get isActive => status == 'active';
}

class ModuleManifest {
  final String name;
  final String version;
  final String description;
  final String icon;
  final String color;
  final List<Map<String, dynamic>> quickActions;

  ModuleManifest({
    required this.name,
    required this.version,
    required this.description,
    required this.icon,
    required this.color,
    this.quickActions = const [],
  });

  factory ModuleManifest.fromJson(Map<String, dynamic> json) {
    return ModuleManifest(
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      quickActions: (json['quick_actions'] as List<dynamic>?)
              ?.map((a) => a as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'description': description,
      'icon': icon,
      'color': color,
      'quick_actions': quickActions,
    };
  }
}

class ActionRequest {
  final String action;
  final Map<String, dynamic> data;

  ActionRequest({
    required this.action,
    this.data = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'data': data,
    };
  }
}
