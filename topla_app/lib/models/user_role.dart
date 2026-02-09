/// Foydalanuvchi rollari
enum UserRole { user, vendor, admin, superAdmin }

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.user:
        return 'user';
      case UserRole.vendor:
        return 'vendor';
      case UserRole.admin:
        return 'admin';
      case UserRole.superAdmin:
        return 'super_admin';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'Foydalanuvchi';
      case UserRole.vendor:
        return 'Do\'kon egasi';
      case UserRole.admin:
        return 'Admin';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }

  String get displayNameRu {
    switch (this) {
      case UserRole.user:
        return 'Пользователь';
      case UserRole.vendor:
        return 'Владелец магазина';
      case UserRole.admin:
        return 'Админ';
      case UserRole.superAdmin:
        return 'Супер Админ';
    }
  }

  bool get isAdmin => this == UserRole.admin || this == UserRole.superAdmin;
  bool get isVendor => this == UserRole.vendor;
  bool get canModerate => isAdmin;
  bool get canManageShops => this == UserRole.superAdmin;
  bool get canManageAdmins => this == UserRole.superAdmin;
  bool get canManagePayouts => isAdmin;

  static UserRole fromString(String? role) {
    switch (role) {
      case 'vendor':
        return UserRole.vendor;
      case 'admin':
        return UserRole.admin;
      case 'super_admin':
        return UserRole.superAdmin;
      default:
        return UserRole.user;
    }
  }
}
