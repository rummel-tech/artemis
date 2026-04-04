import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../dashboard/dashboard_screen.dart';
import '../agent/agent_screen.dart';

class HomeScreen extends StatefulWidget {
  final int tab;
  const HomeScreen({super.key, this.tab = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _current;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard_rounded),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.auto_awesome_outlined),
      selectedIcon: Icon(Icons.auto_awesome_rounded),
      label: 'Artemis',
    ),
  ];

  static const _routes = ['/', '/agent'];

  @override
  void initState() {
    super.initState();
    _current = widget.tab.clamp(0, _destinations.length - 1);
  }

  @override
  void didUpdateWidget(HomeScreen old) {
    super.didUpdateWidget(old);
    if (old.tab != widget.tab) {
      setState(() => _current = widget.tab.clamp(0, _destinations.length - 1));
    }
  }

  Widget _body() => switch (_current) {
        1 => const AgentScreen(),
        _ => const DashboardScreen(),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _current,
        onDestinationSelected: (i) {
          setState(() => _current = i);
          context.go(_routes[i]);
        },
        destinations: _destinations,
      ),
    );
  }
}
