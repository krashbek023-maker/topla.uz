/// Banner modeli
class BannerModel {
  final String id;
  final String? titleUz;
  final String? titleRu;
  final String? subtitleUz;
  final String? subtitleRu;
  final String imageUrl;
  final String actionType; // none, product, category, url
  final String? actionValue;
  final int sortOrder;
  final bool isActive;

  BannerModel({
    required this.id,
    this.titleUz,
    this.titleRu,
    this.subtitleUz,
    this.subtitleRu,
    required this.imageUrl,
    this.actionType = 'none',
    this.actionValue,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String,
      titleUz: json['title_uz'] as String?,
      titleRu: json['title_ru'] as String?,
      subtitleUz: json['subtitle_uz'] as String?,
      subtitleRu: json['subtitle_ru'] as String?,
      imageUrl: json['image_url'] as String,
      actionType: json['action_type'] as String? ?? 'none',
      actionValue: json['action_value'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  String? getTitle(String locale) {
    return locale == 'ru' ? titleRu : titleUz;
  }

  String? getSubtitle(String locale) {
    return locale == 'ru' ? subtitleRu : subtitleUz;
  }
}
