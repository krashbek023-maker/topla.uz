-- =====================================================
-- TOPLA APP - Firebase Auth Migration
-- Bu SQL Supabase SQL Editor'da ishga tushiring
-- Firebase user ID'larini qo'llab-quvvatlash uchun
-- =====================================================

-- 0. AVVAL RLS POLICY'LARNI O'CHIRISH
-- cart_items
DROP POLICY IF EXISTS "Users can manage own cart" ON cart_items;
DROP POLICY IF EXISTS "Users can view own cart" ON cart_items;
DROP POLICY IF EXISTS "Users can insert own cart" ON cart_items;
DROP POLICY IF EXISTS "Users can update own cart" ON cart_items;
DROP POLICY IF EXISTS "Users can delete own cart" ON cart_items;

-- favorites
DROP POLICY IF EXISTS "Users can manage own favorites" ON favorites;
DROP POLICY IF EXISTS "Users can view own favorites" ON favorites;
DROP POLICY IF EXISTS "Users can insert own favorites" ON favorites;
DROP POLICY IF EXISTS "Users can update own favorites" ON favorites;
DROP POLICY IF EXISTS "Users can delete own favorites" ON favorites;

-- orders
DROP POLICY IF EXISTS "Users can manage own orders" ON orders;
DROP POLICY IF EXISTS "Users can view own orders" ON orders;
DROP POLICY IF EXISTS "Users can insert own orders" ON orders;
DROP POLICY IF EXISTS "Users can update own orders" ON orders;

-- order_items
DROP POLICY IF EXISTS "Users can view own order items" ON order_items;
DROP POLICY IF EXISTS "Users can manage own order items" ON order_items;
DROP POLICY IF EXISTS "Users can insert own order items" ON order_items;
DROP POLICY IF EXISTS "Users can update own order items" ON order_items;
DROP POLICY IF EXISTS "Users can delete own order items" ON order_items;

-- addresses
DROP POLICY IF EXISTS "Users can manage own addresses" ON addresses;
DROP POLICY IF EXISTS "Users can view own addresses" ON addresses;
DROP POLICY IF EXISTS "Users can insert own addresses" ON addresses;
DROP POLICY IF EXISTS "Users can update own addresses" ON addresses;
DROP POLICY IF EXISTS "Users can delete own addresses" ON addresses;

-- 1. RLS ni o'chirish
ALTER TABLE cart_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE favorites DISABLE ROW LEVEL SECURITY;
ALTER TABLE orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE order_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE addresses DISABLE ROW LEVEL SECURITY;

-- 2. CART_ITEMS jadvalini yangilash
ALTER TABLE cart_items 
DROP CONSTRAINT IF EXISTS cart_items_user_id_fkey;

ALTER TABLE cart_items 
ALTER COLUMN user_id TYPE TEXT;

-- 3. FAVORITES jadvalini yangilash
ALTER TABLE favorites 
DROP CONSTRAINT IF EXISTS favorites_user_id_fkey;

ALTER TABLE favorites 
ALTER COLUMN user_id TYPE TEXT;

-- 4. ORDERS jadvalini yangilash
ALTER TABLE orders 
DROP CONSTRAINT IF EXISTS orders_user_id_fkey;

ALTER TABLE orders 
ALTER COLUMN user_id TYPE TEXT;

-- 5. ADDRESSES jadvalini yangilash
ALTER TABLE addresses 
DROP CONSTRAINT IF EXISTS addresses_user_id_fkey;

ALTER TABLE addresses 
ALTER COLUMN user_id TYPE TEXT;

-- 6. Unique constraint yangilash (user_id + product_id)
-- cart_items uchun
ALTER TABLE cart_items 
DROP CONSTRAINT IF EXISTS cart_items_user_id_product_id_key;

ALTER TABLE cart_items 
ADD CONSTRAINT cart_items_user_id_product_id_key UNIQUE (user_id, product_id);

-- favorites uchun
ALTER TABLE favorites 
DROP CONSTRAINT IF EXISTS favorites_user_id_product_id_key;

ALTER TABLE favorites 
ADD CONSTRAINT favorites_user_id_product_id_key UNIQUE (user_id, product_id);

-- =====================================================
-- TAYYOR! Endi Firebase userlar ham savat va 
-- sevimlilar bilan ishlashi mumkin
-- =====================================================
