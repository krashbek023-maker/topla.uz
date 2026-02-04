"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export type Product = {
  id: string;
  name_uz: string;
  name_ru: string | null;
  slug: string | null;
  price: number;
  compare_price: number | null;
  quantity: number;
  thumbnail_url: string | null;
  images: string[];
  status: "pending" | "approved" | "rejected" | "draft";
  rejection_reason: string | null;
  is_active: boolean;
  created_at: string;
  shop: {
    id: string;
    name: string;
  } | null;
  category: {
    id: string;
    name_uz: string;
  } | null;
};

export async function getProducts(status?: string) {
  const supabase = createClient();

  let query = supabase
    .from("products")
    .select(`
      id,
      name_uz,
      name_ru,
      slug,
      price,
      compare_price,
      quantity,
      thumbnail_url,
      images,
      status,
      rejection_reason,
      is_active,
      created_at,
      shop:shops!shop_id (
        id,
        name
      ),
      category:categories!category_id (
        id,
        name_uz
      )
    `)
    .order("created_at", { ascending: false });

  if (status && status !== "all") {
    query = query.eq("status", status);
  }

  const { data, error } = await query;

  if (error) {
    console.error("Error fetching products:", error);
    return [];
  }

  return data as Product[];
}

export async function getProductStats() {
  const supabase = createClient();
  
  const { count: total } = await supabase
    .from("products")
    .select("*", { count: "exact", head: true });
    
  const { count: pending } = await supabase
    .from("products")
    .select("*", { count: "exact", head: true })
    .eq("status", "pending");
    
  const { count: approved } = await supabase
    .from("products")
    .select("*", { count: "exact", head: true })
    .eq("status", "approved");
    
  const { count: rejected } = await supabase
    .from("products")
    .select("*", { count: "exact", head: true })
    .eq("status", "rejected");

  return {
    total: total || 0,
    pending: pending || 0,
    approved: approved || 0,
    rejected: rejected || 0,
  };
}

export async function approveProduct(id: string) {
  const supabase = createClient();

  const { error } = await supabase
    .from("products")
    .update({ status: "approved", rejection_reason: null })
    .eq("id", id);

  if (error) {
    console.error("Error approving product:", error);
    throw new Error("Mahsulotni tasdiqlashda xatolik");
  }

  revalidatePath("/admin/products");
}

export async function rejectProduct(id: string, reason: string) {
  const supabase = createClient();

  const { error } = await supabase
    .from("products")
    .update({ status: "rejected", rejection_reason: reason })
    .eq("id", id);

  if (error) {
    console.error("Error rejecting product:", error);
    throw new Error("Mahsulotni rad etishda xatolik");
  }

  revalidatePath("/admin/products");
}

export async function deleteProduct(id: string) {
  const supabase = createClient();

  const { error } = await supabase.from("products").delete().eq("id", id);

  if (error) {
    console.error("Error deleting product:", error);
    throw new Error("Mahsulotni o'chirishda xatolik");
  }

  revalidatePath("/admin/products");
}
