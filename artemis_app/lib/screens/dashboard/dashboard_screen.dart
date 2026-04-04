import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/widget_data.dart';
import '../../providers/auth_provider.dart';
import '../../services/platform_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<DashboardWidget>? _widgets;
  List<Map<String, dynamic>>? _quickActions;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final svc = context.read<PlatformService>();
      final results = await Future.wait([
        svc.getDashboardWidgets(),
        svc.getQuickActions(),
      ]);
      if (mounted) {
        setState(() {
          _widgets = results[0] as List<DashboardWidget>;
          _quickActions = results[1] as List<Map<String, dynamic>>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good ${_greeting()}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            Text(user?.name ?? user?.email ?? 'Artemis', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: CustomScrollView(
                    slivers: [
                      if (_quickActions != null && _quickActions!.isNotEmpty)
                        SliverToBoxAdapter(child: _QuickActionsRow(actions: _quickActions!)),
                      if (_widgets != null && _widgets!.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.1,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => _WidgetCard(widget: _widgets![i]),
                              childCount: _widgets!.length,
                            ),
                          ),
                        )
                      else
                        const SliverFillRemaining(
                          child: Center(child: Text('No widgets configured')),
                        ),
                    ],
                  ),
                ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }
}

class _QuickActionsRow extends StatelessWidget {
  final List<Map<String, dynamic>> actions;
  const _QuickActionsRow({required this.actions});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final a = actions[i];
          return ActionChip(
            avatar: Icon(_iconFromName(a['icon'] as String? ?? 'bolt')),
            label: Text(a['label'] as String? ?? ''),
            onPressed: () {},
          );
        },
      ),
    );
  }

  IconData _iconFromName(String name) {
    const map = {
      'fitness_center': Icons.fitness_center,
      'restaurant': Icons.restaurant,
      'home': Icons.home,
      'directions_car': Icons.directions_car,
      'bolt': Icons.bolt,
    };
    return map[name] ?? Icons.star_rounded;
  }
}

class _WidgetCard extends StatelessWidget {
  final DashboardWidget widget;
  const _WidgetCard({required this.widget});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.error != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error),
              const SizedBox(height: 4),
              Text(widget.widgetName ?? widget.widgetId, style: theme.textTheme.labelMedium, textAlign: TextAlign.center),
              Text(widget.error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );
    }

    final data = widget.data ?? {};
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_moduleIcon(widget.moduleId), size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(widget.widgetName ?? widget.widgetId, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline), overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const Spacer(),
              _buildWidgetContent(context, data),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetContent(BuildContext context, Map<String, dynamic> data) {
    final theme = Theme.of(context);
    final entries = data.entries.where((e) => e.value != null).toList();
    if (entries.isEmpty) return const Text('No data');

    final first = entries.first;
    final value = first.value;
    if (value is num) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value.toString(), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          if (entries.length > 1)
            Text(_humanize(first.key), style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
        ],
      );
    }
    if (value is String) {
      return Text(value, style: theme.textTheme.titleMedium, maxLines: 3, overflow: TextOverflow.ellipsis);
    }
    return Text('${entries.length} items', style: theme.textTheme.titleMedium);
  }

  String _humanize(String key) => key.replaceAll('_', ' ');

  IconData _moduleIcon(String moduleId) {
    if (moduleId.contains('workout')) return Icons.fitness_center;
    if (moduleId.contains('meal')) return Icons.restaurant;
    if (moduleId.contains('home')) return Icons.home;
    if (moduleId.contains('vehicle')) return Icons.directions_car;
    return Icons.apps;
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text('Failed to load dashboard', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(error, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
