import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum VoiceState { idle, listening, thinking, speaking }

class VoiceService extends ChangeNotifier {
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  VoiceState _state = VoiceState.idle;
  String _transcript = '';
  bool _available = false;

  VoiceState get state => _state;
  String get transcript => _transcript;
  bool get isAvailable => _available;

  Future<bool> initialize() async {
    _available = await _stt.initialize(
      onError: (_) => _set(VoiceState.idle),
      onStatus: (s) {
        if ((s == 'done' || s == 'notListening') &&
            _state == VoiceState.listening) {
          _set(VoiceState.idle);
        }
      },
    );

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.52);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() => _set(VoiceState.idle));
    _tts.setErrorHandler((_) => _set(VoiceState.idle));

    return _available;
  }

  Future<void> startListening(void Function(String) onResult) async {
    if (!_available || _state != VoiceState.idle) return;
    _transcript = '';
    _set(VoiceState.listening);

    await _stt.listen(
      onResult: (r) {
        _transcript = r.recognizedWords;
        notifyListeners();
        if (r.finalResult && _transcript.isNotEmpty) {
          _set(VoiceState.thinking);
          onResult(_transcript);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      localeId: 'en_US',
    );
  }

  Future<void> stopListening() async {
    if (_state != VoiceState.listening) return;
    await _stt.stop();
    _set(VoiceState.idle);
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    _set(VoiceState.speaking);
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    _set(VoiceState.idle);
  }

  void setThinking() => _set(VoiceState.thinking);
  void setIdle() => _set(VoiceState.idle);

  void _set(VoiceState s) {
    _state = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _stt.cancel();
    _tts.stop();
    super.dispose();
  }
}
