import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/widget_data.dart';
import '../../services/agent_service.dart';
import '../voice/voice_screen.dart';

class AgentScreen extends StatefulWidget {
  const AgentScreen({super.key});

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  late final AgentService _agent;
  StreamSubscription<AgentEvent>? _sub;

  final _messages = <ChatMessage>[];
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _connecting = true;
  bool _waiting = false;
  String? _pendingText; // streaming text accumulator
  String? _connectionError;

  @override
  void initState() {
    super.initState();
    _agent = context.read<AgentService>();
    _connect();
  }

  Future<void> _connect() async {
    setState(() { _connecting = true; _connectionError = null; });
    try {
      await _agent.connect();
      _sub = _agent.events.listen(_onEvent);
    } catch (e) {
      if (mounted) setState(() { _connectionError = e.toString(); _connecting = false; });
    }
  }

  void _onEvent(AgentEvent event) {
    if (!mounted) return;
    switch (event.type) {
      case AgentEventType.connected:
        setState(() => _connecting = false);
      case AgentEventType.text:
        final chunk = event.content ?? '';
        setState(() {
          _pendingText = (_pendingText ?? '') + chunk;
        });
        _scrollToBottom();
      case AgentEventType.toolCall:
        setState(() {
          if (_pendingText != null) {
            _messages.add(ChatMessage(role: 'assistant', content: _pendingText!));
            _pendingText = null;
          }
          _messages.add(ChatMessage(role: 'assistant', content: '', toolCalls: [event.toolCall!]));
        });
      case AgentEventType.done:
        setState(() {
          if (_pendingText != null) {
            _messages.add(ChatMessage(role: 'assistant', content: _pendingText!));
            _pendingText = null;
          }
          _waiting = false;
        });
        _scrollToBottom();
      case AgentEventType.error:
        setState(() {
          _waiting = false;
          _pendingText = null;
          _connectionError = event.error;
        });
    }
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _waiting || !_agent.isConnected) return;

    final history = _messages
        .where((m) => m.isUser || (m.content.isNotEmpty && m.toolCalls.isEmpty))
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _waiting = true;
    });
    _inputCtrl.clear();
    _agent.sendMessage(text, history: history);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _agent.disconnect();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _agent.isConnected
          ? FloatingActionButton.small(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => const VoiceScreen(),
                ),
              ),
              tooltip: 'Voice mode',
              child: const Icon(Icons.mic_rounded),
            )
          : null,
      appBar: AppBar(
        title: const Text('Artemis'),
        actions: [
          if (!_agent.isConnected)
            IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _connect, tooltip: 'Reconnect'),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.circle,
              size: 10,
              color: _agent.isConnected ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_connecting)
            const LinearProgressIndicator(),
          if (_connectionError != null)
            MaterialBanner(
              content: Text(_connectionError!),
              actions: [TextButton(onPressed: _connect, child: const Text('Retry'))],
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          Expanded(
            child: _messages.isEmpty && !_waiting
                ? _EmptyState(onPrompt: (p) { _inputCtrl.text = p; _send(); })
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_pendingText != null ? 1 : 0) + (_waiting && _pendingText == null ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i < _messages.length) return _MessageBubble(message: _messages[i]);
                      if (_pendingText != null) {
                        return _MessageBubble(
                          message: ChatMessage(role: 'assistant', content: _pendingText!),
                          streaming: true,
                        );
                      }
                      return const _TypingIndicator();
                    },
                  ),
          ),
          _InputBar(
            controller: _inputCtrl,
            enabled: _agent.isConnected && !_waiting,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final void Function(String) onPrompt;
  const _EmptyState({required this.onPrompt});

  static const _prompts = [
    "What's my workout today?",
    "What should I eat for lunch?",
    "Summarize my week",
    "How's my readiness score?",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text('Ask Artemis anything', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Your AI assistant across all modules', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _prompts.map((p) => ActionChip(label: Text(p), onPressed: () => onPrompt(p))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool streaming;
  const _MessageBubble({required this.message, this.streaming = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    if (message.toolCalls.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(Icons.build_rounded, size: 14, color: theme.colorScheme.outline),
            const SizedBox(width: 6),
            Text(
              '${_toolLabel(message.toolCalls.first)}…',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        top: 4, bottom: 4,
        left: isUser ? 48 : 0,
        right: isUser ? 0 : 48,
      ),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
              bottomRight: isUser ? Radius.zero : const Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  message.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (streaming) ...[
                const SizedBox(width: 6),
                SizedBox.square(
                  dimension: 8,
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: theme.colorScheme.outline),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _toolLabel(Map<String, dynamic> call) {
    final name = call['tool_name'] as String? ?? 'tool';
    return name.replaceAll('__', ' → ').replaceAll('_', ' ');
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;
  const _InputBar({required this.controller, required this.enabled, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                maxLines: null,
                decoration: InputDecoration(
                  hintText: enabled ? 'Message Artemis…' : 'Connecting…',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: enabled ? onSend : null,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
              ),
              child: const Icon(Icons.send_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
