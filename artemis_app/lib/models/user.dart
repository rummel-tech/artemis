class ArtemisUser {
  final String id;
  final String email;
  final String name;
  final List<String> enabledModules;
  final List<String> permissions;

  const ArtemisUser({
    required this.id,
    required this.email,
    required this.name,
    this.enabledModules = const [],
    this.permissions = const [],
  });

  factory ArtemisUser.fromJson(Map<String, dynamic> json) => ArtemisUser(
        id: json['id'] as String,
        email: json['email'] as String,
        name: (json['full_name'] as String?) ?? json['email'] as String,
        enabledModules: List<String>.from(json['enabled_modules'] ?? []),
        permissions: List<String>.from(json['permissions'] ?? []),
      );
}
