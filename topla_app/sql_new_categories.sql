-- =====================================================
-- TOPLA.APP - Yangi Kategoriyalar (UUID + SLUG)
-- 29 ta asosiy kategoriya + 130 subkategoriya
-- =====================================================

-- Avvalgi kategoriyalarni o'chirish
DELETE FROM categories;

-- =====================================================
-- ASOSIY KATEGORIYALAR (29 ta)
-- =====================================================

INSERT INTO categories (id, name_uz, name_ru, slug, icon, image_url, sort_order, is_active) VALUES

-- 📱 1-GURUH: ELEKTRONIKA (1-4)
('11111111-1111-1111-1111-000000000001', 'Elektronika', 'Электроника', 'elektronika', 'mobile', 'https://images.uzum.uz/chbmhvvg7oh161p22h30/original.jpg', 1, true),
('11111111-1111-1111-1111-000000000002', 'Noutbuklar va kompyuterlar', 'Ноутбуки и компьютеры', 'noutbuklar-kompyuterlar', 'monitor', 'https://images.uzum.uz/ci9pbf3v427tb8uuttjg/original.jpg', 2, true),
('11111111-1111-1111-1111-000000000003', 'Maishiy texnika', 'Бытовая техника', 'maishiy-texnika', 'blend_2', 'https://images.uzum.uz/ci7hc5fv427tb8uunqdg/original.jpg', 3, true),
('11111111-1111-1111-1111-000000000004', 'Televizor va video', 'ТВ и видео', 'televizor-video', 'screenmirroring', 'https://images.uzum.uz/chbmidng7oh161p22hag/original.jpg', 4, true),

-- 👔 2-GURUH: KIYIM VA MODA (5-7)
('11111111-1111-1111-1111-000000000005', 'Kiyim va poyabzal', 'Одежда и обувь', 'kiyim-poyabzal', 'shirt', 'https://images.uzum.uz/chqhjdlbrucs71oghm60/original.jpg', 5, true),
('11111111-1111-1111-1111-000000000006', 'Sumkalar va aksessuarlar', 'Сумки и аксессуары', 'sumkalar-aksessuarlar', 'bag_2', 'https://images.uzum.uz/ci9pd2bv427tb8uutv4g/original.jpg', 6, true),
('11111111-1111-1111-1111-000000000007', 'Zargarlik buyumlari', 'Ювелирные изделия', 'zargarlik-buyumlari', 'diamonds', 'https://images.uzum.uz/ci9pfkrv427tb8uutvug/original.jpg', 7, true),

-- 💄 3-GURUH: GO'ZALLIK VA SALOMATLIK (8-11)
('11111111-1111-1111-1111-000000000008', 'Go''zallik', 'Красота', 'gozallik', 'magic_star', 'https://images.uzum.uz/chbmjd5g7oh161p22hj0/original.jpg', 8, true),
('11111111-1111-1111-1111-000000000009', 'Parfyumeriya', 'Парфюмерия', 'parfyumeriya', 'drop', 'https://images.uzum.uz/ci9pgebv427tb8uutwdg/original.jpg', 9, true),
('11111111-1111-1111-1111-000000000010', 'Gigiena', 'Гигиена', 'gigiena', 'brush_1', 'https://images.uzum.uz/ci9phk3v427tb8uutwt0/original.jpg', 10, true),
('11111111-1111-1111-1111-000000000011', 'Dorixona', 'Аптека', 'dorixona', 'health', 'https://images.uzum.uz/ci9pj3bv427tb8uutxc0/original.jpg', 11, true),

-- 🏠 4-GURUH: UY VA BOG' (12-15)
('11111111-1111-1111-1111-000000000012', 'Uy', 'Дом', 'uy', 'home_2', 'https://images.uzum.uz/chbmkbdg7oh161p22hm0/original.jpg', 12, true),
('11111111-1111-1111-1111-000000000013', 'Mebel', 'Мебель', 'mebel', 'lamp_charge', 'https://images.uzum.uz/ci9pkcbv427tb8uutxqg/original.jpg', 13, true),
('11111111-1111-1111-1111-000000000014', 'Qurilish va ta''mirlash', 'Строительство и ремонт', 'qurilish-tamirlash', 'ruler', 'https://images.uzum.uz/ci9plkrv427tb8uuty90/original.jpg', 14, true),
('11111111-1111-1111-1111-000000000015', 'Uy kimyoviy moddalari', 'Бытовая химия', 'uy-kimyo', 'box_1', 'https://images.uzum.uz/ci9pn2rv427tb8uutyqg/original.jpg', 15, true),

