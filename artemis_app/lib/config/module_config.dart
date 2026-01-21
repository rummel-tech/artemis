import 'package:flutter/material.dart';

/// Configuration for module display in the dashboard
class ModuleConfig {
  final String name;
  final IconData icon;
  final Color color;
  final Map<String, String> statLabels;

  const ModuleConfig({
    required this.name,
    required this.icon,
    required this.color,
    required this.statLabels,
  });
}

/// Module configurations for all life domains
class ModuleConfigs {
  static const Map<String, ModuleConfig> configs = {
    'work': ModuleConfig(
      name: 'Work',
      icon: Icons.work,
      color: Color(0xFF2196F3),
      statLabels: {
        'task_count': 'Tasks',
        'project_count': 'Projects',
        'completed_today': 'Done Today',
      },
    ),
    'fitness': ModuleConfig(
      name: 'Fitness',
      icon: Icons.fitness_center,
      color: Color(0xFF4CAF50),
      statLabels: {
        'workouts_this_week': 'This Week',
        'total_workouts': 'Total Workouts',
        'active_goals': 'Active Goals',
      },
    ),
    'nutrition': ModuleConfig(
      name: 'Nutrition',
      icon: Icons.restaurant,
      color: Color(0xFFFF9800),
      statLabels: {
        'meals_today': 'Meals Today',
        'recipes_count': 'Recipes',
        'total_meals': 'Total Meals',
      },
    ),
    'entrepreneurship': ModuleConfig(
      name: 'Entrepreneurship',
      icon: Icons.lightbulb,
      color: Color(0xFF9C27B0),
      statLabels: {
        'venture_count': 'Ventures',
        'idea_count': 'Ideas',
        'active_milestones': 'Milestones',
      },
    ),
    'finance': ModuleConfig(
      name: 'Finance',
      icon: Icons.account_balance,
      color: Color(0xFF009688),
      statLabels: {
        'transaction_count': 'Transactions',
        'monthly_spend': 'Monthly Spend',
        'budget_count': 'Budgets',
      },
    ),
    'assets': ModuleConfig(
      name: 'Assets',
      icon: Icons.home,
      color: Color(0xFF795548),
      statLabels: {
        'asset_count': 'Assets',
        'upcoming_maintenance': 'Due Soon',
        'documents_count': 'Documents',
      },
    ),
  };

  /// Get configuration for a module by name
  static ModuleConfig? getConfig(String moduleName) {
    return configs[moduleName.toLowerCase()];
  }

  /// Get icon for a module
  static IconData getIcon(String moduleName) {
    return configs[moduleName.toLowerCase()]?.icon ?? Icons.dashboard;
  }

  /// Get color for a module
  static Color getColor(String moduleName) {
    return configs[moduleName.toLowerCase()]?.color ?? Colors.grey;
  }

  /// Get stat label for a module
  static String getStatLabel(String moduleName, String statKey) {
    return configs[moduleName.toLowerCase()]?.statLabels[statKey] ?? statKey;
  }

  /// Get formatted module name
  static String getDisplayName(String moduleName) {
    return configs[moduleName.toLowerCase()]?.name ??
        (moduleName.isNotEmpty
            ? moduleName[0].toUpperCase() + moduleName.substring(1)
            : moduleName);
  }
}

/// Quick action icon mapping
class QuickActionIcons {
  static const Map<String, IconData> icons = {
    'add_task': Icons.add_task,
    'folder': Icons.folder,
    'fitness_center': Icons.fitness_center,
    'flag': Icons.flag,
    'restaurant': Icons.restaurant,
    'menu_book': Icons.menu_book,
    'lightbulb': Icons.lightbulb,
    'rocket_launch': Icons.rocket_launch,
    'receipt_long': Icons.receipt_long,
    'savings': Icons.savings,
    'home': Icons.home,
    'build': Icons.build,
  };

  /// Get icon for a quick action
  static IconData getIcon(String? iconName) {
    return icons[iconName] ?? Icons.add;
  }
}
