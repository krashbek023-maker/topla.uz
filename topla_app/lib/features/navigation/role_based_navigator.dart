import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_role.dart';
import '../../providers/providers.dart';
import '../main/main_screen.dart';
import '../vendor/vendor_dashboard_screen.dart';

/// Foydalanuvchi roliga qarab navigatsiya
class RoleBasedNavigator extends StatelessWidget {
  const RoleBasedNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final profile = authProvider.profile;

        // Agar foydalanuvchi kirgan va profil yuklangan bo'lsa
        if (authProvider.isLoggedIn && profile != null) {
          final role = profile.role;

          // Vendor - ikki rejimli ekran
          if (role == UserRole.vendor) {
            return const VendorMainScreen();
          }
        }

        // Profil hali yuklanmagan bo'lsa - loading ko'rsatish
        if (authProvider.isLoggedIn &&
            profile == null &&
            authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Oddiy foydalanuvchi va Admin - asosiy ekran
        // Admin uchun web panel ishlatiladi
        return const MainScreen();
      },
    );
  }
}

/// Vendor uchun alohida Bottom Navigation
class VendorMainScreen extends StatefulWidget {
  const VendorMainScreen({super.key});

  @override
  State<VendorMainScreen> createState() => _VendorMainScreenState();
}

class _VendorMainScreenState extends State<VendorMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Vendor panelda bo'lsa, xarid rejimiga qaytarish
        if (_currentIndex == 1) {
          setState(() => _currentIndex = 0);
        }
        // Xarid rejimida MainScreen o'zi handle qiladi
      },
      child: Scaffold(
        body: _currentIndex == 0
            ? const MainScreen()
            : const VendorDashboardScreen(),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Vendor rejim almashtirish paneli
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300,
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildModeButton(
                          icon: Icons.shopping_bag_outlined,
                          selectedIcon: Icons.shopping_bag,
                          label: 'Xarid qilish',
                          isSelected: _currentIndex == 0,
                          onTap: () => setState(() => _currentIndex = 0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildModeButton(
                          icon: Icons.store_outlined,
                          selectedIcon: Icons.store,
                          label: 'Do\'konim',
                          isSelected: _currentIndex == 1,
                          onTap: () => setState(() => _currentIndex = 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 18,
              color: isSelected ? const Color(0xFF2563EB) : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFF2563EB) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