-- 👶 5-GURUH: BOLALAR VA OILA (16-18)
('11111111-1111-1111-1111-000000000016', 'Bolalar mahsulotlari', 'Детские товары', 'bolalar-mahsulotlari', 'happyemoji', 'https://images.uzum.uz/chbmktlg7oh161p22hn0/original.jpg', 16, true),
('11111111-1111-1111-1111-000000000017', 'O''yinchoqlar', 'Игрушки', 'oyinchoqlar', 'game', 'https://images.uzum.uz/ci9pojrv427tb8uutz9g/original.jpg', 17, true),
('11111111-1111-1111-1111-000000000018', 'Maktab va ofis uchun', 'Школа и офис', 'maktab-ofis', 'pen_tool', 'https://images.uzum.uz/ci9pq23v427tb8uutzs0/original.jpg', 18, true),

-- 🍎 6-GURUH: OZIQ-OVQAT (19-21)
('11111111-1111-1111-1111-000000000019', 'Oziq-ovqat mahsulotlari', 'Продукты питания', 'oziq-ovqat', 'milk', 'https://images.uzum.uz/chbmlblg7oh161p22hp0/original.jpg', 19, true),
('11111111-1111-1111-1111-000000000020', 'Shirinliklar va gazaklar', 'Сладости и снеки', 'shirinliklar-gazaklar', 'cake', 'https://images.uzum.uz/ci9prj3v427tb8uu00bg/original.jpg', 20, true),
('11111111-1111-1111-1111-000000000021', 'Ichimliklar', 'Напитки', 'ichimliklar', 'cup', 'https://images.uzum.uz/ci9pt2bv427tb8uu00tg/original.jpg', 21, true),

-- 🚗 7-GURUH: AVTOMOBIL VA SPORT (22-23)
('11111111-1111-1111-1111-000000000022', 'Avtomobil mahsulotlari', 'Автотовары', 'avtomobil-mahsulotlari', 'car', 'https://images.uzum.uz/chbmls5g7oh161p22hq0/original.jpg', 22, true),
('11111111-1111-1111-1111-000000000023', 'Sport va dam olish', 'Спорт и отдых', 'sport-dam-olish', 'weight_1', 'https://images.uzum.uz/ci9pujbv427tb8uu01cg/original.jpg', 23, true),

-- 🎮 8-GURUH: BO'SH VAQT (24-26)
('11111111-1111-1111-1111-000000000024', 'O''yin va konsol', 'Игры и консоли', 'oyin-konsol', 'driver', 'https://images.uzum.uz/ci9pvvrv427tb8uu01ug/original.jpg', 24, true),
('11111111-1111-1111-1111-000000000025', 'Kitoblar', 'Книги', 'kitoblar', 'book', 'https://images.uzum.uz/ci9q0brv427tb8uu02dg/original.jpg', 25, true),
('11111111-1111-1111-1111-000000000026', 'Xobbi va ijodkorlik', 'Хобби и творчество', 'xobbi-ijodkorlik', 'colorfilter', 'https://images.uzum.uz/ci9q1jbv427tb8uu02ug/original.jpg', 26, true),

-- 🐾 9-GURUH: BOSHQALAR (27-29)
('11111111-1111-1111-1111-000000000027', 'Uy hayvonlari', 'Домашние животные', 'uy-hayvonlari', 'pet', 'https://images.uzum.uz/chbmmcng7oh161p22hr0/original.jpg', 27, true),
('11111111-1111-1111-1111-000000000028', 'Gullar va guldastalar', 'Цветы и букеты', 'gullar-guldastalar', 'lovely', 'https://images.uzum.uz/ci9q33rv427tb8uu03dg/original.jpg', 28, true),
('11111111-1111-1111-1111-000000000029', 'Sovg''alar', 'Подарки', 'sovgalar', 'gift', 'https://images.uzum.uz/ci9q4jrv427tb8uu03tg/original.jpg', 29, true);

-- =====================================================
-- SUBKATEGORIYALAR (130 ta)
-- =====================================================

