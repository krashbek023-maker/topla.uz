import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../features/auth/auth_screen.dart';

/// Auth Guard - Foydalanuvchi tizimga kirganligini tekshiradi
/// Agar kirmagan bo'lsa - Auth sahifasiga yo'naltiradi
class AuthGuard extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AuthGuard({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Loading holatida
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Tizimga kirgan
        if (authProvider.isLoggedIn) {
          return child;
        }

        // Tizimga kirmagan - fallback yoki auth sahifasi
        return fallback ?? const AuthScreen();
      },
    );
  }
}

/// Route guard - Navigator.push uchun
class AuthRouteGuard {
  static Future<T?> push<T>(
    BuildContext context,
    Widget screen, {
    bool requireAuth = true,
  }) async {
    final authProvider = context.read<AuthProvider>();

    if (requireAuth && !authProvider.isLoggedIn) {
      // Auth sahifasiga yo'naltirish
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );

      // Agar login qilsa - davom etish
      if (result == true && authProvider.isLoggedIn) {
        if (context.mounted) {
          return Navigator.push<T>(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        }
      }
      return null;
    }

    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
