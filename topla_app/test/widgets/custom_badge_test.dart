import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:topla_app/widgets/custom_badge.dart';

void main() {
  group('StatusBadge Tests', () {
    testWidgets('should render with text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(text: 'Test Badge'),
          ),
        ),
      );

      expect(find.text('Test Badge'), findsOneWidget);
    });

    testWidgets('should render with icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              text: 'With Icon',
              icon: Icons.check,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });

    testWidgets('should render different badge types', (tester) async {
      for (final type in BadgeType.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatusBadge(text: type.name, type: type),
            ),
          ),
        );

        expect(find.text(type.name), findsOneWidget);
      }
    });

    testWidgets('should render outlined style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              text: 'Outlined',
              outlined: true,
            ),
          ),
        ),
      );

      expect(find.text('Outlined'), findsOneWidget);
    });
  });

  group('OrderStatusBadge Tests', () {
    testWidgets('should show pending status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OrderStatusBadge(status: 'pending'),
          ),
        ),
      );

      expect(find.text('Kutilmoqda'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('should show delivered status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OrderStatusBadge(status: 'delivered'),
          ),
        ),
      );

      expect(find.text('Yetkazildi'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should show cancelled status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OrderStatusBadge(status: 'cancelled'),
          ),
        ),
      );

      expect(find.text('Bekor qilindi'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    });

    testWidgets('should handle unknown status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OrderStatusBadge(status: 'unknown_status'),
          ),
        ),
      );

      expect(find.text('unknown_status'), findsOneWidget);
    });
  });

  group('NotificationBadge Tests', () {
    testWidgets('should render child with count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationBadge(
              count: 5,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('should hide badge when count is zero', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationBadge(
              count: 0,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('should show zero when showZero is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationBadge(
              count: 0,
              showZero: true,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('should show 99+ for large counts', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationBadge(
              count: 150,
              child: Icon(Icons.notifications),
            ),
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });
  });

  group('PromoLabel Tests', () {
    testWidgets('should render NEW label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PromoLabel.newItem(),
          ),
        ),
      );

      expect(find.text('YANGI'), findsOneWidget);
      expect(find.byIcon(Icons.fiber_new), findsOneWidget);
    });

    testWidgets('should render HOT label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PromoLabel.hot(),
          ),
        ),
      );

      expect(find.text('HIT'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('should render SALE label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PromoLabel.sale(),
          ),
        ),
      );

      expect(find.text('CHEGIRMA'), findsOneWidget);
      expect(find.byIcon(Icons.percent), findsOneWidget);
    });
  });

  group('RatingBadge Tests', () {
    testWidgets('should display rating', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingBadge(rating: 4.5),
          ),
        ),
      );

      expect(find.text('4.5'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should display review count', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingBadge(rating: 4.5, reviewCount: 120),
          ),
        ),
      );

      expect(find.text('4.5'), findsOneWidget);
      expect(find.text(' (120)'), findsOneWidget);
    });

    testWidgets('should hide review count in compact mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingBadge(rating: 4.5, reviewCount: 120, compact: true),
          ),
        ),
      );

      expect(find.text('4.5'), findsOneWidget);
      expect(find.text(' (120)'), findsNothing);
    });
  });
}
