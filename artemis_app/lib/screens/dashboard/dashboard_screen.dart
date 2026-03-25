import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/dashboard_models.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/dashboard/dashboard_header.dart';
import '../../widgets/dashboard/module_summary_card.dart';
import '../../widgets/dashboard/quick_action_fab.dart';

// Responsive breakpoints
const double _tabletBreakpoint = 600.0;
const double _desktopBreakpoint = 840.0;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
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
            edgeOffset: 120,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: DashboardHeader(summary: provider.summary),
                ),
                if (provider.isLoading && !provider.hasData)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.state == DashboardState.error &&
                    !provider.hasData)
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
          final modules = _buildModuleSummaries(provider.summary!);
          return QuickActionFab(
            modules: modules,
            onActionSelected: _handleQuickAction,
          );
        },
      ),
    );
  }

  List<ModuleSummary> _buildModuleSummaries(DashboardSummary summary) {
    final seen = <String>{};
    final result = <ModuleSummary>[];
    for (final card in summary.cards) {
      if (seen.add(card.moduleName)) {
        result.add(ModuleSummary(
          name: card.moduleName,
          enabled: true,
          healthy: true,
        ));
      }
    }
    return result;
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
    final modules = _buildModuleSummaries(summary);
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
                final module = modules[index];
                return ModuleSummaryCard(
                  summary: module,
                  onTap: () => _handleModuleTap(module),
                  onQuickAction: (action) =>
                      _handleQuickAction(module.name, action),
                );
              },
              childCount: modules.length,
            ),
          );
        },
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= _desktopBreakpoint) return 3;
    if (width >= _tabletBreakpoint) return 2;
    return 1;
  }

  double _getAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= _desktopBreakpoint) return 1.3;
    if (width >= _tabletBreakpoint) return 1.4;
    return 1.6;
  }

  void _handleModuleTap(ModuleSummary module) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(module.name[0].toUpperCase() + module.name.substring(1)),
        content: const Text('Module details coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleQuickAction(String moduleName, QuickAction action) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text('${action.label} for $moduleName'),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () => scaffold.hideCurrentSnackBar(),
        ),
      ),
    );
  }
}
