-- ============================================
-- Yetkazish oqimi uchun yangi ustunlar
-- Supabase Dashboard > SQL Editor da ishga tushiring
-- ============================================

-- 1. Qabul qiluvchi ismi
ALTER TABLE orders ADD COLUMN IF NOT EXISTS recipient_name TEXT;

-- 2. Qabul qiluvchi telefon raqami
ALTER TABLE orders ADD COLUMN IF NOT EXISTS recipient_phone TEXT;

-- 3. Yetkazish usuli (courier / pickup)
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_method TEXT DEFAULT 'courier';

-- RLS policy yangilash (agar kerak bo'lsa)
-- Yangi ustunlar avtomatik mavjud policy ga tushadi

-- Tekshirish
SELECT column_name, data_type, column_default 
FROM information_schema.columns 
WHERE table_name = 'orders' 
AND column_name IN ('recipient_name', 'recipient_phone', 'delivery_method');