-- 📱 ELEKTRONIKA subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000001', 'Smartfonlar', 'Смартфоны', 'smartfonlar', 'mobile', '11111111-1111-1111-1111-000000000001', 1, true),
('22222222-2222-2222-2222-000000000002', 'Planshetlar', 'Планшеты', 'planshetlar', 'cpu', '11111111-1111-1111-1111-000000000001', 2, true),
('22222222-2222-2222-2222-000000000003', 'Quloqchinlar', 'Наушники', 'quloqchinlar', 'headphone', '11111111-1111-1111-1111-000000000001', 3, true),
('22222222-2222-2222-2222-000000000004', 'Smart soatlar', 'Смарт-часы', 'smart-soatlar', 'watch', '11111111-1111-1111-1111-000000000001', 4, true),
('22222222-2222-2222-2222-000000000005', 'Quvvat banklari', 'Повербанки', 'quvvat-banklari', 'battery_charging', '11111111-1111-1111-1111-000000000001', 5, true),
('22222222-2222-2222-2222-000000000006', 'Kabellar va adapterlar', 'Кабели и адаптеры', 'kabellar-adapterlar', 'tag', '11111111-1111-1111-1111-000000000001', 6, true);

-- 💻 NOUTBUKLAR subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000007', 'Noutbuklar', 'Ноутбуки', 'noutbuklar', 'monitor_mobbile', '11111111-1111-1111-1111-000000000002', 1, true),
('22222222-2222-2222-2222-000000000008', 'Kompyuterlar', 'Компьютеры', 'kompyuterlar', 'monitor', '11111111-1111-1111-1111-000000000002', 2, true),
('22222222-2222-2222-2222-000000000009', 'Monitorlar', 'Мониторы', 'monitorlar', 'monitor', '11111111-1111-1111-1111-000000000002', 3, true),
('22222222-2222-2222-2222-000000000010', 'Klaviaturalar', 'Клавиатуры', 'klaviaturalar', 'keyboard', '11111111-1111-1111-1111-000000000002', 4, true),
('22222222-2222-2222-2222-000000000011', 'Sichqonchalar', 'Мыши', 'sichqonchalar', 'mouse', '11111111-1111-1111-1111-000000000002', 5, true),
('22222222-2222-2222-2222-000000000012', 'Kompyuter qismlari', 'Комплектующие', 'kompyuter-qismlari', 'cpu', '11111111-1111-1111-1111-000000000002', 6, true);

-- 🏠 MAISHIY TEXNIKA subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000013', 'Changyutgichlar', 'Пылесосы', 'changyutgichlar', 'blend_2', '11111111-1111-1111-1111-000000000003', 1, true),
('22222222-2222-2222-2222-000000000014', 'Kir yuvish mashinalari', 'Стиральные машины', 'kir-yuvish-mashinalari', 'blend_2', '11111111-1111-1111-1111-000000000003', 2, true),
('22222222-2222-2222-2222-000000000015', 'Muzlatgichlar', 'Холодильники', 'muzlatgichlar', 'blend_2', '11111111-1111-1111-1111-000000000003', 3, true),
('22222222-2222-2222-2222-000000000016', 'Oshxona texnikasi', 'Кухонная техника', 'oshxona-texnikasi', 'coffee', '11111111-1111-1111-1111-000000000003', 4, true),
('22222222-2222-2222-2222-000000000017', 'Dazmollar', 'Утюги', 'dazmollar', 'blend_2', '11111111-1111-1111-1111-000000000003', 5, true),
('22222222-2222-2222-2222-000000000018', 'Iqlim texnikasi', 'Климатическая техника', 'iqlim-texnikasi', 'blend_2', '11111111-1111-1111-1111-000000000003', 6, true);

-- 📺 TV VA VIDEO subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000019', 'Televizorlar', 'Телевизоры', 'televizorlar', 'screenmirroring', '11111111-1111-1111-1111-000000000004', 1, true),
('22222222-2222-2222-2222-000000000020', 'Proyektorlar', 'Проекторы', 'proyektorlar', 'screenmirroring', '11111111-1111-1111-1111-000000000004', 2, true),
('22222222-2222-2222-2222-000000000021', 'Soundbarlar', 'Саундбары', 'soundbarlar', 'headphone', '11111111-1111-1111-1111-000000000004', 3, true),
('22222222-2222-2222-2222-000000000022', 'TV kronshtaynlar', 'ТВ-кронштейны', 'tv-kronshtaynlar', 'tag', '11111111-1111-1111-1111-000000000004', 4, true);

