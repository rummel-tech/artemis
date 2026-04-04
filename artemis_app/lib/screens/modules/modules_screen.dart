import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/module.dart';
import '../../services/platform_service.dart';

class ModulesScreen extends StatefulWidget {
  const ModulesScreen({super.key});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  List<ArtemisModule>? _modules;
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
      final modules = await context.read<PlatformService>().getModules();
      if (mounted) setState(() { _modules = modules; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modules'),
        actions: [IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 48),
                      const SizedBox(height: 12),
                      Text(_error!),
                      const SizedBox(height: 16),
                      FilledButton.tonal(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _modules == null || _modules!.isEmpty
                      ? const Center(child: Text('No modules registered'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _modules!.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (ctx, i) => _ModuleCard(module: _modules![i]),
                        ),
                ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final ArtemisModule module;
  const _ModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _parseColor(module.color);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_iconFromName(module.icon), color: color, size: 22),
        ),
        title: Text(module.displayName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(module.id, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
            if (module.error != null)
              Text(module.error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: _StatusBadge(healthy: module.healthy, enabled: module.enabled),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final h = hex.replaceFirst('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return const Color(0xFF6366F1);
    }
  }

  IconData _iconFromName(String name) {
    const map = {
      'fitness_center': Icons.fitness_center,
      'restaurant': Icons.restaurant,
      'home': Icons.home,
      'directions_car': Icons.directions_car,
      'apps': Icons.apps,
      'bolt': Icons.bolt,
      'favorite': Icons.favorite,
      'schedule': Icons.schedule,
    };
    return map[name] ?? Icons.apps;
  }
}

class _StatusBadge extends StatelessWidget {
  final bool healthy;
  final bool enabled;
  const _StatusBadge({required this.healthy, required this.enabled});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!enabled) {
      return Chip(
        label: const Text('Disabled'),
        labelStyle: theme.textTheme.labelSmall,
        padding: EdgeInsets.zero,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      );
    }
    return Chip(
      label: Text(healthy ? 'Healthy' : 'Offline'),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: healthy ? Colors.green.shade700 : theme.colorScheme.error,
      ),
      padding: EdgeInsets.zero,
      backgroundColor: healthy ? Colors.green.withValues(alpha: 0.12) : theme.colorScheme.errorContainer,
      avatar: Icon(
        healthy ? Icons.check_circle_rounded : Icons.cancel_rounded,
        size: 14,
        color: healthy ? Colors.green.shade700 : theme.colorScheme.error,
      ),
    );
  }
}
