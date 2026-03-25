import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';

class DashboardHeader extends StatelessWidget {
  final DashboardSummary? summary;

  const DashboardHeader({
    Key? key,
    this.summary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = _getGreeting();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withAlpha(204),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getSubtitle(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withAlpha(204),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getSubtitle() {
    if (summary == null) return 'Loading your dashboard...';
    final moduleCount = summary!.moduleNames.length;
    return '$moduleCount module${moduleCount == 1 ? '' : 's'} active';
  }
}
