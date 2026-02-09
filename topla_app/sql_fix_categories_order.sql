-- =====================================================
-- TOPLA.APP - Kategoriyalar tartibini to'g'rilash
-- Bu faylni Supabase SQL Editor'da ishga tushiring
-- =====================================================

-- Avval hozirgi kategoriyalarni ko'rish
SELECT id, name_uz, icon, sort_order FROM categories ORDER BY sort_order;

-- =====================================================
-- Variant 1: Sort_order ni yangilash (agar kategoriyalar mavjud bo'lsa)
-- =====================================================

UPDATE categories SET sort_order = 1 WHERE name_uz = 'Elektronika' OR icon = 'devices';
UPDATE categories SET sort_order = 2 WHERE name_uz = 'Kiyim' OR icon = 'checkroom';
UPDATE categories SET sort_order = 3 WHERE name_uz = 'Uy-rozgor' OR icon = 'home';
UPDATE categories SET sort_order = 4 WHERE name_uz = 'Gozallik' OR icon = 'spa';
UPDATE categories SET sort_order = 5 WHERE name_uz = 'Bolalar' OR icon = 'child_care';
UPDATE categories SET sort_order = 6 WHERE name_uz = 'Sport' OR icon = 'fitness_center';
UPDATE categories SET sort_order = 7 WHERE name_uz = 'Oziq-ovqat' OR icon = 'restaurant';
UPDATE categories SET sort_order = 8 WHERE name_uz = 'Avto' OR icon = 'directions_car';

-- Yangilangan tartibni tekshirish
SELECT id, name_uz, icon, sort_order FROM categories ORDER BY sort_order;

-- =====================================================
-- Variant 2: Kategoriyalarni to'liq qayta yaratish
-- (Agar Variant 1 ishlamasa)
-- =====================================================

-- DIQQAT: Bu barcha kategoriyalarni o'chiradi!
-- Mahsulotlar category_id ga bog'langan bo'lsa, avval ularni yangilash kerak

/*
-- Eski kategoriyalarni o'chirish
DELETE FROM categories;

-- Yangi kategoriyalarni to'g'ri tartibda qo'shish
INSERT INTO categories (name_uz, name_ru, icon, sort_order, is_active) VALUES
('Elektronika', 'Электроника', 'devices', 1, true),
('Kiyim', 'Одежда', 'checkroom', 2, true),
('Uy-rozgor', 'Дом и быт', 'home', 3, true),
('Gozallik', 'Красота', 'spa', 4, true),
('Bolalar', 'Детские', 'child_care', 5, true),
('Sport', 'Спорт', 'fitness_center', 6, true),
('Oziq-ovqat', 'Продукты', 'restaurant', 7, true),
('Avto', 'Авто', 'directions_car', 8, true);
*/

-- =====================================================
-- Tartib:
-- 1. Elektronika (devices) - sort_order: 1
-- 2. Kiyim (checkroom) - sort_order: 2
-- 3. Uy-rozgor (home) - sort_order: 3
-- 4. Gozallik (spa) - sort_order: 4
-- 5. Bolalar (child_care) - sort_order: 5
-- 6. Sport (fitness_center) - sort_order: 6
-- 7. Oziq-ovqat (restaurant) - sort_order: 7
-- 8. Avto (directions_car) - sort_order: 8
-- =====================================================
