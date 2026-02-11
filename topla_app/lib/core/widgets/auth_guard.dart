import 'package:flutter/material.dart';
import '../../core/services/api_client.dart';

/// Auth guard — faqat tizimga kirgan foydalanuvchilarga ruxsat beradi
/// Agar token yo'q bo'lsa, auth sahifasiga yo'naltiradi
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final hasToken = ApiClient().hasToken;
    if (!hasToken) {
      // Frame tugagandan keyin yo'naltirish
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/auth');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return child;
  }
}
