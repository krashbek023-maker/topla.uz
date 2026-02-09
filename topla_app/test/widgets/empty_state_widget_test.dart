import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:topla_app/widgets/empty_state_widget.dart';

void main() {
  group('EmptyStateWidget Tests', () {
    testWidgets('should render cart empty state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(type: EmptyStateType.cart),
          ),
        ),
      );

      expect(find.text('Savat bo\'sh'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('should render orders empty state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(type: EmptyStateType.orders),
          ),
        ),
      );

      expect(find.text('Buyurtmalar yo\'q'), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    });

    testWidgets('should render favorites empty state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(type: EmptyStateType.favorites),
          ),
        ),
      );

      expect(find.text('Sevimlilar bo\'sh'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
    });

    testWidgets('should render search empty state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(type: EmptyStateType.search),
          ),
        ),
      );

      expect(find.text('Hech narsa topilmadi'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('should render custom title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'Custom Title',
              subtitle: 'Custom Subtitle',
            ),
          ),
        ),
      );

      expect(find.text('Custom Title'), findsOneWidget);
      expect(find.text('Custom Subtitle'), findsOneWidget);
    });

    testWidgets('should render action button', (tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              actionText: 'Action Button',
              onAction: () => buttonPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Action Button'), findsOneWidget);

      await tester.tap(find.text('Action Button'));
      expect(buttonPressed, isTrue);
    });

    testWidgets('should render custom icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              customIcon: Icons.star,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('SimpleEmptyState Tests', () {
    testWidgets('should render with message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleEmptyState(message: 'No items'),
          ),
        ),
      );

      expect(find.text('No items'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('should render with custom icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SimpleEmptyState(
              message: 'Empty',
              icon: Icons.folder_open,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });
  });

  group('EmptyStateType Tests', () {
    test('should have all expected types', () {
      expect(EmptyStateType.values.length, equals(8));
      expect(EmptyStateType.values.contains(EmptyStateType.cart), isTrue);
      expect(EmptyStateType.values.contains(EmptyStateType.orders), isTrue);
      expect(EmptyStateType.values.contains(EmptyStateType.favorites), isTrue);
      expect(EmptyStateType.values.contains(EmptyStateType.search), isTrue);
      expect(EmptyStateType.values.contains(EmptyStateType.products), isTrue);
      expect(
          EmptyStateType.values.contains(EmptyStateType.notifications), isTrue);
      expect(EmptyStateType.values.contains(EmptyStateType.messages), isTrue);
      expect(EmptyStateType.values.contains(EmptyStateType.general), isTrue);
    });
  });
}
