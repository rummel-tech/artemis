import 'package:flutter_test/flutter_test.dart';
import 'package:artemis_app/models/models.dart';

void main() {
  group('ModuleStatus', () {
    test('fromJson creates valid object', () {
      final json = {
        'name': 'workout-planner',
        'status': 'active',
      };
      final status = ModuleStatus.fromJson(json);
      expect(status.name, 'workout-planner');
      expect(status.status, 'active');
    });

    test('toJson creates valid map', () {
      final status = ModuleStatus(name: 'test', status: 'active');
      final json = status.toJson();
      expect(json['name'], 'test');
      expect(json['status'], 'active');
    });

    test('isActive returns true for active status', () {
      final active = ModuleStatus(name: 'test', status: 'active');
      final inactive = ModuleStatus(name: 'test', status: 'inactive');
      expect(active.isActive, isTrue);
      expect(inactive.isActive, isFalse);
    });

    test('JSON round-trip preserves data', () {
      final original = ModuleStatus(name: 'planner', status: 'active');
      final json = original.toJson();
      final restored = ModuleStatus.fromJson(json);
      expect(restored.name, original.name);
      expect(restored.status, original.status);
    });
  });

  group('ModuleManifest', () {
    test('fromJson creates valid object', () {
      final json = {
        'name': 'Workout Planner',
        'version': '1.0.0',
        'description': 'Plan workouts',
        'icon': 'fitness_center',
        'color': '#2196F3',
        'quick_actions': [
          {'id': 'start', 'label': 'Start Workout'},
        ],
      };
      final manifest = ModuleManifest.fromJson(json);
      expect(manifest.name, 'Workout Planner');
      expect(manifest.version, '1.0.0');
      expect(manifest.description, 'Plan workouts');
      expect(manifest.icon, 'fitness_center');
      expect(manifest.color, '#2196F3');
      expect(manifest.quickActions.length, 1);
    });

    test('fromJson handles missing quickActions', () {
      final json = {
        'name': 'Test',
        'version': '1.0.0',
        'description': 'Test module',
        'icon': 'star',
        'color': '#FF0000',
      };
      final manifest = ModuleManifest.fromJson(json);
      expect(manifest.quickActions, isEmpty);
    });

    test('toJson creates valid map', () {
      final manifest = ModuleManifest(
        name: 'Test',
        version: '2.0.0',
        description: 'A test',
        icon: 'star',
        color: '#00FF00',
        quickActions: [
          {'id': 'action1', 'label': 'Do Something'},
        ],
      );
      final json = manifest.toJson();
      expect(json['name'], 'Test');
      expect(json['version'], '2.0.0');
      expect(json['quick_actions'].length, 1);
    });

    test('JSON round-trip preserves data', () {
      final original = ModuleManifest(
        name: 'Planner',
        version: '1.0.0',
        description: 'Plans things',
        icon: 'calendar',
        color: '#0000FF',
      );
      final json = original.toJson();
      final restored = ModuleManifest.fromJson(json);
      expect(restored.name, original.name);
      expect(restored.version, original.version);
      expect(restored.description, original.description);
    });
  });

  group('ActionRequest', () {
    test('toJson creates valid map', () {
      final request = ActionRequest(
        action: 'create_task',
        data: {'title': 'Test Task'},
      );
      final json = request.toJson();
      expect(json['action'], 'create_task');
      expect(json['data']['title'], 'Test Task');
    });

    test('default data is empty map', () {
      final request = ActionRequest(action: 'list_tasks');
      final json = request.toJson();
      expect(json['data'], isEmpty);
    });
  });
}
