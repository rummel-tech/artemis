import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';
import '../../config/module_config.dart';

/// Expandable FAB with quick actions
class QuickActionFab extends StatefulWidget {
  final List<ModuleSummary> modules;
  final void Function(String moduleName, QuickAction action)? onActionSelected;

  const QuickActionFab({
    Key? key,
    required this.modules,
    this.onActionSelected,
  }) : super(key: key);

  @override
  State<QuickActionFab> createState() => _QuickActionFabState();
}

class _QuickActionFabState extends State<QuickActionFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _close() {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Expanded actions
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _buildActionButtons(),
          ),
        ),

        // Main FAB
        FloatingActionButton(
          heroTag: 'quick_action_fab',
          onPressed: _toggle,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 250),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActionButtons() {
    final actions = <Widget>[];

    for (final module in widget.modules) {
      if (module.quickActions.isEmpty) continue;

      final moduleColor = ModuleConfigs.getColor(module.name);
      final firstAction = module.quickActions.first;

      actions.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  firstAction.label,
                  style: TextStyle(
                    color: moduleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Mini FAB
              FloatingActionButton.small(
                heroTag: 'fab_${module.name}',
                backgroundColor: moduleColor,
                onPressed: () {
                  _close();
                  widget.onActionSelected?.call(module.name, firstAction);
                },
                child: Icon(
                  QuickActionIcons.getIcon(firstAction.icon),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return actions;
  }
}
