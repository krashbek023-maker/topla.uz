import { fetchCategories, createCategory as apiCreateCategory, updateCategory as apiUpdateCategory, deleteCategory as apiDeleteCategory } from "@/lib/api/admin";

export type Category = {
  id: string;
  name_uz: string;
  name_ru?: string | null;
  icon?: string | null;
  parent_id?: string | null;
  sort_order?: number;
  is_active?: boolean;
  children?: Category[];
  created_at?: string;
  [key: string]: any;
};

export async function getCategories(): Promise<Category[]> {
  try {
    const data = await fetchCategories();
    return (data || []).map((c: any) => ({
      id: c.id,
      name_uz: c.nameUz,
      name_ru: c.nameRu,
      icon: c.icon,
      sort_order: c.sortOrder,
      is_active: c.isActive,
      children: (c.subcategories || []).map((s: any) => ({
        id: s.id,
        name_uz: s.nameUz,
        name_ru: s.nameRu,
        parent_id: c.id,
        sort_order: s.sortOrder,
        is_active: s.isActive,
      })),
      created_at: c.createdAt,
    }));
  } catch {
    return [];
  }
}

export async function createCategory(formData: FormData): Promise<void> {
  await apiCreateCategory({
    nameUz: formData.get('name_uz') as string,
    nameRu: formData.get('name_ru') as string,
    icon: formData.get('icon') as string,
    sortOrder: parseInt(formData.get('sort_order') as string || '0'),
    isActive: formData.get('is_active') === 'true',
  });
}

export async function updateCategory(id: string, formData: FormData): Promise<void> {
  await apiUpdateCategory(id, {
    nameUz: formData.get('name_uz') as string,
    nameRu: formData.get('name_ru') as string,
    icon: formData.get('icon') as string,
    sortOrder: parseInt(formData.get('sort_order') as string || '0'),
    isActive: formData.get('is_active') === 'true',
  });
}

export async function deleteCategory(id: string): Promise<void> {
  await apiDeleteCategory(id);
}

export async function toggleCategoryStatus(id: string, isActive: boolean): Promise<void> {
  await apiUpdateCategory(id, { isActive });
}