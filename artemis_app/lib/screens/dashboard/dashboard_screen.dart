import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/dashboard_models.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/dashboard/dashboard_header.dart';
import '../../widgets/dashboard/module_summary_card.dart';
import '../../widgets/dashboard/quick_action_fab.dart';

// Responsive breakpoints
const double _tabletBreakpoint = 800.0;
const double _desktopBreakpoint = 1200.0;

/// Main dashboard screen with module overview
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: provider.refresh,
            edgeOffset: 120, // Account for header
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: DashboardHeader(summary: provider.summary),
                ),

                // Content
                if (provider.isLoading && !provider.hasData)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.state == DashboardState.error && !provider.hasData)
                  SliverFillRemaining(
                    child: _buildErrorState(provider),
                  )
                else if (provider.hasData)
                  _buildModuleGrid(provider.summary!)
                else
                  const SliverFillRemaining(
                    child: Center(child: Text('No data available')),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (!provider.hasData) return const SizedBox.shrink();

          return QuickActionFab(
            modules: provider.summary!.modules,
            onActionSelected: _handleQuickAction,
          );
        },
      ),
    );
  }

  Widget _buildErrorState(DashboardProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load dashboard',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: provider.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleGrid(DashboardSummary summary) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = _getCrossAxisCount(context);
          final aspectRatio = _getAspectRatio(context);

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: aspectRatio,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final module = summary.modules[index];
                return ModuleSummaryCard(
                  summary: module,
                  onTap: () => _handleModuleTap(module),
                  onQuickAction: (action) => _handleQuickAction(module.name, action),
                );
              },
              childCount: summary.modules.length,
            ),
          );
        },
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > _desktopBreakpoint) return 3;
    if (width > _tabletBreakpoint) return 2;
    return 1;
  }

  double _getAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > _desktopBreakpoint) return 1.3;
    if (width > _tabletBreakpoint) return 1.4;
    return 1.6;
  }

  void _handleModuleTap(ModuleSummary module) {
    // Show module details dialog for now
    // TODO: Navigate to module detail screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(module.name[0].toUpperCase() + module.name.substring(1)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${module.healthy ? "Healthy" : "Unhealthy"}'),
            Text('Enabled: ${module.enabled ? "Yes" : "No"}'),
            const SizedBox(height: 16),
            const Text('Statistics:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...module.stats.entries.map((e) => Text('${e.key}: ${e.value}')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleQuickAction(String moduleName, QuickAction action) async {
    // Execute the quick action
    final scaffold = ScaffoldMessenger.of(context);

    try {
      // For now, just show a snackbar - actual implementation would
      // show a form or execute the action directly
      scaffold.showSnackBar(
        SnackBar(
          content: Text('${action.label} for $moduleName'),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () => scaffold.hideCurrentSnackBar(),
          ),
        ),
      );

      // In a real implementation, you might show a bottom sheet
      // with a form to create the item
      // await apiService.executeModuleAction(moduleName, ActionRequest(action: action.action, data: {...}));
      // await context.read<DashboardProvider>().refresh();
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Failed to execute action: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
