-- =====================================================
-- TOPLA APP - Profiles jadvalini yangilash
-- Bu SQL ni Supabase SQL Editor'da ishga tushiring
-- =====================================================

-- 1. Profiles jadvaliga yangi ustunlar qo'shish
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS email VARCHAR(255),
ADD COLUMN IF NOT EXISTS first_name VARCHAR(100),
ADD COLUMN IF NOT EXISTS last_name VARCHAR(100);

-- 2. Email uchun index (optional, performance uchun)
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);

-- 3. Role ustunini qo'shish (agar yo'q bo'lsa)
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'user';

-- 4. Tekshirish
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'profiles';
