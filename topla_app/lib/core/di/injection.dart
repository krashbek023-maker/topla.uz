import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

// Repositories - Interfaces
import 'package:topla_app/core/repositories/repositories.dart';

// Repositories - Implementations
import 'package:topla_app/data/repositories/repositories.dart';

// Services
import 'package:topla_app/services/secure_storage_service.dart';

// Providers
import 'package:topla_app/providers/providers.dart';

/// GetIt instance - global service locator
final getIt = GetIt.instance;

/// Dependency Injection setup
/// Bu funksiya app boshida chaqirilishi kerak
Future<void> setupDependencies() async {
  // ==================== EXTERNAL ====================

  // Supabase client
  getIt.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // Firebase Auth
  getIt.registerLazySingleton<firebase.FirebaseAuth>(
    () => firebase.FirebaseAuth.instance,
  );

  // ==================== SERVICES ====================

  // Cache service
  getIt.registerLazySingleton<CacheService>(
    () => CacheService(),
  );

  // Secure storage service
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  // ==================== REPOSITORIES ====================

  // Auth repository
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      getIt<SupabaseClient>(),
      getIt<firebase.FirebaseAuth>(),
    ),
  );

  // Product repository
  getIt.registerLazySingleton<IProductRepository>(
    () => ProductRepositoryImpl(
      getIt<SupabaseClient>(),
      getIt<CacheService>(),
    ),
  );

  // Category repository
  getIt.registerLazySingleton<ICategoryRepository>(
    () => CategoryRepositoryImpl(
      getIt<SupabaseClient>(),
      getIt<CacheService>(),
    ),
  );

  // Cart repository
  getIt.registerLazySingleton<ICartRepository>(
    () => CartRepositoryImpl(
      getIt<SupabaseClient>(),
      () => getIt<IAuthRepository>().currentUserId,
    ),
  );

  // Order repository
  getIt.registerLazySingleton<IOrderRepository>(
    () => OrderRepositoryImpl(
      getIt<SupabaseClient>(),
      () => getIt<IAuthRepository>().currentUserId,
    ),
  );

  // Address repository
  getIt.registerLazySingleton<IAddressRepository>(
    () => AddressRepositoryImpl(
      getIt<SupabaseClient>(),
      () => getIt<IAuthRepository>().currentUserId,
    ),
  );

  // Favorites repository
  getIt.registerLazySingleton<IFavoritesRepository>(
    () => FavoritesRepositoryImpl(
      getIt<SupabaseClient>(),
      () => getIt<IAuthRepository>().currentUserId,
    ),
  );

  // Banner repository
  getIt.registerLazySingleton<IBannerRepository>(
    () => BannerRepositoryImpl(
      getIt<SupabaseClient>(),
      getIt<CacheService>(),
    ),
  );

  // Vendor repository
  getIt.registerLazySingleton<IVendorRepository>(
    () => VendorRepositoryImpl(
      getIt<SupabaseClient>(),
      () => getIt<IAuthRepository>().currentUserId,
    ),
  );

  // Shop repository (public shop access)
  getIt.registerLazySingleton<IShopRepository>(
    () => ShopRepositoryImpl(
      supabase: getIt<SupabaseClient>(),
    ),
  );

  // ==================== PROVIDERS ====================
  // Provider'larni singleton sifatida register qilamiz
  // chunki ChangeNotifier state saqlashi kerak

  getIt.registerLazySingleton<AuthProvider>(
    () => AuthProvider(getIt<IAuthRepository>()),
  );

  getIt.registerLazySingleton<ProductsProvider>(
    () => ProductsProvider(
      getIt<IProductRepository>(),
      getIt<ICategoryRepository>(),
      getIt<IBannerRepository>(),
      getIt<IFavoritesRepository>(),
    ),
  );

  getIt.registerLazySingleton<CartProvider>(
    () => CartProvider(getIt<ICartRepository>()),
  );

  getIt.registerLazySingleton<OrdersProvider>(
    () => OrdersProvider(getIt<IOrderRepository>()),
  );

  getIt.registerLazySingleton<AddressesProvider>(
    () => AddressesProvider(getIt<IAddressRepository>()),
  );

  getIt.registerLazySingleton<VendorProvider>(
    () => VendorProvider(getIt<IVendorRepository>()),
  );

  getIt.registerLazySingleton<ShopProvider>(
    () => ShopProvider(getIt<IShopRepository>()),
  );
}

/// Reset all dependencies (for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}

/// Check if dependencies are registered
bool areDependenciesRegistered() {
  return getIt.isRegistered<IAuthRepository>();
}
