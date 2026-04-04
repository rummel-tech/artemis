import 'package:shared_services/shared_services.dart';

/// Base URLs and configuration for all Artemis platform services.
///
/// In development these point to localhost.
/// In production they are overridden via compile-time environment variables.
class AppConfig {
  static const String _authBaseUrl = String.fromEnvironment(
    'AUTH_BASE_URL',
    defaultValue: 'http://localhost:8090',
  );

  static const String _platformBaseUrl = String.fromEnvironment(
    'PLATFORM_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  /// [ApiConfig] for the Artemis auth backend.
  static ApiConfig get authConfig => ApiConfig(
        baseUrl: _authBaseUrl,
        timeout: const Duration(seconds: 30),
        maxRetries: 3,
        environment: _environment,
      );

  /// [ApiConfig] for the Artemis platform backend.
  static ApiConfig get platformConfig => ApiConfig(
        baseUrl: _platformBaseUrl,
        timeout: const Duration(seconds: 30),
        maxRetries: 3,
        environment: _environment,
      );

  /// WebSocket agent endpoint derived from the platform URL.
  static String get agentWsUrl =>
      '${_platformBaseUrl.replaceFirst('http', 'ws')}/agent/ws';

  /// Google OAuth client ID (iOS/Android — set in Google Cloud Console).
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );
}
