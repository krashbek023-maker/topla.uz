-- Subcategoriyalar qo'shish
-- Bu SQL ni Supabase Dashboard -> SQL Editor da ishga tushiring

-- =====================================================
-- ELEKTRONIKA SUBCATEGORIYALARI
-- =====================================================

INSERT INTO categories (id, name_uz, name_ru, icon, parent_id, sort_order, is_active) VALUES
-- Elektronika subcategoriyalari
(gen_random_uuid(), 'Smartfonlar', 'Смартфоны', 'mobile', (SELECT id FROM categories WHERE name_uz = 'Elektronika' LIMIT 1), 1, true),
(gen_random_uuid(), 'Noutbuklar', 'Ноутбуки', 'monitor_mobbile', (SELECT id FROM categories WHERE name_uz = 'Elektronika' LIMIT 1), 2, true),
(gen_random_uuid(), 'Planshetlar', 'Планшеты', 'cpu', (SELECT id FROM categories WHERE name_uz = 'Elektronika' LIMIT 1), 3, true),
(gen_random_uuid(), 'Quloqchinlar', 'Наушники', 'headphone', (SELECT id FROM categories WHERE name_uz = 'Elektronika' LIMIT 1), 4, true),
(gen_random_uuid(), 'Smart soatlar', 'Смарт-часы', 'watch', (SELECT id FROM categories WHERE name_uz = 'Elektronika' LIMIT 1), 5, true),
(gen_random_uuid(), 'Televizorlar', 'Телевизоры', 'screenmirroring', (SELECT id FROM categories WHERE name_uz = 'Elektronika' LIMIT 1), 6, true);

-- =====================================================
-- KIYIM SUBCATEGORIYALARI
-- =====================================================

INSERT INTO categories (id, name_uz, name_ru, icon, parent_id, sort_order, is_active) VALUES
-- Kiyim subcategoriyalari
(gen_random_uuid(), 'Erkaklar kiyimi', 'Мужская одежда', 'man', (SELECT id FROM categories WHERE name_uz = 'Kiyim' LIMIT 1), 1, true),
(gen_random_uuid(), 'Ayollar kiyimi', 'Женская одежда', 'woman', (SELECT id FROM categories WHERE name_uz = 'Kiyim' LIMIT 1), 2, true),
(gen_random_uuid(), 'Bolalar kiyimi', 'Детская одежда', 'happyemoji', (SELECT id FROM categories WHERE name_uz = 'Kiyim' LIMIT 1), 3, true),
(gen_random_uuid(), 'Poyabzallar', 'Обувь', 'bag_2', (SELECT id FROM categories WHERE name_uz = 'Kiyim' LIMIT 1), 4, true),
(gen_random_uuid(), 'Aksessuarlar', 'Аксессуары', 'diamonds', (SELECT id FROM categories WHERE name_uz = 'Kiyim' LIMIT 1), 5, true);

-- =====================================================
-- UY-RO'ZG'OR SUBCATEGORIYALARI
-- =====================================================

INSERT INTO categories (id, name_uz, name_ru, icon, parent_id, sort_order, is_active) VALUES
(gen_random_uuid(), 'Oshxona jihozlari', 'Кухонная техника', 'blend_2', (SELECT id FROM categories WHERE name_uz = 'Uy-ro''zg''or' OR name_uz = 'Uy uchun' LIMIT 1), 1, true),
(gen_random_uuid(), 'Mebel', 'Мебель', 'home_2', (SELECT id FROM categories WHERE name_uz = 'Uy-ro''zg''or' OR name_uz = 'Uy uchun' LIMIT 1), 2, true),
(gen_random_uuid(), 'Yoritish', 'Освещение', 'lamp_charge', (SELECT id FROM categories WHERE name_uz = 'Uy-ro''zg''or' OR name_uz = 'Uy uchun' LIMIT 1), 3, true),
(gen_random_uuid(), 'Uy bezaklari', 'Декор для дома', 'gift', (SELECT id FROM categories WHERE name_uz = 'Uy-ro''zg''or' OR name_uz = 'Uy uchun' LIMIT 1), 4, true);

-- =====================================================
-- GO'ZALLIK SUBCATEGORIYALARI
-- =====================================================

INSERT INTO categories (id, name_uz, name_ru, icon, parent_id, sort_order, is_active) VALUES
(gen_random_uuid(), 'Teri parvarishi', 'Уход за кожей', 'drop', (SELECT id FROM categories WHERE name_uz = 'Go''zallik' LIMIT 1), 1, true),
(gen_random_uuid(), 'Pardoz', 'Макияж', 'brush_1', (SELECT id FROM categories WHERE name_uz = 'Go''zallik' LIMIT 1), 2, true),
(gen_random_uuid(), 'Soch parvarishi', 'Уход за волосами', 'magic_star', (SELECT id FROM categories WHERE name_uz = 'Go''zallik' LIMIT 1), 3, true),
(gen_random_uuid(), 'Atirlar', 'Парфюмерия', 'lovely', (SELECT id FROM categories WHERE name_uz = 'Go''zallik' LIMIT 1), 4, true);

