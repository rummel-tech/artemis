import 'package:flutter/material.dart';
import '../models/models.dart';

/// Card widget displaying module status
class ModuleCard extends StatelessWidget {
  final ModuleStatus moduleStatus;

  const ModuleCard({Key? key, required this.moduleStatus}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to module detail screen
          _showModuleDetails(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getModuleIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _formatModuleName(moduleStatus.name),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  _buildStatusIndicator(),
                ],
              ),
              const Spacer(),
              if (moduleStatus.message != null)
                Text(
                  moduleStatus.message!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getModuleIcon() {
    IconData icon;
    Color color;

    switch (moduleStatus.name.toLowerCase()) {
      case 'work':
        icon = Icons.work;
        color = Colors.blue;
        break;
      case 'fitness':
        icon = Icons.fitness_center;
        color = Colors.green;
        break;
      case 'nutrition':
        icon = Icons.restaurant;
        color = Colors.orange;
        break;
      case 'entrepreneurship':
        icon = Icons.lightbulb;
        color = Colors.purple;
        break;
      case 'finance':
        icon = Icons.account_balance;
        color = Colors.teal;
        break;
      case 'assets':
        icon = Icons.home;
        color = Colors.brown;
        break;
      default:
        icon = Icons.dashboard;
        color = Colors.grey;
    }

    return Icon(icon, size: 32, color: color);
  }

  Widget _buildStatusIndicator() {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: moduleStatus.healthy ? Colors.green : Colors.red,
      ),
    );
  }

  String _formatModuleName(String name) {
    return name[0].toUpperCase() + name.substring(1);
  }

  void _showModuleDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_formatModuleName(moduleStatus.name)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${moduleStatus.healthy ? "Healthy" : "Unhealthy"}'),
            Text('Enabled: ${moduleStatus.enabled ? "Yes" : "No"}'),
            if (moduleStatus.message != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(moduleStatus.message!),
              ),
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
}
