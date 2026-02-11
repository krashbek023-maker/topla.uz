import { fetchProducts, blockProduct as apiBlockProduct, unblockProduct as apiUnblockProduct, deleteProduct as apiDeleteProduct } from "@/lib/api/admin";

export type Product = {
  id: string;
  name_uz: string;
  shop?: { name?: string };
  thumbnail_url?: string;
  category?: { name_uz?: string };
  price: number;
  status: "pending" | "approved" | "rejected" | "draft";
  created_at?: string;
  [key: string]: any;
};

export async function getProducts(): Promise<Product[]> {
  try {
    const data = await fetchProducts();
    return (data.products || []).map((p: any) => ({
      id: p.id,
      name_uz: p.nameUz || p.name,
      shop: p.shop ? { name: p.shop.name } : undefined,
      thumbnail_url: p.thumbnailUrl || p.images?.[0],
      category: p.category ? { name_uz: p.category.nameUz } : undefined,
      price: Number(p.price),
      status: p.status === 'active' ? 'approved' : p.status === 'has_errors' ? 'rejected' : p.status === 'on_review' ? 'pending' : p.status,
      created_at: p.createdAt,
      quality_score: p.qualityScore,
      validation_errors: p.validationErrors,
    }));
  } catch {
    return [];
  }
}

export async function getProductStats(): Promise<{ total: number; pending: number; approved: number; rejected: number }> {
  try {
    const data = await fetchProducts();
    return {
      total: data.stats?.total || 0,
      pending: data.stats?.on_review || 0,
      approved: data.stats?.active || 0,
      rejected: (data.stats?.has_errors || 0) + (data.stats?.blocked || 0),
    };
  } catch {
    return { total: 0, pending: 0, approved: 0, rejected: 0 };
  }
}

export async function approveProduct(id: string): Promise<void> {
  await apiUnblockProduct(id);
}

export async function rejectProduct(id: string, reason: string): Promise<void> {
  await apiBlockProduct(id, reason);
}

export async function deleteProduct(id: string): Promise<void> {
  await apiDeleteProduct(id);
}