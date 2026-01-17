import 'package:flutter_test/flutter_test.dart';
import 'package:artemis_app/models/models.dart';

void main() {
  group('ModuleStatus', () {
    test('fromJson creates valid object', () {
      final json = {
        'name': 'test',
        'enabled': true,
        'healthy': true,
        'message': 'Test message',
      };

      final status = ModuleStatus.fromJson(json);

      expect(status.name, 'test');
      expect(status.enabled, true);
      expect(status.healthy, true);
      expect(status.message, 'Test message');
    });

    test('toJson creates valid map', () {
      final status = ModuleStatus(
        name: 'test',
        enabled: true,
        healthy: false,
        message: 'Test',
      );

      final json = status.toJson();

      expect(json['name'], 'test');
      expect(json['enabled'], true);
      expect(json['healthy'], false);
      expect(json['message'], 'Test');
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

      expect(json['data'], {});
    });
  });
}