-- 👔 KIYIM VA POYABZAL subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000023', 'Erkaklar kiyimi', 'Мужская одежда', 'erkaklar-kiyimi', 'man', '11111111-1111-1111-1111-000000000005', 1, true),
('22222222-2222-2222-2222-000000000024', 'Ayollar kiyimi', 'Женская одежда', 'ayollar-kiyimi', 'woman', '11111111-1111-1111-1111-000000000005', 2, true),
('22222222-2222-2222-2222-000000000025', 'Bolalar kiyimi', 'Детская одежда', 'bolalar-kiyimi', 'happyemoji', '11111111-1111-1111-1111-000000000005', 3, true),
('22222222-2222-2222-2222-000000000026', 'Erkaklar poyabzali', 'Мужская обувь', 'erkaklar-poyabzali', 'ruler', '11111111-1111-1111-1111-000000000005', 4, true),
('22222222-2222-2222-2222-000000000027', 'Ayollar poyabzali', 'Женская обувь', 'ayollar-poyabzali', 'diamonds', '11111111-1111-1111-1111-000000000005', 5, true),
('22222222-2222-2222-2222-000000000028', 'Bolalar poyabzali', 'Детская обувь', 'bolalar-poyabzali', 'happyemoji', '11111111-1111-1111-1111-000000000005', 6, true);

-- 👜 SUMKALAR subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000029', 'Ayollar sumkalari', 'Женские сумки', 'ayollar-sumkalari', 'bag_2', '11111111-1111-1111-1111-000000000006', 1, true),
('22222222-2222-2222-2222-000000000030', 'Erkaklar sumkalari', 'Мужские сумки', 'erkaklar-sumkalari', 'bag_2', '11111111-1111-1111-1111-000000000006', 2, true),
('22222222-2222-2222-2222-000000000031', 'Ryukzaklar', 'Рюкзаки', 'ryukzaklar', 'bag_2', '11111111-1111-1111-1111-000000000006', 3, true),
('22222222-2222-2222-2222-000000000032', 'Hamyonlar', 'Кошельки', 'hamyonlar', 'wallet', '11111111-1111-1111-1111-000000000006', 4, true),
('22222222-2222-2222-2222-000000000033', 'Kamarlar', 'Ремни', 'kamarlar', 'tag', '11111111-1111-1111-1111-000000000006', 5, true);

-- 💎 ZARGARLIK subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000034', 'Uzuklar', 'Кольца', 'uzuklar', 'diamonds', '11111111-1111-1111-1111-000000000007', 1, true),
('22222222-2222-2222-2222-000000000035', 'Marjonlar va kulon', 'Колье и подвески', 'marjonlar-kulon', 'diamonds', '11111111-1111-1111-1111-000000000007', 2, true),
('22222222-2222-2222-2222-000000000036', 'Ziraklar', 'Серьги', 'ziraklar', 'diamonds', '11111111-1111-1111-1111-000000000007', 3, true),
('22222222-2222-2222-2222-000000000037', 'Bilakuzuklar', 'Браслеты', 'bilakuzuklar', 'diamonds', '11111111-1111-1111-1111-000000000007', 4, true),
('22222222-2222-2222-2222-000000000038', 'Soatlar', 'Часы', 'soatlar', 'watch', '11111111-1111-1111-1111-000000000007', 5, true);

-- 💄 GO'ZALLIK subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000039', 'Pardoz', 'Макияж', 'pardoz', 'brush_1', '11111111-1111-1111-1111-000000000008', 1, true),
('22222222-2222-2222-2222-000000000040', 'Teri parvarishi', 'Уход за кожей', 'teri-parvarishi', 'drop', '11111111-1111-1111-1111-000000000008', 2, true),
('22222222-2222-2222-2222-000000000041', 'Soch parvarishi', 'Уход за волосами', 'soch-parvarishi', 'magic_star', '11111111-1111-1111-1111-000000000008', 3, true),
('22222222-2222-2222-2222-000000000042', 'Tirnoq parvarishi', 'Уход за ногтями', 'tirnoq-parvarishi', 'brush_1', '11111111-1111-1111-1111-000000000008', 4, true),
('22222222-2222-2222-2222-000000000043', 'Go''zallik asboblari', 'Инструменты красоты', 'gozallik-asboblari', 'brush_1', '11111111-1111-1111-1111-000000000008', 5, true);

