-- =====================================================
-- TOPLA.APP - STORAGE BUCKETS SETUP
-- Supabase Dashboard > SQL Editor da ishga tushiring
-- =====================================================

-- 1. SHOPS BUCKET (Do'kon rasmlari uchun)
-- =====================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'shops', 
  'shops', 
  true,
  5242880,  -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'];

-- 2. PRODUCTS BUCKET (Mahsulot rasmlari uchun)
-- =====================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'products', 
  'products', 
  true,  
  10485760,  -- 10MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 10485760,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'];

-- 3. AVATARS BUCKET (Foydalanuvchi profil rasmlari)
-- =====================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars', 
  'avatars', 
  true,
  2097152,  -- 2MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 2097152,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp'];

-- 4. BANNERS BUCKET (App bannerlari - admin uchun)
-- =====================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'banners', 
  'banners', 
  true,
  5242880,  -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'];

-- =====================================================
-- RLS POLICIES - XAVFSIZLIK QOIDALARI
-- =====================================================

-- Avvalgi policy'larni o'chirish (agar mavjud bo'lsa)
DROP POLICY IF EXISTS "shops_select_policy" ON storage.objects;
DROP POLICY IF EXISTS "shops_insert_policy" ON storage.objects;
DROP POLICY IF EXISTS "shops_update_policy" ON storage.objects;
DROP POLICY IF EXISTS "shops_delete_policy" ON storage.objects;

DROP POLICY IF EXISTS "products_select_policy" ON storage.objects;
DROP POLICY IF EXISTS "products_insert_policy" ON storage.objects;
DROP POLICY IF EXISTS "products_update_policy" ON storage.objects;
DROP POLICY IF EXISTS "products_delete_policy" ON storage.objects;

DROP POLICY IF EXISTS "avatars_select_policy" ON storage.objects;
DROP POLICY IF EXISTS "avatars_insert_policy" ON storage.objects;
DROP POLICY IF EXISTS "avatars_update_policy" ON storage.objects;
DROP POLICY IF EXISTS "avatars_delete_policy" ON storage.objects;

DROP POLICY IF EXISTS "banners_select_policy" ON storage.objects;
DROP POLICY IF EXISTS "banners_insert_policy" ON storage.objects;
DROP POLICY IF EXISTS "banners_update_policy" ON storage.objects;
DROP POLICY IF EXISTS "banners_delete_policy" ON storage.objects;

-- =====================================================
-- SHOPS BUCKET POLICIES
-- =====================================================

-- Hamma ko'ra oladi
CREATE POLICY "shops_select_policy" ON storage.objects
FOR SELECT USING (bucket_id = 'shops');

-- Faqat do'kon egasi yuklaydi (shops/{shop_id}/... papkasiga)
CREATE POLICY "shops_insert_policy" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'shops' AND
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM public.shops 
    WHERE id = (storage.foldername(name))[1]::uuid 
    AND owner_id = auth.uid()
  )
);

-- Faqat do'kon egasi yangilaydi
CREATE POLICY "shops_update_policy" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'shops' AND
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM public.shops 
    WHERE id = (storage.foldername(name))[1]::uuid 
    AND owner_id = auth.uid()
  )
);

-- Faqat do'kon egasi o'chiradi
CREATE POLICY "shops_delete_policy" ON storage.objects
FOR DELETE USING (
  bucket_id = 'shops' AND
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM public.shops 
    WHERE id = (storage.foldername(name))[1]::uuid 
    AND owner_id = auth.uid()
  )
);

-- =====================================================
-- PRODUCTS BUCKET POLICIES
-- =====================================================

-- Hamma ko'ra oladi
CREATE POLICY "products_select_policy" ON storage.objects
FOR SELECT USING (bucket_id = 'products');

-- Vendor o'z mahsulotlariga rasm yuklaydi
CREATE POLICY "products_insert_policy" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'products' AND
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM public.shops 
    WHERE id = (storage.foldername(name))[1]::uuid 
    AND owner_id = auth.uid()
  )
);

-- Vendor o'z mahsulot rasmlarini yangilaydi
CREATE POLICY "products_update_policy" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'products' AND
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM public.shops 
    WHERE id = (storage.foldername(name))[1]::uuid 
    AND owner_id = auth.uid()
  )
);

-- Vendor o'z mahsulot rasmlarini o'chiradi
CREATE POLICY "products_delete_policy" ON storage.objects
FOR DELETE USING (
  bucket_id = 'products' AND
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM public.shops 
    WHERE id = (storage.foldername(name))[1]::uuid 
    AND owner_id = auth.uid()
  )
);

-- =====================================================
-- AVATARS BUCKET POLICIES
-- =====================================================

-- Hamma ko'ra oladi
CREATE POLICY "avatars_select_policy" ON storage.objects
FOR SELECT USING (bucket_id = 'avatars');

-- Foydalanuvchi faqat o'z avatarini yuklaydi (avatars/{user_id}/...)
CREATE POLICY "avatars_insert_policy" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'avatars' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Foydalanuvchi faqat o'z avatarini yangilaydi
CREATE POLICY "avatars_update_policy" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'avatars' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Foydalanuvchi faqat o'z avatarini o'chiradi
CREATE POLICY "avatars_delete_policy" ON storage.objects
FOR DELETE USING (
  bucket_id = 'avatars' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- =====================================================
-- BANNERS BUCKET POLICIES (faqat admin)
-- =====================================================

-- Hamma ko'ra oladi
CREATE POLICY "banners_select_policy" ON storage.objects
FOR SELECT USING (bucket_id = 'banners');

-- Faqat admin yuklaydi
CREATE POLICY "banners_insert_policy" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'banners' AND
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Faqat admin yangilaydi
CREATE POLICY "banners_update_policy" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'banners' AND
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Faqat admin o'chiradi
CREATE POLICY "banners_delete_policy" ON storage.objects
FOR DELETE USING (
  bucket_id = 'banners' AND
  auth.role() = 'authenticated' AND
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- =====================================================
-- TEKSHIRISH
-- =====================================================
SELECT 
  id as bucket_name,
  public,
  file_size_limit / 1048576 as max_mb,
  allowed_mime_types
FROM storage.buckets
WHERE id IN ('shops', 'products', 'avatars', 'banners');
