-- =====================================================
-- TOPLA.APP - Kategoriyalar yangilash
-- 35 ta kategoriya - mantiqiy tartibda
-- =====================================================

-- Avvalgi kategoriyalarni o'chirish
DELETE FROM categories;

-- Yangi kategoriyalarni qo'shish
INSERT INTO categories (id, name_uz, name_ru, icon, sort_order, is_active) VALUES

-- 📱 ELEKTRONIKA GURUHI (1-7)
('cat_smartphones', 'Smartfonlar', 'Смартфоны', 'mobile', 1, true),
('cat_tablets', 'Planshetlar', 'Планшеты', 'tablet', 2, true),
('cat_laptops', 'Noutbuklar', 'Ноутбуки', 'laptop', 3, true),
('cat_computers', 'Kompyuterlar', 'Компьютеры', 'monitor', 4, true),
('cat_tv', 'Televizorlar', 'Телевизоры', 'screenmirroring', 5, true),
('cat_headphones', 'Quloqchinlar', 'Наушники', 'headphone', 6, true),
('cat_smartwatch', 'Smart soatlar', 'Смарт часы', 'watch', 7, true),

-- 👔 ERKAKLAR KIYIMI (8-11)
('cat_men_clothing', 'Erkaklar kiyimi', 'Мужская одежда', 'man', 8, true),
('cat_men_shoes', 'Erkaklar poyabzali', 'Мужская обувь', 'ruler', 9, true),
('cat_men_accessories', 'Erkaklar aksessuarlari', 'Мужские аксессуары', 'watch', 10, true),
('cat_men_underwear', 'Erkaklar ichki kiyimi', 'Мужское белье', 'tag', 11, true),

-- 👗 AYOLLAR KIYIMI (12-15)
('cat_women_clothing', 'Ayollar kiyimi', 'Женская одежда', 'woman', 12, true),
('cat_women_shoes', 'Ayollar poyabzali', 'Женская обувь', 'diamonds', 13, true),
('cat_bags', 'Sumkalar', 'Сумки', 'bag_2', 14, true),
('cat_women_accessories', 'Ayollar aksessuarlari', 'Женские аксессуары', 'crown_1', 15, true),

-- 👶 BOLALAR (16-18)
('cat_kids_clothing', 'Bolalar kiyimi', 'Детская одежда', 'happyemoji', 16, true),
('cat_toys', 'O''yinchoqlar', 'Игрушки', 'game', 17, true),
('cat_kids_products', 'Bolalar tovarlari', 'Детские товары', 'gift', 18, true),

-- 🏠 UY-RO'ZG'OR (19-22)
('cat_appliances', 'Maishiy texnika', 'Бытовая техника', 'blend_2', 19, true),
('cat_furniture', 'Mebel', 'Мебель', 'lamp_charge', 20, true),
('cat_kitchen', 'Oshxona anjomlari', 'Кухонные принадлежности', 'coffee', 21, true),
('cat_decor', 'Uy dekori', 'Декор для дома', 'home_2', 22, true),

-- 💄 GO'ZALLIK (23-25)
('cat_perfume', 'Parfyumeriya', 'Парфюмерия', 'drop', 23, true),
('cat_cosmetics', 'Kosmetika', 'Косметика', 'magic_star', 24, true),
('cat_hygiene', 'Shaxsiy gigiyena', 'Личная гигиена', 'brush_1', 25, true),

-- 💊 SALOMATLIK (26-27)
('cat_medicine', 'Dori-darmonlar', 'Лекарства', 'health', 26, true),
('cat_medical', 'Tibbiy tovarlar', 'Медицинские товары', 'hospital', 27, true),

-- 🏃 SPORT (28-29)
('cat_sport_equipment', 'Sport anjomlari', 'Спортивный инвентарь', 'weight_1', 28, true),
('cat_sport_clothing', 'Sport kiyimlari', 'Спортивная одежда', 'running', 29, true),

-- 🍎 OZIQ-OVQAT (30-31)
('cat_food', 'Oziq-ovqat', 'Продукты питания', 'cake', 30, true),
('cat_drinks', 'Ichimliklar', 'Напитки', 'cup', 31, true),

-- 🚗 BOSHQALAR (32-35)
('cat_auto', 'Avtotovarlar', 'Автотовары', 'car', 32, true),
('cat_pets', 'Uy hayvonlari', 'Домашние животные', 'pet', 33, true),
('cat_books', 'Kitoblar', 'Книги', 'book_1', 34, true),
('cat_gifts', 'Sovg''alar', 'Подарки', 'gift', 35, true);

-- =====================================================
-- Tekshirish
-- =====================================================
SELECT id, name_uz, name_ru, icon, sort_order FROM categories ORDER BY sort_order;
