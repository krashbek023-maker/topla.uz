import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../core/repositories/repositories.dart';
import '../../models/models.dart';

/// Supabase bilan Auth operatsiyalari implementatsiyasi
class AuthRepositoryImpl implements IAuthRepository {
  final SupabaseClient _client;
  final firebase.FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._client, this._firebaseAuth);

  @override
  String? get currentUserId {
    if (_firebaseAuth.currentUser != null) {
      return _firebaseAuth.currentUser!.uid;
    }
    if (_client.auth.currentUser != null) {
      return _client.auth.currentUser!.id;
    }
    return null;
  }

  @override
  bool get isLoggedIn =>
      _client.auth.currentUser != null || _firebaseAuth.currentUser != null;

  @override
  Future<void> sendOTP(String phone) async {
    await _client.auth.signInWithOtp(
      phone: phone,
      shouldCreateUser: true,
    );
  }

  @override
  Future<AuthResponse> verifyOTP(String phone, String otp) async {
    return await _client.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );
  }

  @override
  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(OAuthProvider.google);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserProfile?> getProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final response =
        await _client.from('profiles').select().eq('id', userId).maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  @override
  Future<void> upsertProfile(UserProfile profile) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Tizimga kiring');

    await _client.from('profiles').upsert(profile.toJson());
  }

  @override
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? avatarUrl,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Tizimga kiring');

    final updates = <String, dynamic>{
      'id': userId,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (firstName != null) updates['first_name'] = firstName;
    if (lastName != null) updates['last_name'] = lastName;
    if (email != null) updates['email'] = email;
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _client.from('profiles').upsert(updates);
  }

  @override
  Future<UserRole> getUserRole() async {
    final profile = await getProfile();
    return profile?.role ?? UserRole.user;
  }
}
