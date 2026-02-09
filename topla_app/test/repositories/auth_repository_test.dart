import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:topla_app/core/repositories/i_auth_repository.dart';
import 'package:topla_app/models/models.dart';

/// Mock auth repository for testing
class MockAuthRepository implements IAuthRepository {
  String? _userId;
  UserProfile? _profile;
  UserRole _role = UserRole.user;

  @override
  String? get currentUserId => _userId;

  @override
  bool get isLoggedIn => _userId != null;

  @override
  Future<void> sendOTP(String phone) async {
    await Future.delayed(const Duration(milliseconds: 10));
    // Simulate OTP sending
  }

  @override
  Future<AuthResponse> verifyOTP(String phone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (otp == '123456') {
      _userId = 'user-${phone.hashCode}';
      _profile = UserProfile(
        id: _userId!,
        phone: phone,
        createdAt: DateTime.now(),
      );
      // Return mock AuthResponse - using a minimal mock implementation
      throw UnimplementedError('AuthResponse requires Supabase types');
    }
    throw Exception('Invalid OTP');
  }

  @override
  Future<AuthResponse> signUp(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 10));
    _userId = 'user-${email.hashCode}';
    _profile = UserProfile(
      id: _userId!,
      email: email,
      createdAt: DateTime.now(),
    );
    throw UnimplementedError('AuthResponse requires Supabase types');
  }

  @override
  Future<AuthResponse> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 10));
    _userId = 'user-${email.hashCode}';
    throw UnimplementedError('AuthResponse requires Supabase types');
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  @override
  Future<void> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 10));
    _userId = 'google-user-123';
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 10));
    _userId = null;
    _profile = null;
  }

  @override
  Future<UserProfile?> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _profile;
  }

  @override
  Future<void> upsertProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 10));
    _profile = profile;
  }

  @override
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? avatarUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (_profile != null) {
      _profile = UserProfile(
        id: _profile!.id,
        firstName: firstName ?? _profile!.firstName,
        lastName: lastName ?? _profile!.lastName,
        email: email ?? _profile!.email,
        phone: phone ?? _profile!.phone,
        avatarUrl: avatarUrl ?? _profile!.avatarUrl,
        createdAt: _profile!.createdAt,
      );
    }
  }

  @override
  Future<UserRole> getUserRole() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return _role;
  }

  // Test helpers
  void setUser(String userId, UserProfile? profile, UserRole role) {
    _userId = userId;
    _profile = profile;
    _role = role;
  }

  void reset() {
    _userId = null;
    _profile = null;
    _role = UserRole.user;
  }
}

void main() {
  late MockAuthRepository authRepo;

  setUp(() {
    authRepo = MockAuthRepository();
  });

  group('AuthRepository Tests', () {
    test('isLoggedIn returns false when not logged in', () {
      expect(authRepo.isLoggedIn, isFalse);
      expect(authRepo.currentUserId, isNull);
    });

    test('isLoggedIn returns true after sign in', () {
      authRepo.setUser('user-123', null, UserRole.user);

      expect(authRepo.isLoggedIn, isTrue);
      expect(authRepo.currentUserId, equals('user-123'));
    });

    test('sendOTP completes successfully', () async {
      await expectLater(
        authRepo.sendOTP('+998901234567'),
        completes,
      );
    });

    test('signOut clears user', () async {
      authRepo.setUser('user-123', null, UserRole.user);
      expect(authRepo.isLoggedIn, isTrue);

      await authRepo.signOut();

      expect(authRepo.isLoggedIn, isFalse);
      expect(authRepo.currentUserId, isNull);
    });

    test('getProfile returns null when no profile', () async {
      final profile = await authRepo.getProfile();
      expect(profile, isNull);
    });

    test('getProfile returns profile when set', () async {
      final testProfile = UserProfile(
        id: 'user-123',
        firstName: 'Test',
        lastName: 'User',
        email: 'test@example.com',
        createdAt: DateTime.now(),
      );
      authRepo.setUser('user-123', testProfile, UserRole.user);

      final profile = await authRepo.getProfile();

      expect(profile, isNotNull);
      expect(profile!.firstName, equals('Test'));
      expect(profile.lastName, equals('User'));
    });

    test('upsertProfile saves profile', () async {
      final testProfile = UserProfile(
        id: 'user-123',
        firstName: 'Test',
        lastName: 'User',
        createdAt: DateTime.now(),
      );

      await authRepo.upsertProfile(testProfile);

      final profile = await authRepo.getProfile();
      expect(profile, isNotNull);
      expect(profile!.id, equals('user-123'));
    });

    test('updateProfile updates fields', () async {
      final testProfile = UserProfile(
        id: 'user-123',
        firstName: 'Old',
        lastName: 'Name',
        createdAt: DateTime.now(),
      );
      authRepo.setUser('user-123', testProfile, UserRole.user);

      await authRepo.updateProfile(firstName: 'New', lastName: 'Updated');

      final profile = await authRepo.getProfile();
      expect(profile!.firstName, equals('New'));
      expect(profile.lastName, equals('Updated'));
    });

    test('getUserRole returns correct role', () async {
      authRepo.setUser('admin-123', null, UserRole.admin);

      final role = await authRepo.getUserRole();

      expect(role, equals(UserRole.admin));
    });

    test('getUserRole returns user by default', () async {
      final role = await authRepo.getUserRole();

      expect(role, equals(UserRole.user));
    });

    test('resetPassword completes successfully', () async {
      await expectLater(
        authRepo.resetPassword('test@example.com'),
        completes,
      );
    });

    test('signInWithGoogle sets user', () async {
      await authRepo.signInWithGoogle();

      expect(authRepo.isLoggedIn, isTrue);
      expect(authRepo.currentUserId, equals('google-user-123'));
    });
  });
}
