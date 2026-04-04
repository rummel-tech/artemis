import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artemis_app/main.dart';

void main() {
  group('ArtemisApp', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(const ArtemisApp());
      expect(find.byType(ArtemisApp), findsOneWidget);
    });

    testWidgets('renders MaterialApp', (tester) async {
      await tester.pumpWidget(const ArtemisApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('uses system theme mode', (tester) async {
      await tester.pumpWidget(const ArtemisApp());
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.system);
    });
  });
}
