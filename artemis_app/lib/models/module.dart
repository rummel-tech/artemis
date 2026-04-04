class ArtemisModule {
  final String id;
  final String? name;
  final bool healthy;
  final bool enabled;
  final String? error;
  final Map<String, dynamic>? manifest;

  const ArtemisModule({
    required this.id,
    this.name,
    required this.healthy,
    this.enabled = true,
    this.error,
    this.manifest,
  });

  factory ArtemisModule.fromJson(Map<String, dynamic> json) => ArtemisModule(
        id: json['id'] as String,
        name: json['name'] as String?,
        healthy: json['healthy'] as bool? ?? false,
        enabled: json['enabled'] as bool? ?? true,
        error: json['error'] as String?,
        manifest: json['manifest'] as Map<String, dynamic>?,
      );

  String get displayName => name ?? id;

  String get color {
    if (manifest == null) return '#6366f1';
    return manifest!['module']?['color'] as String? ?? '#6366f1';
  }

  String get icon {
    if (manifest == null) return 'apps';
    return manifest!['module']?['icon'] as String? ?? 'apps';
  }
}
