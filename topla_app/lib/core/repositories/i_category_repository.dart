import '../../models/models.dart';

/// Kategoriya operatsiyalari uchun interface
abstract class ICategoryRepository {
  /// Barcha kategoriyalarni olish
  Future<List<CategoryModel>> getCategories();

  /// Sub-kategoriyalarni olish
  Future<List<CategoryModel>> getSubCategories(String parentId);

  /// Bitta kategoriyani olish
  Future<CategoryModel?> getCategoryById(String id);
}
