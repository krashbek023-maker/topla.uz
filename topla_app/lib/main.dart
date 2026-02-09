import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/di/injection.dart';
import 'providers/providers.dart';
import 'providers/connectivity_provider.dart';
import 'services/connectivity_service.dart';
import 'widgets/connectivity_wrapper.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/navigation/role_based_navigator.dart';
import 'features/auth/auth_screen.dart';
import 'features/auth/phone_auth_screen.dart';
import 'features/auth/otp_screen.dart';
import 'features/favorites/favorites_screen.dart';
import 'features/addresses/addresses_screen.dart';
import 'features/payment/payment_methods_screen.dart';
import 'features/help/help_screen.dart';
import 'features/invite/invite_friend_screen.dart';
import 'features/vendor/vendor_dashboard_screen.dart';
import 'features/orders/orders_screen.dart';
import 'features/profile/purchased_products_screen.dart';
import 'features/profile/returns_screen.dart';
import 'features/profile/reviews_questions_screen.dart';
// Web pages
import 'features/web/landing/web_landing_page.dart';
import 'features/web/vendor/web_vendor_landing.dart';
import 'features/web/vendor/web_vendor_login.dart';
import 'features/web/vendor/web_vendor_register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase - google-services.json orqali avtomatik ishga tushadi
  try {
    await Firebase.initializeApp();
    debugPrint('=== TOPLA: Firebase initialized ===');
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // Supabase ni ishga tushirish
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    debugPrint('=== TOPLA: Supabase initialized ===');
  } catch (e) {
    debugPrint('=== TOPLA: Supabase init ERROR: $e ===');
  }

  // Dependency Injection ni sozlash
  try {
    await setupDependencies();
    debugPrint('=== TOPLA: Dependencies initialized ===');
  } catch (e) {
    debugPrint('=== TOPLA: DI init ERROR: $e ===');
  }

  // Internet aloqasini kuzatish
  try {
    await ConnectivityService().initialize();
    debugPrint('=== TOPLA: Connectivity initialized ===');
  } catch (e) {
    debugPrint('=== TOPLA: Connectivity init ERROR: $e ===');
  }

  // Status bar va navigation bar ni sozlash
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Faqat portret rejim
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  debugPrint('=== TOPLA: runApp() chaqirilmoqda ===');
  runApp(const ToplaApp());
}

class ToplaApp extends StatelessWidget {
  const ToplaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<CartProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ProductsProvider>()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => getIt<OrdersProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<AddressesProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<VendorProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ShopProvider>()),
        ChangeNotifierProvider(
          create: (_) => ConnectivityProvider(ConnectivityService()),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'TOPLA',
            debugShowCheckedModeBanner: false,

            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,

            // Localization
            locale: settings.locale,
            supportedLocales: const [
              Locale('uz'),
              Locale('ru'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // Initial route - Web uchun landing page, mobile uchun splash
            initialRoute: kIsWeb ? '/' : '/mobile',

            // Internet aloqasi banner'i
            builder: (context, child) {
              if (kIsWeb) return child ?? const SizedBox.shrink();
              return ConnectivityWrapper(
                  child: child ?? const SizedBox.shrink());
            },

            // Routes
            routes: {
              // Mobile routes
              '/mobile': (context) => const SplashScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/main': (context) => const RoleBasedNavigator(),
              '/auth': (context) => const AuthScreen(),
              '/phone-auth': (context) => const PhoneAuthScreen(),
              '/otp': (context) => const OtpScreen(),
              '/favorites': (context) => const FavoritesScreen(),
              '/addresses': (context) => const AddressesScreen(),
              '/payment-methods': (context) => const PaymentMethodsScreen(),
              '/help': (context) => const HelpScreen(),
              '/invite': (context) => const InviteFriendScreen(),
              '/orders': (context) => const OrdersScreen(showBackButton: true),
              '/purchased-products': (context) =>
                  const PurchasedProductsScreen(),
              '/returns': (context) => const ReturnsScreen(),
              '/reviews-questions': (context) => const ReviewsQuestionsScreen(),
              '/mobile-vendor': (context) => const VendorDashboardScreen(),

              // Web routes - topla.uz
              '/': (context) =>
                  kIsWeb ? const WebLandingPage() : const SplashScreen(),

              // Vendor panel - vendor.topla.uz
              '/vendor': (context) => const WebVendorLanding(),
              '/vendor/login': (context) => const WebVendorLogin(),
              '/vendor/register': (context) => const WebVendorRegister(),
              '/vendor/dashboard': (context) => const VendorDashboardScreen(),
            },
          );
        },
      ),
    );
  }
}
