import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/dashboard_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'services/api_service.dart';
import 'theme/rummel_theme.dart';

void main() {
  runApp(const ArtemisApp());
}

class ArtemisApp extends StatelessWidget {
  const ArtemisApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        ChangeNotifierProxyProvider<ApiService, DashboardProvider>(
          create: (context) => DashboardProvider(context.read<ApiService>()),
          update: (context, apiService, previous) =>
              previous ?? DashboardProvider(apiService),
        ),
      ],
      child: MaterialApp(
        title: 'Artemis Personal OS',
        theme: RummelTheme.lightTheme,
        darkTheme: RummelTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const DashboardScreen(),
      ),
    );
  }
}
