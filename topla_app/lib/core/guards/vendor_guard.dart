import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_role.dart';
import '../../features/vendor/create_shop_screen.dart';

/// Vendor Guard - Faqat vendor kirishiga ruxsat
/// Agar vendor emas - do'kon ochish sahifasiga yo'naltiradi
class VendorGuard extends StatelessWidget {
  final Widget child;
  final bool redirectToCreateShop;

  const VendorGuard({
    super.key,
    required this.child,
    this.redirectToCreateShop = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authProvider.isLoggedIn) {
          return _buildNotLoggedIn(context);
        }

        final user = authProvider.profile;
        final isVendor = user?.role == UserRole.vendor;

        if (!isVendor) {
          if (redirectToCreateShop) {
            return const CreateShopScreen();
          }
          return _buildNotVendor(context);
        }

        return child;
      },
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tizimga kiring'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_off_outlined,
                  size: 50,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Tizimga kiring',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Vendor paneliga kirish uchun avval tizimga kiring',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/auth'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Kirish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotVendor(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor bo\'lish'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.store_outlined,
                  size: 50,
                  color: Colors.blue.shade400,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Do\'kon oching',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Mahsulot sotish uchun o\'z do\'koningizni oching',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateShopScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Do\'kon ochish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vendor route helper - navigation uchun
class VendorRouteGuard {
  static Future<T?> push<T>(
    BuildContext context,
    Widget screen, {
    bool redirectToCreateShop = true,
  }) async {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avval tizimga kiring'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pushNamed(context, '/auth');
      return null;
    }

    final isVendor = authProvider.profile?.role == UserRole.vendor;

    if (!isVendor && redirectToCreateShop) {
      return Navigator.push<T>(
        context,
        MaterialPageRoute(builder: (_) => const CreateShopScreen()),
      );
    }

    if (!isVendor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vendor huquqi kerak'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }

    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
