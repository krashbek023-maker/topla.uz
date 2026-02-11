import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../core/constants/app_colors.dart';

/// Empty State Widget - Zamonaviy animatsiyali bo'sh holatlar
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? lottieAsset;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.lottieAsset,
    this.actionText,
    this.onAction,
    this.iconColor,
    this.iconSize = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            if (lottieAsset != null)
              Lottie.asset(
                lottieAsset!,
                width: iconSize,
                height: iconSize,
                repeat: true,
              )
            else if (icon != null)
              _AnimatedIcon(
                icon: icon!,
                color: iconColor ?? AppColors.primary.withValues(alpha: 0.6),
                size: iconSize,
              ),

            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action button
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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

/// Animated Icon with pulse effect
class _AnimatedIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _AnimatedIcon({
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  State<_AnimatedIcon> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<_AnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                size: widget.size * 0.5,
                color: widget.color,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Empty Cart Widget
class EmptyCartWidget extends StatelessWidget {
  final VoidCallback onShopNow;

  const EmptyCartWidget({super.key, required this.onShopNow});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      lottieAsset: 'assets/lottie/empty_cart.json',
      iconSize: 200,
      title: 'Savatingiz bo\'sh',
      subtitle: 'Mahsulotlarni savatga qo\'shing va buyurtma bering',
      actionText: 'Xarid qilish',
      onAction: onShopNow,
    );
  }
}

/// Empty Favorites Widget
class EmptyFavoritesWidget extends StatelessWidget {
  final VoidCallback onExplore;

  const EmptyFavoritesWidget({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.favorite_border,
      iconColor: AppColors.error,
      title: 'Sevimlilar ro\'yxati bo\'sh',
      subtitle: 'Yoqtirgan mahsulotlaringizni ❤️ bosib saqlang',
      actionText: 'Mahsulotlarni ko\'rish',
      onAction: onExplore,
    );
  }
}

/// Empty Orders Widget
class EmptyOrdersWidget extends StatelessWidget {
  final VoidCallback onShopNow;

  const EmptyOrdersWidget({super.key, required this.onShopNow});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      lottieAsset: 'assets/lottie/empty_orders.json',
      iconSize: 200,
      title: 'Buyurtmalar yo\'q',
      subtitle: 'Siz hali hech narsa buyurtma qilmagansiz',
      actionText: 'Xarid qilish',
      onAction: onShopNow,
    );
  }
}

/// Empty Notifications Widget
class EmptyNotificationsWidget extends StatelessWidget {
  const EmptyNotificationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.notifications_none,
      iconColor: AppColors.warning,
      title: 'Bildirishnomalar yo\'q',
      subtitle: 'Yangi xabarlar bu yerda ko\'rinadi',
    );
  }
}

/// Empty Search Results Widget
class EmptySearchWidget extends StatelessWidget {
  final String query;
  final VoidCallback? onClear;

  const EmptySearchWidget({
    super.key,
    required this.query,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      iconColor: Colors.grey,
      title: 'Natija topilmadi',
      subtitle:
          '"$query" bo\'yicha hech narsa topilmadi. Boshqa so\'z bilan qidirib ko\'ring.',
      actionText: onClear != null ? 'Tozalash' : null,
      onAction: onClear,
    );
  }
}

/// No Internet Widget
class NoInternetWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.wifi_off,
      iconColor: AppColors.error,
      title: 'Internet aloqasi yo\'q',
      subtitle: 'Iltimos, internet ulanishingizni tekshiring',
      actionText: 'Qayta urinish',
      onAction: onRetry,
    );
  }
}

/// Error Widget
class ErrorStateWidget extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      iconColor: AppColors.error,
      title: 'Xatolik yuz berdi',
      subtitle:
          message ?? 'Nimadir noto\'g\'ri ketdi. Qaytadan urinib ko\'ring.',
      actionText: 'Qayta urinish',
      onAction: onRetry,
    );
  }
}
