/// Kategoriya modeli
class CategoryModel {
  final String id;
  final String nameUz;
  final String nameRu;
  final String? icon;
  final String? imageUrl;
  final String? parentId;
  final int sortOrder;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.nameUz,
    required this.nameRu,
    this.icon,
    this.imageUrl,
    this.parentId,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      nameUz: json['name_uz'] as String,
      nameRu: json['name_ru'] as String,
      icon: json['icon'] as String?,
      imageUrl: json['image_url'] as String?,
      parentId: json['parent_id'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_uz': nameUz,
      'name_ru': nameRu,
      'icon': icon,
      'image_url': imageUrl,
      'parent_id': parentId,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  /// Til bo'yicha nom olish
  String getName(String locale) {
    return locale == 'ru' ? nameRu : nameUz;
  }
}