-- 🌸 PARFYUMERIYA subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000044', 'Ayollar atiri', 'Женская парфюмерия', 'ayollar-atiri', 'drop', '11111111-1111-1111-1111-000000000009', 1, true),
('22222222-2222-2222-2222-000000000045', 'Erkaklar atiri', 'Мужская парфюмерия', 'erkaklar-atiri', 'drop', '11111111-1111-1111-1111-000000000009', 2, true),
('22222222-2222-2222-2222-000000000046', 'Parfyum to''plamlari', 'Парфюмерные наборы', 'parfyum-toplamlari', 'gift', '11111111-1111-1111-1111-000000000009', 3, true);

-- 🧴 GIGIENA subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000047', 'Og''iz bo''shlig''i', 'Уход за полостью рта', 'ogiz-boshligi', 'brush_1', '11111111-1111-1111-1111-000000000010', 1, true),
('22222222-2222-2222-2222-000000000048', 'Tana parvarishi', 'Уход за телом', 'tana-parvarishi', 'drop', '11111111-1111-1111-1111-000000000010', 2, true),
('22222222-2222-2222-2222-000000000049', 'Soqol olish', 'Бритье', 'soqol-olish', 'brush_1', '11111111-1111-1111-1111-000000000010', 3, true),
('22222222-2222-2222-2222-000000000050', 'Ayollar gigiyanasi', 'Женская гигиена', 'ayollar-gigiyanasi', 'drop', '11111111-1111-1111-1111-000000000010', 4, true);

-- 💊 DORIXONA subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000051', 'Vitaminlar', 'Витамины', 'vitaminlar', 'health', '11111111-1111-1111-1111-000000000011', 1, true),
('22222222-2222-2222-2222-000000000052', 'Dori-darmonlar', 'Лекарства', 'dori-darmonlar', 'health', '11111111-1111-1111-1111-000000000011', 2, true),
('22222222-2222-2222-2222-000000000053', 'Tibbiy asboblar', 'Медицинские изделия', 'tibbiy-asboblar', 'health', '11111111-1111-1111-1111-000000000011', 3, true),
('22222222-2222-2222-2222-000000000054', 'Birinchi yordam', 'Первая помощь', 'birinchi-yordam', 'health', '11111111-1111-1111-1111-000000000011', 4, true);

-- 🏠 UY subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000055', 'Uy to''qimalari', 'Домашний текстиль', 'uy-toqimalari', 'home_2', '11111111-1111-1111-1111-000000000012', 1, true),
('22222222-2222-2222-2222-000000000056', 'Dekor', 'Декор', 'dekor', 'gift', '11111111-1111-1111-1111-000000000012', 2, true),
('22222222-2222-2222-2222-000000000057', 'Yoritish', 'Освещение', 'yoritish', 'lamp_charge', '11111111-1111-1111-1111-000000000012', 3, true),
('22222222-2222-2222-2222-000000000058', 'Saqlash tizimlari', 'Системы хранения', 'saqlash-tizimlari', 'home_2', '11111111-1111-1111-1111-000000000012', 4, true),
('22222222-2222-2222-2222-000000000059', 'Hammom uchun', 'Для ванной', 'hammom-uchun', 'drop', '11111111-1111-1111-1111-000000000012', 5, true);

-- 🪑 MEBEL subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000060', 'Yotoq xonasi', 'Спальня', 'yotoq-xonasi', 'lamp_charge', '11111111-1111-1111-1111-000000000013', 1, true),
('22222222-2222-2222-2222-000000000061', 'Yashash xonasi', 'Гостиная', 'yashash-xonasi', 'home_2', '11111111-1111-1111-1111-000000000013', 2, true),
('22222222-2222-2222-2222-000000000062', 'Oshxona mebeli', 'Кухонная мебель', 'oshxona-mebeli', 'coffee', '11111111-1111-1111-1111-000000000013', 3, true),
('22222222-2222-2222-2222-000000000063', 'Ofis mebeli', 'Офисная мебель', 'ofis-mebeli', 'book', '11111111-1111-1111-1111-000000000013', 4, true),
('22222222-2222-2222-2222-000000000064', 'Bolalar mebeli', 'Детская мебель', 'bolalar-mebeli', 'happyemoji', '11111111-1111-1111-1111-000000000013', 5, true);

