import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/voice_service.dart';
import '../../services/platform_service.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen>
    with TickerProviderStateMixin {
  late final PlatformService _platform;
  late final VoiceService _voice;
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  final List<Map<String, dynamic>> _history = [];
  String _response = '';
  bool _waiting = false;

  static const _bg = Color(0xFF0A0A1B);

  @override
  void initState() {
    super.initState();
    _platform = context.read<PlatformService>();
    _voice = VoiceService();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _scale = Tween<double>(begin: 0.93, end: 1.07).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );

    _voice.addListener(_onVoiceChange);
    _initVoice();
  }

  Future<void> _initVoice() async {
    final ok = await _voice.initialize();
    if (mounted && !ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice requires Chrome or Edge with microphone access.'),
        ),
      );
    }
  }

  void _onVoiceChange() {
    if (mounted) setState(() {});
  }

  void _onOrbTap() {
    switch (_voice.state) {
      case VoiceState.idle:
        _response = '';
        _voice.startListening(_onTranscript);
      case VoiceState.listening:
        _voice.stopListening();
      case VoiceState.speaking:
        _voice.stopSpeaking();
      case VoiceState.thinking:
        break;
    }
  }

  Future<void> _onTranscript(String transcript) async {
    if (_waiting) return;
    setState(() => _waiting = true);
    try {
      final result = await _platform.sendAgentMessage(
        transcript,
        history: List.from(_history),
      );
      final text = (result['response'] as String? ?? '').trim();
      _history.add({'role': 'user', 'content': transcript});
      if (text.isNotEmpty) {
        _history.add({'role': 'assistant', 'content': text});
      }
      setState(() => _response = text);
      await _voice.speak(text.isNotEmpty ? text : 'I had trouble with that.');
    } catch (_) {
      _voice.setIdle();
    } finally {
      if (mounted) setState(() => _waiting = false);
    }
  }

  // Orb colors per state
  Color get _inner {
    switch (_voice.state) {
      case VoiceState.idle:     return const Color(0xFF6366F1);
      case VoiceState.listening: return const Color(0xFF0D9488);
      case VoiceState.thinking: return const Color(0xFF7C3AED);
      case VoiceState.speaking: return const Color(0xFF2563EB);
    }
  }

  Color get _outer {
    switch (_voice.state) {
      case VoiceState.idle:     return const Color(0xFF3730A3);
      case VoiceState.listening: return const Color(0xFF0F766E);
      case VoiceState.thinking: return const Color(0xFF4C1D95);
      case VoiceState.speaking: return const Color(0xFF1E3A8A);
    }
  }

  IconData get _icon {
    switch (_voice.state) {
      case VoiceState.speaking: return Icons.volume_up_rounded;
      default:                  return Icons.mic_rounded;
    }
  }

  String get _label {
    switch (_voice.state) {
      case VoiceState.idle:
        return _history.isEmpty ? 'Tap to speak' : 'Tap to continue';
      case VoiceState.listening:
        return _voice.transcript.isEmpty ? 'Listening…' : _voice.transcript;
      case VoiceState.thinking:
        return 'Thinking…';
      case VoiceState.speaking:
        return 'Tap to stop';
    }
  }

  bool get _animate =>
      _voice.state == VoiceState.listening ||
      _voice.state == VoiceState.speaking;

  @override
  void dispose() {
    _voice.removeListener(_onVoiceChange);
    _voice.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 30,
                      color: Colors.white60,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    'Artemis',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Response area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _response.isEmpty
                            ? (_voice.state == VoiceState.idle
                                ? 'How can I help?'
                                : '')
                            : _response,
                        key: ValueKey(_response.hashCode),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Orb
            GestureDetector(
              onTap: _onOrbTap,
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) {
                  final s = _animate ? _scale.value : 1.0;
                  return Transform.scale(
                    scale: s,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [_inner, _outer],
                          stops: const [0.25, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _inner.withOpacity(_animate ? 0.55 : 0.30),
                            blurRadius: _animate ? 52 : 22,
                            spreadRadius: _animate ? 10 : 3,
                          ),
                        ],
                      ),
                      child: _voice.state == VoiceState.thinking
                          ? const Padding(
                              padding: EdgeInsets.all(46),
                              child: CircularProgressIndicator(
                                color: Colors.white70,
                                strokeWidth: 3,
                              ),
                            )
                          : Icon(_icon, color: Colors.white, size: 56),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // Status label
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                height: 44,
                child: Text(
                  _label,
                  key: ValueKey(
                    _label.length > 20 ? _label.substring(0, 20) : _label,
                  ),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 15,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            const SizedBox(height: 56),
          ],
        ),
      ),
    );
  }
}
