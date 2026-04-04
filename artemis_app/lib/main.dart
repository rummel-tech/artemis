import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rummel_blue_theme/rummel_blue_theme.dart';
import 'package:shared_services/shared_services.dart';
import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth_service.dart';
import 'services/platform_service.dart';
import 'services/agent_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  MetricsCollector().configure(
    MonitoringConfig.development(appName: 'artemis'),
  );

  runApp(const ArtemisApp());
}

class ArtemisApp extends StatefulWidget {
  const ArtemisApp({super.key});

  @override
  State<ArtemisApp> createState() => _ArtemisAppState();
}

class _ArtemisAppState extends State<ArtemisApp> {
  late final TokenStorage _tokenStorage;
  late final BaseApiClient _authClient;
  late final AuthService _authService;
  late final AuthProvider _authProvider;
  late final PlatformService _platformService;
  late final AgentService _agentService;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _tokenStorage = TokenStorage();

    _authClient = BaseApiClient(config: AppConfig.authConfig)
      ..tokenProvider = () => _tokenStorage.getAccessToken();

    _authService = AuthService(client: _authClient, storage: _tokenStorage);
    _authProvider = AuthProvider(_authService);
    _platformService = PlatformService(storage: _tokenStorage);
    _agentService = AgentService(_tokenStorage);

    _router = GoRouter(
      refreshListenable: _authProvider,
      redirect: (context, state) {
        final loggedIn = _authProvider.isLoggedIn;
        final initialized = _authProvider.initialized;
        final onAuth = state.matchedLocation == '/login';

        if (!initialized) return null;
        if (!loggedIn && !onAuth) return '/login';
        if (loggedIn && onAuth) return '/';
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/', builder: (_, __) => const HomeScreen(tab: 0)),
        GoRoute(path: '/agent', builder: (_, __) => const HomeScreen(tab: 1)),
      ],
    );

    _authProvider.addListener(() {});
    _authProvider.init();
  }

  @override
  void dispose() {
    _agentService.dispose();
    _authService.dispose();
    _platformService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        Provider.value(value: _platformService),
        Provider.value(value: _agentService),
      ],
      child: MaterialApp.router(
        title: 'Artemis',
        theme: RummelThemeData.light(),
        darkTheme: RummelThemeData.dark(),
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}
