/// Models for Artemis Personal OS
library;

/// Module status model
class ModuleStatus {
  final String name;
  final bool enabled;
  final bool healthy;
  final String? message;

  ModuleStatus({
    required this.name,
    required this.enabled,
    required this.healthy,
    this.message,
  });

  factory ModuleStatus.fromJson(Map<String, dynamic> json) {
    return ModuleStatus(
      name: json['name'] as String,
      enabled: json['enabled'] as bool,
      healthy: json['healthy'] as bool,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'enabled': enabled,
      'healthy': healthy,
      'message': message,
    };
  }
}

/// Action request model
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
