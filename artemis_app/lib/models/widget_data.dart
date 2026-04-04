class DashboardWidget {
  final String moduleId;
  final String widgetId;
  final String? widgetName;
  final String size;
  final Map<String, dynamic>? data;
  final String? error;

  const DashboardWidget({
    required this.moduleId,
    required this.widgetId,
    this.widgetName,
    this.size = 'medium',
    this.data,
    this.error,
  });

  factory DashboardWidget.fromJson(Map<String, dynamic> json) => DashboardWidget(
        moduleId: json['module_id'] as String,
        widgetId: json['widget_id'] as String,
        widgetName: json['widget_name'] as String?,
        size: json['size'] as String? ?? 'medium',
        data: json['data'] as Map<String, dynamic>?,
        error: json['error'] as String?,
      );

  bool get hasData => data != null && error == null;
}

class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  final List<Map<String, dynamic>> toolCalls;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    this.toolCalls = const [],
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == 'user';
}