-- =====================================================
-- SPORT SUBCATEGORIYALARI
-- =====================================================

INSERT INTO categories (id, name_uz, name_ru, icon, parent_id, sort_order, is_active) VALUES
(gen_random_uuid(), 'Fitnes jihozlari', 'Фитнес оборудование', 'weight_1', (SELECT id FROM categories WHERE name_uz = 'Sport' LIMIT 1), 1, true),
(gen_random_uuid(), 'Sport kiyimlari', 'Спортивная одежда', 'activity', (SELECT id FROM categories WHERE name_uz = 'Sport' LIMIT 1), 2, true),
(gen_random_uuid(), 'Tashqi sport', 'Уличный спорт', 'car', (SELECT id FROM categories WHERE name_uz = 'Sport' LIMIT 1), 3, true);

-- =====================================================
-- OZIQ-OVQAT SUBCATEGORIYALARI
-- =====================================================

INSERT INTO categories (id, name_uz, name_ru, icon, parent_id, sort_order, is_active) VALUES
(gen_random_uuid(), 'Oziq-ovqat mahsulotlari', 'Продукты питания', 'milk', (SELECT id FROM categories WHERE name_uz = 'Oziq-ovqat' LIMIT 1), 1, true),
(gen_random_uuid(), 'Shirinliklar', 'Сладости', 'cake', (SELECT id FROM categories WHERE name_uz = 'Oziq-ovqat' LIMIT 1), 2, true),
(gen_random_uuid(), 'Ichimliklar', 'Напитки', 'cup', (SELECT id FROM categories WHERE name_uz = 'Oziq-ovqat' LIMIT 1), 3, true);

-- =====================================================
-- BOLALAR SUBCATEGORIYALARI
-- =====================================================

INSERT INTO categories (id, name_uz, name_ru, icon, parent_id, sort_order, is_active) VALUES
(gen_random_uuid(), 'O''yinchoqlar', 'Игрушки', 'game', (SELECT id FROM categories WHERE name_uz = 'Bolalar' LIMIT 1), 1, true),
(gen_random_uuid(), 'Chaqaloq parvarishi', 'Уход за малышом', 'happyemoji', (SELECT id FROM categories WHERE name_uz = 'Bolalar' LIMIT 1), 2, true),
(gen_random_uuid(), 'Maktab anjomlar', 'Школьные принадлежности', 'book_1', (SELECT id FROM categories WHERE name_uz = 'Bolalar' LIMIT 1), 3, true);

-- =====================================================
-- MEBEL KATEGORIYASI (YANGI)
-- =====================================================

-- Avval asosiy Mebel kategoriyasini qo'shamiz
INSERT INTO categories (id, name_uz, name_ru, icon, parent_id, sort_order, is_active) VALUES
(gen_random_uuid(), 'Mebel', 'Мебель', 'home_2', NULL, 9, true);

-- Mebel subcategoriyalari
INSERT INTO categories (id, name_uz, name_ru, icon, parent_id, sort_order, is_active) VALUES
(gen_random_uuid(), 'Yotoq mebeli', 'Спальная мебель', 'lamp_on', (SELECT id FROM categories WHERE name_uz = 'Mebel' AND parent_id IS NULL LIMIT 1), 1, true),
(gen_random_uuid(), 'Yashash xonasi', 'Гостиная', 'building_3', (SELECT id FROM categories WHERE name_uz = 'Mebel' AND parent_id IS NULL LIMIT 1), 2, true),
(gen_random_uuid(), 'Oshxona mebeli', 'Кухонная мебель', 'reserve', (SELECT id FROM categories WHERE name_uz = 'Mebel' AND parent_id IS NULL LIMIT 1), 3, true),
(gen_random_uuid(), 'Ofis mebeli', 'Офисная мебель', 'briefcase', (SELECT id FROM categories WHERE name_uz = 'Mebel' AND parent_id IS NULL LIMIT 1), 4, true),
(gen_random_uuid(), 'Bolalar mebeli', 'Детская мебель', 'emoji_happy', (SELECT id FROM categories WHERE name_uz = 'Mebel' AND parent_id IS NULL LIMIT 1), 5, true);

-- =====================================================
-- NATIJANI TEKSHIRISH
-- =====================================================

-- Subcategoriyalar ro'yxatini ko'rish
SELECT 
    c.id,
    c.name_uz,
    c.name_ru,
    c.icon,
    p.name_uz as parent_category,
    c.sort_order
FROM categories c
LEFT JOIN categories p ON c.parent_id = p.id
WHERE c.parent_id IS NOT NULL
ORDER BY p.name_uz, c.sort_order;
