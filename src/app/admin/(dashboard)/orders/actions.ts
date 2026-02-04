'use server'

import { createClient } from '@/lib/supabase/server'

export type Order = {
  id: string
  order_number: string
  total_amount: number
  status: string
  payment_method: string
  payment_status: string
  created_at: string
  customer: {
    id: string
    full_name: string
    email: string
    phone: string
  } | null
  shop: {
    id: string
    name: string
  } | null
  items_count?: number
}

export async function getOrders() {
  const supabase = await createClient()
  
  const { data, error } = await supabase
    .from('orders')
    .select(`
      id,
      order_number,
      total_amount,
      status,
      payment_method,
      payment_status,
      created_at,
      customer:profiles!orders_user_id_fkey(id, full_name, email, phone),
      shop:shops!orders_shop_id_fkey(id, name)
    `)
    .order('created_at', { ascending: false })

  if (error) {
    console.error('Error fetching orders:', error)
    return []
  }

  return (data || []) as Order[]
}

export async function getOrderStats() {
  const supabase = await createClient()

  const { data: all } = await supabase.from('orders').select('id, status, total_amount')
  
  const orders = all || []
  
  return {
    total: orders.length,
    pending: orders.filter(o => o.status === 'pending').length,
    processing: orders.filter(o => o.status === 'processing').length,
    shipped: orders.filter(o => o.status === 'shipped').length,
    delivered: orders.filter(o => o.status === 'delivered').length,
    cancelled: orders.filter(o => o.status === 'cancelled').length,
    totalRevenue: orders.filter(o => o.status === 'delivered').reduce((sum, o) => sum + (o.total_amount || 0), 0)
  }
}

export async function updateOrderStatus(orderId: string, status: string) {
  const supabase = await createClient()

  const { error } = await supabase
    .from('orders')
    .update({ status, updated_at: new Date().toISOString() })
    .eq('id', orderId)

  if (error) {
    throw new Error(error.message)
  }

  return { success: true }
}

export async function getOrderDetails(orderId: string) {
  const supabase = await createClient()

  const { data: order, error: orderError } = await supabase
    .from('orders')
    .select(`
      *,
      customer:profiles!orders_user_id_fkey(id, full_name, email, phone),
      shop:shops!orders_shop_id_fkey(id, name)
    `)
    .eq('id', orderId)
    .single()

  if (orderError) {
    throw new Error(orderError.message)
  }

  const { data: items } = await supabase
    .from('order_items')
    .select(`
      id,
      quantity,
      price,
      product:products(id, name_uz, thumbnail_url)
    `)
    .eq('order_id', orderId)

  return {
    ...order,
    items: items || []
  }
}
