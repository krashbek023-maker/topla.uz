import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/repositories/repositories.dart';
import '../models/models.dart';

/// Auth holati uchun Provider
/// Repository pattern bilan - backend o'zgarganda bu kod o'zgarmaydi
class AuthProvider extends ChangeNotifier {
  final IAuthRepository _authRepo;

  /// Auth state subscription - memory leak oldini olish uchun
  StreamSubscription<AuthState>? _authStateSubscription;

  AuthProvider(this._authRepo) {
    _init();
  }

  // State
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _authRepo.isLoggedIn;
  String? get error => _error;
  String? get currentUserId => _authRepo.currentUserId;
  String? get phoneNumber => _profile?.phone;

  void _init() {
    // Auth state changes ni kuzatish
    // Subscription ni saqlash - dispose da bekor qilish uchun
    _authStateSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (data.session?.user != null) {
          loadProfile();
        } else {
          _profile = null;
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint('Auth state change error: $error');
      },
    );

    // Profil yuklash
    if (isLoggedIn) {
      _loadOrCreateProfile();
    }
  }

  @override
  void dispose() {
    // Memory leak oldini olish - subscription ni bekor qilish
    _authStateSubscription?.cancel();
    _authStateSubscription = null;
    super.dispose();
  }

  Future<void> _loadOrCreateProfile() async {
    if (!isLoggedIn) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _authRepo.getProfile();

      // Agar profil yo'q bo'lsa yoki Google orqali kirgan bo'lsa - profilni yaratish/yangilash
      if (currentUserId != null) {
        final user = Supabase.instance.client.auth.currentUser;
        final metadata = user?.userMetadata;

        // Google orqali kirgan foydalanuvchi ma'lumotlarini olish
        final googleName =
            metadata?['full_name'] as String? ?? metadata?['name'] as String?;
        final googleAvatar = metadata?['avatar_url'] as String? ??
            metadata?['picture'] as String?;
        final googleEmail = user?.email;

        // Profil yo'q bo'lsa yoki Google ma'lumotlari mavjud bo'lsa
        if (_profile == null) {
          // Yangi profil yaratish
          String? firstName;
          String? lastName;

          if (googleName != null && googleName.isNotEmpty) {
            final nameParts = googleName.split(' ');
            firstName = nameParts.first;
            lastName =
                nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;
          }

          final newProfile = UserProfile(
            id: currentUserId!,
            firstName: firstName,
            lastName: lastName,
            fullName: googleName,
            email: googleEmail,
            avatarUrl: googleAvatar,
          );

          await _authRepo.upsertProfile(newProfile);
          _profile = newProfile;
        } else if (_profile!.firstName == null &&
            _profile!.avatarUrl == null &&
            googleName != null) {
          // Profil bor lekin Google ma'lumotlari yo'q - yangilash
          String? firstName;
          String? lastName;

          if (googleName.isNotEmpty) {
            final nameParts = googleName.split(' ');
            firstName = nameParts.first;
            lastName =
                nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;
          }

          await _authRepo.updateProfile(
            firstName: firstName,
            lastName: lastName,
            email: googleEmail ?? _profile!.email,
            avatarUrl: googleAvatar,
          );

          // Profilni qayta yuklash
          _profile = await _authRepo.getProfile();
        }
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Profile load/create error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    await _loadOrCreateProfile();
  }

  Future<void> sendOtp(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepo.sendOTP(phone);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(String phone, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepo.verifyOTP(phone, otp);
      await loadProfile();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepo.signInWithGoogle();
      await loadProfile();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepo.signOut();
      _profile = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? avatarUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepo.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      await loadProfile();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserRole> getUserRole() async {
    return await _authRepo.getUserRole();
  }
}
