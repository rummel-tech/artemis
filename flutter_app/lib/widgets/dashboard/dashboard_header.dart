import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';

/// Dashboard header with greeting and overview
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
            if (summary != null) ...[
              const SizedBox(height: 16),
              _buildOverviewCards(context),
            ],
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _getSubtitle() {
    if (summary == null) return 'Loading your dashboard...';

    final activeModules = summary!.modules.where((m) => m.healthy).length;
    final totalModules = summary!.modules.length;

    return '$activeModules of $totalModules modules active';
  }

  Widget _buildOverviewCards(BuildContext context) {
    if (summary == null) return const SizedBox.shrink();

    // Calculate some aggregate stats
    int totalTasks = 0;
    int totalWorkouts = 0;
    int totalVentures = 0;

    for (final module in summary!.modules) {
      final stats = module.stats;
      totalTasks += (stats['task_count'] as int?) ?? 0;
      totalWorkouts += (stats['total_workouts'] as int?) ?? 0;
      totalVentures += (stats['venture_count'] as int?) ?? 0;
    }

    return Row(
      children: [
        _buildMiniStat(context, Icons.task_alt, '$totalTasks', 'Tasks'),
        const SizedBox(width: 12),
        _buildMiniStat(context, Icons.fitness_center, '$totalWorkouts', 'Workouts'),
        const SizedBox(width: 12),
        _buildMiniStat(context, Icons.rocket_launch, '$totalVentures', 'Ventures'),
      ],
    );
  }

  Widget _buildMiniStat(BuildContext context, IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(38),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withAlpha(179),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
