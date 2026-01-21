import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/dashboard_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'services/api_service.dart';

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
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.system,
        home: const DashboardScreen(),
      ),
    );
  }
}
