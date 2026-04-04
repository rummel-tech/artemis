import 'dart:async';
import 'dart:convert';
import 'package:shared_services/shared_services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/app_config.dart';

enum AgentEventType { connected, text, toolCall, done, error }

class AgentEvent {
  final AgentEventType type;
  final String? content;
  final Map<String, dynamic>? toolCall;
  final String? error;

  AgentEvent({required this.type, this.content, this.toolCall, this.error});
}

/// WebSocket-based agent service.
///
/// Uses shared [TokenStorage] to retrieve the access token for the
/// initial WebSocket auth handshake.
class AgentService {
  final TokenStorage _storage;
  WebSocketChannel? _channel;
  final _controller = StreamController<AgentEvent>.broadcast();
  bool _connected = false;

  AgentService(this._storage);

  Stream<AgentEvent> get events => _controller.stream;
  bool get isConnected => _connected;

  Future<void> connect() async {
    final token = await _storage.getAccessToken() ?? '';
    final uri = Uri.parse(AppConfig.agentWsUrl);

    _channel = WebSocketChannel.connect(uri);
    _connected = true;

    _channel!.sink.add(jsonEncode({'token': 'Bearer $token'}));

    _channel!.stream.listen(
      (raw) {
        final msg = jsonDecode(raw as String) as Map<String, dynamic>;
        final type = msg['type'] as String?;
        switch (type) {
          case 'connected':
            _controller.add(AgentEvent(
                type: AgentEventType.connected,
                content: msg['user'] as String?));
          case 'text':
            _controller.add(AgentEvent(
                type: AgentEventType.text,
                content: msg['content'] as String?));
          case 'tool_call':
            _controller
                .add(AgentEvent(type: AgentEventType.toolCall, toolCall: msg));
          case 'done':
            _controller.add(AgentEvent(type: AgentEventType.done));
          case 'error':
            _controller.add(AgentEvent(
                type: AgentEventType.error,
                error: msg['detail'] as String?));
        }
      },
      onError: (e) {
        _connected = false;
        _controller
            .add(AgentEvent(type: AgentEventType.error, error: e.toString()));
      },
      onDone: () {
        _connected = false;
      },
    );
  }

  void sendMessage(String message, {List<Map<String, dynamic>>? history}) {
    if (!_connected || _channel == null) return;
    _channel!.sink.add(jsonEncode({
      'message': message,
      if (history != null) 'history': history,
    }));
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _connected = false;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}
