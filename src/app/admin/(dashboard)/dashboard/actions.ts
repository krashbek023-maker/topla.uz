"use server";

import { createClient } from "@/lib/supabase/server";

export async function getDashboardStats() {
  const supabase = createClient();
  
  // 1. Total Revenue (sum of delivered orders total)
  const { data: revenueData } = await supabase
    .from('orders')
    .select('total')
    .eq('status', 'delivered');
    
  // Calculate total revenue
  const totalRevenue = revenueData?.reduce((sum, order) => sum + Number(order.total), 0) || 0;

  // 2. Today's Orders
  const today = new Date();
  today.setHours(0, 0, 0, 0); // Start of today
  const { count: todayOrdersCount } = await supabase
    .from('orders')
    .select('*', { count: 'exact', head: true })
    .gte('created_at', today.toISOString());

  // 3. Pending Shops
  const { count: pendingShopsCount } = await supabase
    .from('shops')
    .select('*', { count: 'exact', head: true })
    .eq('status', 'pending');

  // 4. Pending Products (Moderation)
  const { count: pendingProductsCount } = await supabase
    .from('products')
    .select('*', { count: 'exact', head: true })
    .eq('status', 'pending');

  return {
    revenue: totalRevenue,
    todayOrders: todayOrdersCount || 0,
    pendingShops: pendingShopsCount || 0,
    pendingProducts: pendingProductsCount || 0,
  };
}

export async function getRecentOrders() {
  const supabase = createClient();
  
  const { data, error } = await supabase
    .from('orders')
    .select(`
      id,
      order_number,
      total,
      status,
      created_at,
      profiles:user_id (
        full_name
      ),
      shops:shop_id (
        name
      )
    `)
    .order('created_at', { ascending: false })
    .limit(5);
    
  if (error) {
    console.error('Error fetching recent orders:', error);
    return [];
  }
  
  // Map/Transform data to match UI expectations if needed
  return data.map(order => ({
    id: order.id,
    order_number: order.order_number,
    customer: order.profiles?.full_name || 'Noma\'lum mijoz',
    shop: order.shops?.name || 'Noma\'lum do\'kon',
    total: order.total,
    status: order.status,
    date: new Date(order.created_at).toLocaleString('uz-UZ'),
  }));
}

export async function getPendingShops() {
  const supabase = createClient();
  
  const { data, error } = await supabase
    .from('shops')
    .select(`
      id,
      name,
      phone,
      created_at,
      owner:owner_id (
        full_name,
        email
      )
    `)
    .eq('status', 'pending')
    .order('created_at', { ascending: false })
    .limit(5);

  if (error) {
    console.error('Error fetching pending shops:', error);
    return [];
  }

  return data.map(shop => ({
    id: shop.id,
    name: shop.name,
    owner: shop.owner?.full_name || 'Noma\'lum',
    phone: shop.phone,
    date: new Date(shop.created_at).toLocaleDateString('uz-UZ'),
    email: shop.owner?.email
  }));
}
