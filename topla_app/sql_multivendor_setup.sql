-- Multi-Vendor va Admin Panel uchun yangilanishlar
-- Ushbu kodni Supabase SQL Editor da ishga tushiring

-- 1. Profiles jadvaliga role va shop_id qo'shish
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'customer',
ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT false;

-- Role turlari: 'admin', 'vendor', 'customer'
-- Default admin yaratish uchun: UPDATE profiles SET role = 'admin' WHERE id = 'YOUR_USER_ID';

-- 2. Shops (Do'konlar) jadvali
CREATE TABLE IF NOT EXISTS shops (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE,
    description TEXT,
    logo_url TEXT,
    phone VARCHAR(20),
    address TEXT,
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'active', 'rejected', 'blocked'
    commission_rate DECIMAL(5,2) DEFAULT 10.00,
    balance DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Products jadvalini shops ga ulash
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'pending'; -- 'pending', 'approved', 'rejected'

-- 4. Orders jadvaliga shop_id qo'shish (Oddiy MVP variant: bitta buyurtma = bitta do'kon)
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS shop_id UUID REFERENCES shops(id),
ADD COLUMN IF NOT EXISTS payment_method VARCHAR(50) DEFAULT 'cash',
ADD COLUMN IF NOT EXISTS payment_status VARCHAR(20) DEFAULT 'pending';

-- 5. Subcategories uchun o'zgarishlar (agar kerak bo'lsa)
-- Categories jadvali allaqachon parent_id ga ega, shuning uchun bu qism shart emas.

-- 6. Payouts (Pul yechish) jadvali
CREATE TABLE IF NOT EXISTS payouts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    shop_id UUID REFERENCES shops(id),
    amount DECIMAL(15,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'rejected'
    card_number VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS (Row Level Security) Policies
ALTER TABLE shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE payouts ENABLE ROW LEVEL SECURITY;

-- Shops policies
CREATE POLICY "Public shops are viewable by everyone" ON shops FOR SELECT USING (status = 'active');
CREATE POLICY "Vendors can view own shop" ON shops FOR SELECT USING (auth.uid() = owner_id);
CREATE POLICY "Vendors can update own shop" ON shops FOR UPDATE USING (auth.uid() = owner_id);
CREATE POLICY "Vendors can insert own shop" ON shops FOR INSERT WITH CHECK (auth.uid() = owner_id);

-- Admin policies (Adminga hamma narsa ruxsat)
-- Eslatma: Admin tekshiruvi uchun function kerak bo'ladi yoki oddiyroq yo'l sifatida public qilamiz hozircha
