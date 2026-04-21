import 'package:flutter_test/flutter_test.dart';
import 'package:artemis_app/models/briefing.dart';

void main() {
  group('MorningBriefing.fromJson', () {
    test('parses full briefing response', () {
      final json = {
        'briefing': 'Good morning, Shawn.',
        'date': '2026-04-21',
        'sections': {
          'body': 'Readiness 78',
          'work': 'Top priority: ship',
          'mind': null,
        },
        'stoic_quote': {
          'text': 'You have power over your mind.',
          'author': 'Marcus Aurelius',
        },
        'open_loops': ['Deploy', 'Review PR'],
        'patterns': [
          {
            'name': 'burnout_early_warning',
            'severity': 'warning',
            'headline': 'Burnout Warning',
            'domains': ['body', 'work'],
            'message': 'Pay attention.',
          },
        ],
        'has_critical': false,
      };

      final b = MorningBriefing.fromJson(json);
      expect(b.briefing, 'Good morning, Shawn.');
      expect(b.date, '2026-04-21');
      expect(b.sections['body'], 'Readiness 78');
      expect(b.openLoops.length, 2);
      expect(b.patterns.first.severity, 'warning');
      expect(b.stoicQuote.author, 'Marcus Aurelius');
      expect(b.hasCritical, false);
    });

    test('handles missing optional fields', () {
      final b = MorningBriefing.fromJson({
        'stoic_quote': {'text': 'Test.', 'author': 'Test'},
      });
      expect(b.briefing, '');
      expect(b.patterns, isEmpty);
      expect(b.openLoops, isEmpty);
    });
  });

  group('DetectedPattern.fromJson', () {
    test('parses pattern with all fields', () {
      final p = DetectedPattern.fromJson({
        'name': 'peak_performance_window',
        'severity': 'insight',
        'headline': 'Peak Window',
        'domains': ['body', 'work'],
        'message': 'Protect this.',
      });
      expect(p.name, 'peak_performance_window');
      expect(p.domains, ['body', 'work']);
      expect(p.message, 'Protect this.');
    });
  });

  group('Proposal.fromJson', () {
    test('parses proposal with action', () {
      final p = Proposal.fromJson({
        'id': 'prop_1',
        'type': 'deep_work_block',
        'title': 'Block morning',
        'description': 'Deep work is low.',
        'domain': 'work',
        'status': 'pending',
        'action': {'type': 'create_task', 'module': 'work-planner'},
      });
      expect(p.id, 'prop_1');
      expect(p.status, 'pending');
      expect(p.action?['type'], 'create_task');
    });
  });

  group('ArtemisNotification.fromJson', () {
    test('parses notification', () {
      final n = ArtemisNotification.fromJson({
        'id': 'notif_1',
        'title': 'Alert',
        'body': 'Something happened.',
        'severity': 'warning',
        'domain': 'body',
        'read': false,
        'created_at': '2026-04-21T10:00:00Z',
      });
      expect(n.severity, 'warning');
      expect(n.domain, 'body');
      expect(n.read, false);
    });
  });

  group('WidgetData.fromJson', () {
    test('parses widget snapshot', () {
      final w = WidgetData.fromJson({
        'date': '2026-04-21',
        'status_color': 'amber',
        'readiness': 72,
        'top_priority': 'Ship Phase 5',
        'workouts': {'completed': 3, 'target': 5},
        'streaks': {'morning': 4, 'evening': 2},
        'counts': {
          'notifications': 1,
          'proposals': 2,
          'open_loops': 5,
        },
        'top_pattern': {
          'name': 'learning_application_lag',
          'severity': 'warning',
          'headline': 'Learning-Action Gap',
          'domains': ['mind', 'work'],
        },
        'stoic_quote': {'text': 'Do the work.', 'author': 'Marcus Aurelius'},
      });
      expect(w.statusColor, 'amber');
      expect(w.readiness, 72);
      expect(w.counts['notifications'], 1);
      expect(w.topPattern?.name, 'learning_application_lag');
      expect(w.streaks['morning'], 4);
    });
  });
}
