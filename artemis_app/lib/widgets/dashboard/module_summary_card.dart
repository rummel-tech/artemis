import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';
import '../../config/module_config.dart';
import 'stat_tile.dart';

/// Enhanced module card with statistics for dashboard
class ModuleSummaryCard extends StatelessWidget {
  final ModuleSummary summary;
  final VoidCallback? onTap;
  final void Function(QuickAction action)? onQuickAction;

  const ModuleSummaryCard({
    Key? key,
    required this.summary,
    this.onTap,
    this.onQuickAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moduleColor = ModuleConfigs.getColor(summary.name);
    final moduleIcon = ModuleConfigs.getIcon(summary.name);
    final displayName = ModuleConfigs.getDisplayName(summary.name);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with module name and status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    moduleColor,
                    moduleColor.withAlpha(204),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Icon(moduleIcon, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      displayName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusIndicator(),
                ],
              ),
            ),

            // Stats section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats row
                    Expanded(
                      child: _buildStatsGrid(moduleColor),
                    ),

                    // Quick actions row
                    if (summary.quickActions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildQuickActions(context, moduleColor),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: summary.healthy ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            summary.healthy ? 'Healthy' : 'Issue',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Color moduleColor) {
    final stats = summary.stats;
    if (stats.isEmpty) {
      return const Center(
        child: Text('No statistics available'),
      );
    }

    final statEntries = stats.entries.take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: statEntries.map((entry) {
            final label = ModuleConfigs.getStatLabel(summary.name, entry.key);
            final value = _formatStatValue(entry.value);

            return SizedBox(
              width: (constraints.maxWidth - 8) / 2,
              child: StatTile(
                label: label,
                value: value,
                color: moduleColor,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, Color moduleColor) {
    return Row(
      children: summary.quickActions.take(2).map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: TextButton.icon(
              onPressed: onQuickAction != null ? () => onQuickAction!(action) : null,
              icon: Icon(
                QuickActionIcons.getIcon(action.icon),
                size: 16,
              ),
              label: Text(
                action.label,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              style: TextButton.styleFrom(
                foregroundColor: moduleColor,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatStatValue(dynamic value) {
    if (value is double) {
      if (value >= 1000) {
        return '\$${(value / 1000).toStringAsFixed(1)}k';
      }
      return '\$${value.toStringAsFixed(2)}';
    }
    return value.toString();
  }
}