-- 🔧 QURILISH subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000065', 'Asboblar', 'Инструменты', 'asboblar', 'ruler', '11111111-1111-1111-1111-000000000014', 1, true),
('22222222-2222-2222-2222-000000000066', 'Santexnika', 'Сантехника', 'santexnika', 'drop', '11111111-1111-1111-1111-000000000014', 2, true),
('22222222-2222-2222-2222-000000000067', 'Elektrika', 'Электрика', 'elektrika', 'lamp_charge', '11111111-1111-1111-1111-000000000014', 3, true),
('22222222-2222-2222-2222-000000000068', 'Bo''yoqlar', 'Краски', 'boyoqlar', 'brush_1', '11111111-1111-1111-1111-000000000014', 4, true),
('22222222-2222-2222-2222-000000000069', 'Qurilish materiallari', 'Стройматериалы', 'qurilish-materiallari', 'ruler', '11111111-1111-1111-1111-000000000014', 5, true);

-- 🧴 UY KIMYOVIY subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000070', 'Kir yuvish', 'Стирка', 'kir-yuvish', 'drop', '11111111-1111-1111-1111-000000000015', 1, true),
('22222222-2222-2222-2222-000000000071', 'Tozalash', 'Уборка', 'tozalash', 'blend_2', '11111111-1111-1111-1111-000000000015', 2, true),
('22222222-2222-2222-2222-000000000072', 'Idish yuvish', 'Мытье посуды', 'idish-yuvish', 'coffee', '11111111-1111-1111-1111-000000000015', 3, true),
('22222222-2222-2222-2222-000000000073', 'Xushbo''ylagichlar', 'Ароматизаторы', 'xushboylagichlar', 'lovely', '11111111-1111-1111-1111-000000000015', 4, true);

-- 👶 BOLALAR subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000074', 'Chaqaloq kiyimi', 'Одежда для малышей', 'chaqaloq-kiyimi', 'happyemoji', '11111111-1111-1111-1111-000000000016', 1, true),
('22222222-2222-2222-2222-000000000075', 'Chaqaloq parvarishi', 'Уход за малышом', 'chaqaloq-parvarishi', 'drop', '11111111-1111-1111-1111-000000000016', 2, true),
('22222222-2222-2222-2222-000000000076', 'Ovqatlantirish', 'Кормление', 'ovqatlantirish', 'milk', '11111111-1111-1111-1111-000000000016', 3, true),
('22222222-2222-2222-2222-000000000077', 'Kolyaskalar', 'Коляски', 'kolyaskalar', 'car', '11111111-1111-1111-1111-000000000016', 4, true),
('22222222-2222-2222-2222-000000000078', 'Avtokreslo', 'Автокресла', 'avtokreslo', 'car', '11111111-1111-1111-1111-000000000016', 5, true);

-- 🧸 O'YINCHOQLAR subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000079', 'Konstruktorlar', 'Конструкторы', 'konstruktorlar', 'game', '11111111-1111-1111-1111-000000000017', 1, true),
('22222222-2222-2222-2222-000000000080', 'Qo''g''irchoqlar', 'Куклы', 'qogirchoqlar', 'happyemoji', '11111111-1111-1111-1111-000000000017', 2, true),
('22222222-2222-2222-2222-000000000081', 'Mashinkalar', 'Машинки', 'mashinkalar', 'car', '11111111-1111-1111-1111-000000000017', 3, true),
('22222222-2222-2222-2222-000000000082', 'Stol o''yinlari', 'Настольные игры', 'stol-oyinlari', 'game', '11111111-1111-1111-1111-000000000017', 4, true),
('22222222-2222-2222-2222-000000000083', 'Yumshoq o''yinchoqlar', 'Мягкие игрушки', 'yumshoq-oyinchoqlar', 'lovely', '11111111-1111-1111-1111-000000000017', 5, true);

-- 📚 MAKTAB VA OFIS subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000084', 'Daftarlar', 'Тетради', 'daftarlar', 'book', '11111111-1111-1111-1111-000000000018', 1, true),
('22222222-2222-2222-2222-000000000085', 'Ruchkalar', 'Ручки', 'ruchkalar', 'brush_1', '11111111-1111-1111-1111-000000000018', 2, true),
('22222222-2222-2222-2222-000000000086', 'Maktab sumkalari', 'Школьные рюкзаки', 'maktab-sumkalari', 'bag_2', '11111111-1111-1111-1111-000000000018', 3, true),
('22222222-2222-2222-2222-000000000087', 'Ofis jihozlari', 'Офисные принадлежности', 'ofis-jihozlari', 'book', '11111111-1111-1111-1111-000000000018', 4, true);

