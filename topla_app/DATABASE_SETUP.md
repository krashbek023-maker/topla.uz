# 🗄️ TOPLA Database Sozlash Qo'llanmasi

## 📋 1-Qadam: Supabase Dashboard'ga kirish

1. [Supabase Dashboard](https://supabase.com/dashboard) ga boring
2. Loyihangizni tanlang: `urchzigbkfvlpmrsfrlj`
3. Chap menuda **SQL Editor** ni bosing

---

## 📦 2-Qadam: Kategoriyalar qo'shish

SQL Editor'da quyidagi so'rovni ishga tushiring:

```sql
-- Kategoriyalar
INSERT INTO categories (name_uz, name_ru, icon, sort_order, is_active) VALUES
('Elektronika', 'Электроника', 'devices', 1, true),
('Kiyim', 'Одежда', 'checkroom', 2, true),
('Uy-ro''zg''or', 'Дом и быт', 'home', 3, true),
('Go''zallik', 'Красота', 'spa', 4, true),
('Bolalar', 'Детские', 'child_care', 5, true),
('Sport', 'Спорт', 'fitness_center', 6, true),
('Oziq-ovqat', 'Продукты', 'restaurant', 7, true),
('Avto', 'Авто', 'directions_car', 8, true)
ON CONFLICT DO NOTHING;
```

---

## 🛍️ 3-Qadam: Test mahsulotlar qo'shish

```sql
-- Test mahsulotlar
INSERT INTO products (name_uz, name_ru, description_uz, description_ru, price, old_price, category_id, images, stock, rating, review_count, is_featured, is_active, cashback_percent) VALUES
-- Elektronika
('iPhone 15 Pro Max 256GB', 'iPhone 15 Pro Max 256GB', 
 'Apple iPhone 15 Pro Max - eng yangi iPhone. Titanium korpus, A17 Pro chip.', 
 'Apple iPhone 15 Pro Max - новейший iPhone. Титановый корпус, чип A17 Pro.',
 15999000, 17500000, 
 (SELECT id FROM categories WHERE name_uz = 'Elektronika' LIMIT 1), 
 ARRAY['https://images.unsplash.com/photo-1695048133142-1a20484d2569?w=400'], 
 50, 4.8, 124, true, true, 3),

('Samsung Galaxy S24 Ultra', 'Samsung Galaxy S24 Ultra', 
 'Samsung Galaxy S24 Ultra - AI telefon. 200MP kamera, S Pen.', 
 'Samsung Galaxy S24 Ultra - AI телефон. 200MP камера, S Pen.',
 14500000, 15999000, 
 (SELECT id FROM categories WHERE name_uz = 'Elektronika' LIMIT 1), 
 ARRAY['https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400'], 
 35, 4.7, 89, true, true, 5),

('AirPods Pro 2', 'AirPods Pro 2', 
 'Apple AirPods Pro 2 - shovqinni yo''qotish, adaptive audio.', 
 'Apple AirPods Pro 2 - шумоподавление, адаптивное аудио.',
 2850000, 3200000, 
 (SELECT id FROM categories WHERE name_uz = 'Elektronika' LIMIT 1), 
 ARRAY['https://images.unsplash.com/photo-1606220588913-b3aacb4d2f46?w=400'], 
 100, 4.9, 256, true, true, 2),

('MacBook Air M3', 'MacBook Air M3', 
 'Apple MacBook Air M3 chip bilan. 15 soat batareya, 18mm ingichka.', 
 'Apple MacBook Air с чипом M3. 15 часов батареи, 18мм тонкий.',
 18900000, 21000000, 
 (SELECT id FROM categories WHERE name_uz = 'Elektronika' LIMIT 1), 
 ARRAY['https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400'], 
 20, 4.9, 67, true, true, 4),

-- Sport
('Nike Air Max 270', 'Nike Air Max 270', 
 'Nike Air Max 270 - qulay va yengil krossovka. Air Max to''piq.', 
 'Nike Air Max 270 - удобные и легкие кроссовки. Air Max подошва.',
 890000, 1200000, 
 (SELECT id FROM categories WHERE name_uz = 'Sport' LIMIT 1), 
 ARRAY['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400'], 
 80, 4.6, 198, true, true, 4),

('Adidas Ultraboost 23', 'Adidas Ultraboost 23', 
 'Adidas Ultraboost 23 - eng qulay yugurish krossovkasi.', 
 'Adidas Ultraboost 23 - самые удобные беговые кроссовки.',
 1250000, 1500000, 
 (SELECT id FROM categories WHERE name_uz = 'Sport' LIMIT 1), 
 ARRAY['https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=400'], 
 45, 4.8, 156, false, true, 3),

-- Uy-ro'zg'or
('Xiaomi Robot Vacuum S10+', 'Xiaomi Robot Vacuum S10+', 
 'Xiaomi Robot Vacuum S10+ - aqlli changyutgich. LiDAR navigatsiya.', 
 'Xiaomi Robot Vacuum S10+ - умный пылесос. LiDAR навигация.',
 3200000, 4500000, 
 (SELECT id FROM categories WHERE name_uz = 'Uy-ro''zg''or' LIMIT 1), 
 ARRAY['https://images.unsplash.com/photo-1558317374-067fb5f30001?w=400'], 
 25, 4.7, 89, true, true, 5),

('Dyson V15 Detect', 'Dyson V15 Detect', 
 'Dyson V15 Detect - eng kuchli simsiz changyutgich. Lazer texnologiyasi.', 
 'Dyson V15 Detect - самый мощный беспроводной пылесос. Лазерная технология.',
 8500000, 9500000, 
 (SELECT id FROM categories WHERE name_uz = 'Uy-ro''zg''or' LIMIT 1), 
 ARRAY['https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400'], 
 15, 4.9, 45, true, true, 3),

-- Kiyim
('Zara Premium Ko''ylak', 'Zara Premium Рубашка', 
 'Zara Premium erkaklar ko''ylagi. 100% paxta, slim fit.', 
 'Zara Premium мужская рубашка. 100% хлопок, slim fit.',
 450000, 600000, 
 (SELECT id FROM categories WHERE name_uz = 'Kiyim' LIMIT 1), 
 ARRAY['https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=400'], 
 120, 4.5, 78, false, true, 2),

('Levi''s 501 Original', 'Levi''s 501 Original', 
 'Levi''s 501 Original - klassik jinsi shim. Made in USA.', 
 'Levi''s 501 Original - классические джинсы. Made in USA.',
 750000, 950000, 
 (SELECT id FROM categories WHERE name_uz = 'Kiyim' LIMIT 1), 
 ARRAY['https://images.unsplash.com/photo-1542272604-787c3835535d?w=400'], 
 60, 4.7, 234, true, true, 3),

-- Go'zallik
('Dyson Airwrap Complete', 'Dyson Airwrap Complete', 
 'Dyson Airwrap - soch uchun to''liq to''plam. 6 ta nasadka.', 
 'Dyson Airwrap - полный набор для волос. 6 насадок.',
 6500000, 7500000, 
 (SELECT id FROM categories WHERE name_uz = 'Go''zallik' LIMIT 1), 
 ARRAY['https://images.unsplash.com/photo-1522338242042-2d1c1f9e1d94?w=400'], 
 30, 4.9, 156, true, true, 4),

-- Bolalar
('LEGO Technic Ferrari', 'LEGO Technic Ferrari', 
 'LEGO Technic Ferrari 488 GTE - 1677 qism. 10+ yosh uchun.', 
 'LEGO Technic Ferrari 488 GTE - 1677 деталей. Для 10+ лет.',
 1200000, 1500000, 
 (SELECT id FROM categories WHERE name_uz = 'Bolalar' LIMIT 1), 
 ARRAY['https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=400'], 
 40, 4.8, 67, true, true, 5)

ON CONFLICT DO NOTHING;
```

---

## 🎨 4-Qadam: Bannerlar qo'shish

```sql
-- Bannerlar
INSERT INTO banners (title_uz, title_ru, subtitle_uz, subtitle_ru, image_url, action_type, action_value, sort_order, is_active) VALUES
('Katta chegirmalar!', 'Большие скидки!', 
 '50% gacha chegirma', 'Скидки до 50%', 
 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800&h=400&fit=crop', 
 'category', 'elektronika', 1, true),

('Yangi kolleksiya', 'Новая коллекция', 
 'Bahorgi kiyimlar', 'Весенняя одежда', 
 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=400&fit=crop', 
 'category', 'kiyim', 2, true),

('Flash Sale', 'Flash Sale', 
 'Faqat bugun 70% chegirma!', 'Только сегодня скидка 70%!', 
 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=400&fit=crop', 
 'none', '', 3, true)

ON CONFLICT DO NOTHING;
```

---

## 👤 5-Qadam: Admin va Vendor yaratish

### Admin profil

```sql
-- Admin profil yaratish (avval Firebase/Supabase Auth orqali ro'yxatdan o'ting)
-- Keyin profiles jadvaliga qo'shing:

UPDATE profiles 
SET role = 'admin', is_verified = true 
WHERE phone = '+998901234567';  -- O'zingizning telefon raqamingiz
```

### Vendor (Do'kon) yaratish

```sql
-- Vendor profil
UPDATE profiles 
SET role = 'vendor', is_verified = true 
WHERE phone = '+998909876543';  -- Vendor telefon raqami

-- Do'kon yaratish
INSERT INTO shops (owner_id, name, description, logo_url, is_active, is_verified) 
SELECT id, 'Test Do''kon', 'Test do''kon tavsifi', 'https://picsum.photos/200', true, true
FROM profiles WHERE phone = '+998909876543';
```

---

## 🔍 6-Qadam: Tekshirish

```sql
-- Kategoriyalarni tekshirish
SELECT id, name_uz, icon, sort_order FROM categories ORDER BY sort_order;

-- Mahsulotlarni tekshirish  
SELECT id, name_uz, price, category_id, is_active FROM products LIMIT 10;

-- Bannerlarni tekshirish
SELECT id, title_uz, is_active FROM banners;
```

---

## 📱 7-Qadam: Ilovani qayta yuklash

Ma'lumotlar qo'shilgandan so'ng, ilovani qayta yuklang (Hot Restart):

Terminalda `R` tugmasini bosing (Hot Restart)

---

## 🔑 Admin/Vendor Panel

### Admin panelga kirish

1. Ilovada ro'yxatdan o'ting
2. Supabase'da profilingizni `admin` qilib o'zgartiring
3. Ilovani qayta oching
4. Profil → Admin Panel

### Vendor panelga kirish

1. Ilovada ro'yxatdan o'ting
2. Supabase'da profilingizni `vendor` qilib o'zgartiring
3. Do'kon yarating (shops jadvaliga)
4. Ilovani qayta oching
5. Profil → Vendor Panel

---

## 📞 Yordam kerakmi?

Agar muammo bo'lsa:

1. Supabase Dashboard → Logs bo'limini tekshiring
2. Flutter terminalidagi xatolarni ko'ring
3. RLS (Row Level Security) sozlamalarini tekshiring
