'use server'

import { createClient } from '@/lib/supabase/server'

export type User = {
  id: string
  full_name: string
  email: string
  phone: string
  role: string
  is_active: boolean
  created_at: string
  avatar_url: string | null
}

export async function getUsers() {
  const supabase = await createClient()
  
  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    console.error('Error fetching users:', error)
    return []
  }

  return (data || []) as User[]
}

export async function getUserStats() {
  const supabase = await createClient()

  const { data: all } = await supabase.from('profiles').select('id, role, is_active')
  
  const users = all || []
  
  return {
    total: users.length,
    customers: users.filter(u => u.role === 'customer' || !u.role).length,
    vendors: users.filter(u => u.role === 'vendor').length,
    admins: users.filter(u => u.role === 'admin').length,
    active: users.filter(u => u.is_active !== false).length,
  }
}

export async function updateUserRole(userId: string, role: string) {
  const supabase = await createClient()

  const { error } = await supabase
    .from('profiles')
    .update({ role, updated_at: new Date().toISOString() })
    .eq('id', userId)

  if (error) {
    throw new Error(error.message)
  }

  return { success: true }
}

export async function toggleUserStatus(userId: string, isActive: boolean) {
  const supabase = await createClient()

  const { error } = await supabase
    .from('profiles')
    .update({ is_active: isActive, updated_at: new Date().toISOString() })
    .eq('id', userId)

  if (error) {
    throw new Error(error.message)
  }

  return { success: true }
}

export async function deleteUser(userId: string) {
  const supabase = await createClient()

  const { error } = await supabase
    .from('profiles')
    .delete()
    .eq('id', userId)

  if (error) {
    throw new Error(error.message)
  }

  return { success: true }
}