-- 🍎 OZIQ-OVQAT subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000088', 'Sut mahsulotlari', 'Молочные продукты', 'sut-mahsulotlari', 'milk', '11111111-1111-1111-1111-000000000019', 1, true),
('22222222-2222-2222-2222-000000000089', 'Go''sht mahsulotlari', 'Мясные продукты', 'gosht-mahsulotlari', 'cake', '11111111-1111-1111-1111-000000000019', 2, true),
('22222222-2222-2222-2222-000000000090', 'Baqqollik', 'Бакалея', 'baqqollik', 'milk', '11111111-1111-1111-1111-000000000019', 3, true),
('22222222-2222-2222-2222-000000000091', 'Muzlatilgan', 'Замороженные продукты', 'muzlatilgan', 'milk', '11111111-1111-1111-1111-000000000019', 4, true),
('22222222-2222-2222-2222-000000000092', 'Sabzavotlar', 'Овощи и фрукты', 'sabzavotlar', 'milk', '11111111-1111-1111-1111-000000000019', 5, true);

-- 🍬 SHIRINLIKLAR subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000093', 'Shokoladlar', 'Шоколад', 'shokoladlar', 'cake', '11111111-1111-1111-1111-000000000020', 1, true),
('22222222-2222-2222-2222-000000000094', 'Pechene', 'Печенье', 'pechene', 'cake', '11111111-1111-1111-1111-000000000020', 2, true),
('22222222-2222-2222-2222-000000000095', 'Chipslar', 'Чипсы', 'chipslar', 'cake', '11111111-1111-1111-1111-000000000020', 3, true),
('22222222-2222-2222-2222-000000000096', 'Yong''oqlar', 'Орехи', 'yongoqlar', 'cake', '11111111-1111-1111-1111-000000000020', 4, true);

-- ☕ ICHIMLIKLAR subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000097', 'Choy', 'Чай', 'choy', 'cup', '11111111-1111-1111-1111-000000000021', 1, true),
('22222222-2222-2222-2222-000000000098', 'Qahva', 'Кофе', 'qahva', 'coffee', '11111111-1111-1111-1111-000000000021', 2, true),
('22222222-2222-2222-2222-000000000099', 'Sharbatlar', 'Соки', 'sharbatlar', 'cup', '11111111-1111-1111-1111-000000000021', 3, true),
('22222222-2222-2222-2222-000000000100', 'Suv', 'Вода', 'suv', 'cup', '11111111-1111-1111-1111-000000000021', 4, true);

-- 🚗 AVTOMOBIL subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000101', 'Ehtiyot qismlar', 'Запчасти', 'ehtiyot-qismlar', 'car', '11111111-1111-1111-1111-000000000022', 1, true),
('22222222-2222-2222-2222-000000000102', 'Aksessuarlar', 'Аксессуары', 'avto-aksessuarlar', 'car', '11111111-1111-1111-1111-000000000022', 2, true),
('22222222-2222-2222-2222-000000000103', 'Moylar', 'Масла', 'moylar', 'drop', '11111111-1111-1111-1111-000000000022', 3, true),
('22222222-2222-2222-2222-000000000104', 'Shinalar', 'Шины', 'shinalar', 'car', '11111111-1111-1111-1111-000000000022', 4, true);

-- 🏃 SPORT subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000105', 'Fitnes', 'Фитнес', 'fitnes', 'weight_1', '11111111-1111-1111-1111-000000000023', 1, true),
('22222222-2222-2222-2222-000000000106', 'Velosiped', 'Велоспорт', 'velosiped', 'car', '11111111-1111-1111-1111-000000000023', 2, true),
('22222222-2222-2222-2222-000000000107', 'Turizm', 'Туризм', 'turizm', 'car', '11111111-1111-1111-1111-000000000023', 3, true),
('22222222-2222-2222-2222-000000000108', 'Sport kiyimi', 'Спортивная одежда', 'sport-kiyimi', 'tag', '11111111-1111-1111-1111-000000000023', 4, true);

