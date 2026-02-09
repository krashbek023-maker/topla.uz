import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Empty state types
enum EmptyStateType {
  cart,
  orders,
  favorites,
  search,
  products,
  notifications,
  messages,
  general,
}

/// Empty state widget with optional animation
class EmptyStateWidget extends StatelessWidget {
  final EmptyStateType type;
  final String? title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? customIcon;
  final String? lottieAsset;

  const EmptyStateWidget({
    super.key,
    this.type = EmptyStateType.general,
    this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.customIcon,
    this.lottieAsset,
  });

  IconData get _icon {
    if (customIcon != null) return customIcon!;
    switch (type) {
      case EmptyStateType.cart:
        return Icons.shopping_cart_outlined;
      case EmptyStateType.orders:
        return Icons.receipt_long_outlined;
      case EmptyStateType.favorites:
        return Icons.favorite_outline;
      case EmptyStateType.search:
        return Icons.search_off;
      case EmptyStateType.products:
        return Icons.inventory_2_outlined;
      case EmptyStateType.notifications:
        return Icons.notifications_off_outlined;
      case EmptyStateType.messages:
        return Icons.chat_bubble_outline;
      case EmptyStateType.general:
        return Icons.inbox_outlined;
    }
  }

  String get _defaultTitle {
    switch (type) {
      case EmptyStateType.cart:
        return 'Savat bo\'sh';
      case EmptyStateType.orders:
        return 'Buyurtmalar yo\'q';
      case EmptyStateType.favorites:
        return 'Sevimlilar bo\'sh';
      case EmptyStateType.search:
        return 'Hech narsa topilmadi';
      case EmptyStateType.products:
        return 'Mahsulotlar yo\'q';
      case EmptyStateType.notifications:
        return 'Bildirishnomalar yo\'q';
      case EmptyStateType.messages:
        return 'Xabarlar yo\'q';
      case EmptyStateType.general:
        return 'Ma\'lumot yo\'q';
    }
  }

  String get _defaultSubtitle {
    switch (type) {
      case EmptyStateType.cart:
        return 'Mahsulotlarni qo\'shing va xarid qiling';
      case EmptyStateType.orders:
        return 'Buyurtma berishni boshlang';
      case EmptyStateType.favorites:
        return 'Yoqtirgan mahsulotlaringizni saqlang';
      case EmptyStateType.search:
        return 'Boshqa so\'zlarni sinab ko\'ring';
      case EmptyStateType.products:
        return 'Tez orada mahsulotlar qo\'shiladi';
      case EmptyStateType.notifications:
        return 'Hozircha yangi bildirishnomalar yo\'q';
      case EmptyStateType.messages:
        return 'Hozircha xabarlar yo\'q';
      case EmptyStateType.general:
        return 'Tez orada ma\'lumotlar qo\'shiladi';
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (type) {
      case EmptyStateType.cart:
        return Colors.blue;
      case EmptyStateType.orders:
        return Colors.orange;
      case EmptyStateType.favorites:
        return Colors.red;
      case EmptyStateType.search:
        return Colors.purple;
      case EmptyStateType.products:
        return Colors.green;
      case EmptyStateType.notifications:
        return Colors.amber;
      case EmptyStateType.messages:
        return Colors.teal;
      case EmptyStateType.general:
        return Theme.of(context).primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon or Lottie animation
            if (lottieAsset != null)
              LottieBuilder.asset(
                lottieAsset!,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              )
            else
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _getIconColor(context).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icon,
                  size: 56,
                  color: _getIconColor(context),
                ),
              ),
            const SizedBox(height: 24),

            // Title
            Text(
              title ?? _defaultTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle ?? _defaultSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            // Action button
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getIconColor(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Simple empty state for lists
class SimpleEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const SimpleEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
