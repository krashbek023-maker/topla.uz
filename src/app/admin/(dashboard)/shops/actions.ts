"use server";

import { createClient } from "@/lib/supabase/server";
import { revalidatePath } from "next/cache";

export type Shop = {
  id: string;
  name: string;
  slug: string | null;
  description: string | null;
  logo_url: string | null;
  phone: string | null;
  email: string | null;
  address: string | null;
  city: string | null;
  status: "pending" | "active" | "rejected" | "blocked";
  commission_rate: number;
  balance: number;
  rating: number;
  total_orders: number;
  total_products: number;
  created_at: string;
  owner: {
    id: string;
    full_name: string | null;
    email: string | null;
    phone: string | null;
  } | null;
};

export async function getShops(status?: string) {
  const supabase = createClient();

  let query = supabase
    .from("shops")
    .select(`
      *,
      owner:profiles!owner_id (
        id,
        full_name,
        email,
        phone
      )
    `)
    .order("created_at", { ascending: false });

  if (status && status !== "all") {
    query = query.eq("status", status);
  }

  const { data, error } = await query;

  if (error) {
    console.error("Error fetching shops:", error);
    return [];
  }

  return data as Shop[];
}

export async function getShopStats() {
  const supabase = createClient();
  
  const { count: total } = await supabase
    .from("shops")
    .select("*", { count: "exact", head: true });
    
  const { count: pending } = await supabase
    .from("shops")
    .select("*", { count: "exact", head: true })
    .eq("status", "pending");
    
  const { count: active } = await supabase
    .from("shops")
    .select("*", { count: "exact", head: true })
    .eq("status", "active");
    
  const { count: blocked } = await supabase
    .from("shops")
    .select("*", { count: "exact", head: true })
    .eq("status", "blocked");

  return {
    total: total || 0,
    pending: pending || 0,
    active: active || 0,
    blocked: blocked || 0,
  };
}

export async function updateShopStatus(
  id: string,
  status: "active" | "rejected" | "blocked",
  rejectionReason?: string
) {
  const supabase = createClient();

  const updateData: any = { status };
  if (rejectionReason) {
    updateData.rejection_reason = rejectionReason;
  }

  const { error } = await supabase.from("shops").update(updateData).eq("id", id);

  if (error) {
    console.error("Error updating shop status:", error);
    throw new Error("Do'kon statusini yangilashda xatolik");
  }

  revalidatePath("/admin/shops");
}

export async function updateShopCommission(id: string, commissionRate: number) {
  const supabase = createClient();

  const { error } = await supabase
    .from("shops")
    .update({ commission_rate: commissionRate })
    .eq("id", id);

  if (error) {
    console.error("Error updating shop commission:", error);
    throw new Error("Komissiya foizini yangilashda xatolik");
  }

  revalidatePath("/admin/shops");
}
