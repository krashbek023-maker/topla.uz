import { fetchOrders } from "@/lib/api/admin";

export type Order = {
  id: string;
  order_number?: string;
  customer?: { full_name?: string; phone?: string };
  shop?: { name?: string };
  total_amount: number;
  payment_method?: string;
  status: string;
  created_at: string;
  [key: string]: any;
};

export async function getOrders(): Promise<Order[]> {
  try {
    const data = await fetchOrders();
    return (data.orders || []).map((o: any) => ({
      id: o.id,
      order_number: o.orderNumber,
      customer: o.customer ? { full_name: o.customer.fullName, phone: o.customer.phone } : undefined,
      shop: o.shop ? { name: o.shop.name } : undefined,
      total_amount: Number(o.totalAmount || 0),
      payment_method: o.paymentMethod,
      status: o.status,
      created_at: o.createdAt,
    }));
  } catch {
    return [];
  }
}

export async function getOrderStats(): Promise<{ total: number; pending: number; processing: number; shipped: number; delivered: number; cancelled: number; totalRevenue: number }> {
  try {
    const data = await fetchOrders();
    const orders = data.orders || [];
    return {
      total: data.pagination?.total || orders.length,
      pending: orders.filter((o: any) => o.status === 'pending').length,
      processing: orders.filter((o: any) => ['confirmed', 'preparing'].includes(o.status)).length,
      shipped: orders.filter((o: any) => o.status === 'shipped').length,
      delivered: orders.filter((o: any) => o.status === 'delivered').length,
      cancelled: orders.filter((o: any) => o.status === 'cancelled').length,
      totalRevenue: orders.reduce((sum: number, o: any) => sum + Number(o.totalAmount || 0), 0),
    };
  } catch {
    return { total: 0, pending: 0, processing: 0, shipped: 0, delivered: 0, cancelled: 0, totalRevenue: 0 };
  }
}

export async function updateOrderStatus(_id: string, _status: string): Promise<void> {
  // Order status managed through backend admin routes
  return;
}