-- 🎮 O'YIN VA KONSOL subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000109', 'O''yin konsollari', 'Игровые консоли', 'oyin-konsollari', 'game', '11111111-1111-1111-1111-000000000024', 1, true),
('22222222-2222-2222-2222-000000000110', 'Video o''yinlar', 'Видеоигры', 'video-oyinlar', 'game', '11111111-1111-1111-1111-000000000024', 2, true),
('22222222-2222-2222-2222-000000000111', 'O''yin aksessuarlari', 'Игровые аксессуары', 'oyin-aksessuarlari', 'headphone', '11111111-1111-1111-1111-000000000024', 3, true),
('22222222-2222-2222-2222-000000000112', 'O''yin kompyuterlari', 'Игровые ПК', 'oyin-kompyuterlari', 'monitor', '11111111-1111-1111-1111-000000000024', 4, true);

-- 📚 KITOBLAR subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000113', 'Badiiy adabiyot', 'Художественная литература', 'badiiy-adabiyot', 'book', '11111111-1111-1111-1111-000000000025', 1, true),
('22222222-2222-2222-2222-000000000114', 'O''quv adabiyoti', 'Учебная литература', 'oquv-adabiyoti', 'book', '11111111-1111-1111-1111-000000000025', 2, true),
('22222222-2222-2222-2222-000000000115', 'Bolalar kitoblari', 'Детские книги', 'bolalar-kitoblari', 'happyemoji', '11111111-1111-1111-1111-000000000025', 3, true),
('22222222-2222-2222-2222-000000000116', 'Biznes kitoblar', 'Бизнес литература', 'biznes-kitoblar', 'book', '11111111-1111-1111-1111-000000000025', 4, true);

-- 🎨 XOBBI subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000117', 'Tikish', 'Шитье', 'tikish', 'brush_1', '11111111-1111-1111-1111-000000000026', 1, true),
('22222222-2222-2222-2222-000000000118', 'Rasm chizish', 'Рисование', 'rasm-chizish', 'brush_1', '11111111-1111-1111-1111-000000000026', 2, true),
('22222222-2222-2222-2222-000000000119', 'Bog''dorchilik', 'Садоводство', 'bogdorchilik', 'lovely', '11111111-1111-1111-1111-000000000026', 3, true),
('22222222-2222-2222-2222-000000000120', 'Kollektsiya', 'Коллекционирование', 'kollektsiya', 'gift', '11111111-1111-1111-1111-000000000026', 4, true);

-- 🐾 UY HAYVONLARI subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000121', 'Itlar uchun', 'Для собак', 'itlar-uchun', 'pet', '11111111-1111-1111-1111-000000000027', 1, true),
('22222222-2222-2222-2222-000000000122', 'Mushuklar uchun', 'Для кошек', 'mushuklar-uchun', 'pet', '11111111-1111-1111-1111-000000000027', 2, true),
('22222222-2222-2222-2222-000000000123', 'Baliqlar uchun', 'Для рыб', 'baliqlar-uchun', 'pet', '11111111-1111-1111-1111-000000000027', 3, true),
('22222222-2222-2222-2222-000000000124', 'Qushlar uchun', 'Для птиц', 'qushlar-uchun', 'pet', '11111111-1111-1111-1111-000000000027', 4, true);

-- 🌸 GULLAR subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000125', 'Guldastalar', 'Букеты', 'guldastalar', 'lovely', '11111111-1111-1111-1111-000000000028', 1, true),
('22222222-2222-2222-2222-000000000126', 'Uy o''simliklari', 'Комнатные растения', 'uy-osimliklari', 'lovely', '11111111-1111-1111-1111-000000000028', 2, true),
('22222222-2222-2222-2222-000000000127', 'Guldonlar', 'Горшки', 'guldonlar', 'home_2', '11111111-1111-1111-1111-000000000028', 3, true);

-- 🎁 SOVG'ALAR subkategoriyalari
INSERT INTO categories (id, name_uz, name_ru, slug, icon, parent_id, sort_order, is_active) VALUES
('22222222-2222-2222-2222-000000000128', 'Sovg''a to''plamlari', 'Подарочные наборы', 'sovga-toplamlari', 'gift', '11111111-1111-1111-1111-000000000029', 1, true),
('22222222-2222-2222-2222-000000000129', 'Sertifikatlar', 'Сертификаты', 'sertifikatlar', 'gift', '11111111-1111-1111-1111-000000000029', 2, true),
('22222222-2222-2222-2222-000000000130', 'Esdaliklar', 'Сувениры', 'esdaliklar', 'gift', '11111111-1111-1111-1111-000000000029', 3, true);
