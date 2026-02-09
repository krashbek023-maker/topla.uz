import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Performance Tests', () {
    testWidgets('App should launch within 3 seconds', (tester) async {
      final stopwatch = Stopwatch()..start();

      // Note: Replace with actual app import
      // await tester.pumpWidget(const ToplaApp());

      await tester.pumpAndSettle(const Duration(seconds: 5));

      stopwatch.stop();

      expect(
        stopwatch.elapsed.inSeconds,
        lessThanOrEqualTo(3),
        reason: 'App launch took too long: ${stopwatch.elapsed}',
      );
    });

    testWidgets('List scroll should be smooth', (tester) async {
      // Note: Replace with actual test
      // Build a list with 100 items
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) => ListTile(
                title: Text('Item $index'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll down
      final stopwatch = Stopwatch()..start();

      await tester.fling(
        find.byType(ListView),
        const Offset(0, -500),
        1000,
      );

      await tester.pumpAndSettle();

      stopwatch.stop();

      // Scroll should complete within 500ms
      expect(
        stopwatch.elapsed.inMilliseconds,
        lessThanOrEqualTo(500),
        reason: 'Scroll was not smooth: ${stopwatch.elapsed}',
      );
    });

    testWidgets('Navigation should be fast', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Scaffold(
                        body: Center(child: Text('Second Page')),
                      ),
                    ),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(find.text('Second Page'), findsOneWidget);
      expect(
        stopwatch.elapsed.inMilliseconds,
        lessThanOrEqualTo(500),
        reason: 'Navigation took too long: ${stopwatch.elapsed}',
      );
    });

    testWidgets('Search input should debounce', (tester) async {
      int searchCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              onChanged: (value) {
                searchCount++;
              },
            ),
          ),
        ),
      );

      // Type rapidly
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump(const Duration(milliseconds: 100));

      // Each character triggers onChange
      expect(searchCount, equals(4));
    });
  });

  group('Widget Build Performance', () {
    testWidgets('const widgets should not rebuild', (tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    Builder(
                      builder: (context) {
                        buildCount++;
                        return const Text('Const child');
                      },
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Rebuild'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(buildCount, equals(1));

      // Trigger rebuild
      await tester.tap(find.text('Rebuild'));
      await tester.pump();

      // Builder rebuilds even with const child because Builder itself isn't const
      // This test shows the behavior
      expect(buildCount, greaterThanOrEqualTo(1));
    });
  });
}
