-- ===========================================
-- TOPLA.APP - Professional Filter System
-- Uzum-style filtering architecture
-- ===========================================

-- 1. BRANDS TABLE
-- Brendlar jadvali (Samsung, Apple, Xiaomi, va h.k.)
-- ===========================================
CREATE TABLE IF NOT EXISTS brands (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_uz VARCHAR(100) NOT NULL,
    name_ru VARCHAR(100),
    slug VARCHAR(100) UNIQUE NOT NULL,
    logo_url TEXT,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. COLOR OPTIONS TABLE
-- Ranglar jadvali (vizual ko'rsatish uchun hex kodlari bilan)
-- ===========================================
CREATE TABLE IF NOT EXISTS color_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_uz VARCHAR(50) NOT NULL,
    name_ru VARCHAR(50),
    hex_code VARCHAR(7) NOT NULL, -- #FFFFFF format
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. CATEGORY FILTER ATTRIBUTES TABLE
-- Har bir kategoriya uchun qanday filtrlar mavjudligini belgilaydi
-- ===========================================
CREATE TABLE IF NOT EXISTS category_filter_attributes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    attribute_key VARCHAR(50) NOT NULL,  -- 'ram', 'screen_size', 'battery', 'storage'
    attribute_name_uz VARCHAR(100) NOT NULL,
    attribute_name_ru VARCHAR(100),
    filter_type VARCHAR(20) NOT NULL CHECK (filter_type IN ('range', 'chips', 'toggle', 'color', 'radio')),
    options JSONB DEFAULT '[]',          -- Chips uchun: ["4GB", "8GB", "12GB"]
    unit VARCHAR(20),                     -- 'GB', 'dyuym', 'mAh', 'Vt'
    min_value NUMERIC,                    -- Range uchun minimal qiymat
    max_value NUMERIC,                    -- Range uchun maksimal qiymat
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. PRODUCTS TABLE UPDATES
-- Mavjud products jadvaliga yangi ustunlar qo'shish
-- ===========================================
ALTER TABLE products ADD COLUMN IF NOT EXISTS brand_id UUID REFERENCES brands(id);
ALTER TABLE products ADD COLUMN IF NOT EXISTS attributes JSONB DEFAULT '{}';
ALTER TABLE products ADD COLUMN IF NOT EXISTS colors JSONB DEFAULT '[]';
ALTER TABLE products ADD COLUMN IF NOT EXISTS is_original BOOLEAN DEFAULT false;
ALTER TABLE products ADD COLUMN IF NOT EXISTS is_click_delivery BOOLEAN DEFAULT false;
ALTER TABLE products ADD COLUMN IF NOT EXISTS delivery_hours INTEGER DEFAULT 72;
ALTER TABLE products ADD COLUMN IF NOT EXISTS product_line VARCHAR(100);

-- 5. INDEXES FOR PERFORMANCE
-- Tezkor qidiruv uchun indekslar
-- ===========================================
CREATE INDEX IF NOT EXISTS idx_products_brand ON products(brand_id);
CREATE INDEX IF NOT EXISTS idx_products_attributes ON products USING GIN(attributes);
CREATE INDEX IF NOT EXISTS idx_products_colors ON products USING GIN(colors);
CREATE INDEX IF NOT EXISTS idx_products_delivery ON products(is_click_delivery, delivery_hours);
CREATE INDEX IF NOT EXISTS idx_category_filter_attrs ON category_filter_attributes(category_id, is_active);

-- ===========================================
-- SAMPLE DATA - BRANDS
-- ===========================================
INSERT INTO brands (id, name_uz, name_ru, slug, sort_order) VALUES
-- Elektronika brendlari
('b0000001-0001-0001-0001-000000000001', 'Samsung', 'Samsung', 'samsung', 1),
('b0000001-0001-0001-0001-000000000002', 'Apple', 'Apple', 'apple', 2),
('b0000001-0001-0001-0001-000000000003', 'Xiaomi', 'Xiaomi', 'xiaomi', 3),
('b0000001-0001-0001-0001-000000000004', 'Huawei', 'Huawei', 'huawei', 4),
('b0000001-0001-0001-0001-000000000005', 'Realme', 'Realme', 'realme', 5),
('b0000001-0001-0001-0001-000000000006', 'OPPO', 'OPPO', 'oppo', 6),
('b0000001-0001-0001-0001-000000000007', 'Vivo', 'Vivo', 'vivo', 7),
('b0000001-0001-0001-0001-000000000008', 'OnePlus', 'OnePlus', 'oneplus', 8),
('b0000001-0001-0001-0001-000000000009', 'Honor', 'Honor', 'honor', 9),
('b0000001-0001-0001-0001-000000000010', 'Nokia', 'Nokia', 'nokia', 10),
-- Maishiy texnika brendlari
('b0000001-0001-0001-0001-000000000011', 'LG', 'LG', 'lg', 11),
('b0000001-0001-0001-0001-000000000012', 'Bosch', 'Bosch', 'bosch', 12),
('b0000001-0001-0001-0001-000000000013', 'Philips', 'Philips', 'philips', 13),
('b0000001-0001-0001-0001-000000000014', 'Artel', 'Artel', 'artel', 14),
('b0000001-0001-0001-0001-000000000015', 'Haier', 'Haier', 'haier', 15),
-- Kiyim brendlari
('b0000001-0001-0001-0001-000000000016', 'Zara', 'Zara', 'zara', 16),
('b0000001-0001-0001-0001-000000000017', 'H&M', 'H&M', 'hm', 17),
('b0000001-0001-0001-0001-000000000018', 'Nike', 'Nike', 'nike', 18),
('b0000001-0001-0001-0001-000000000019', 'Adidas', 'Adidas', 'adidas', 19),
('b0000001-0001-0001-0001-000000000020', 'Puma', 'Puma', 'puma', 20)
ON CONFLICT (id) DO NOTHING;

-- ===========================================
-- SAMPLE DATA - COLORS
-- ===========================================
INSERT INTO color_options (id, name_uz, name_ru, hex_code, sort_order) VALUES
('c0000001-0001-0001-0001-000000000001', 'Qora', 'Черный', '#000000', 1),
('c0000001-0001-0001-0001-000000000002', 'Oq', 'Белый', '#FFFFFF', 2),
('c0000001-0001-0001-0001-000000000003', 'Kulrang', 'Серый', '#808080', 3),
('c0000001-0001-0001-0001-000000000004', 'Kumush', 'Серебристый', '#C0C0C0', 4),
('c0000001-0001-0001-0001-000000000005', 'Ko''k', 'Синий', '#0000FF', 5),
('c0000001-0001-0001-0001-000000000006', 'Qizil', 'Красный', '#FF0000', 6),
('c0000001-0001-0001-0001-000000000007', 'Yashil', 'Зеленый', '#008000', 7),
('c0000001-0001-0001-0001-000000000008', 'Sariq', 'Желтый', '#FFFF00', 8),
('c0000001-0001-0001-0001-000000000009', 'Pushti', 'Розовый', '#FFC0CB', 9),
('c0000001-0001-0001-0001-000000000010', 'Binafsha', 'Фиолетовый', '#800080', 10),
('c0000001-0001-0001-0001-000000000011', 'Oltin', 'Золотой', '#FFD700', 11),
('c0000001-0001-0001-0001-000000000012', 'Bronza', 'Бронзовый', '#CD7F32', 12),
('c0000001-0001-0001-0001-000000000013', 'Jigarrang', 'Коричневый', '#8B4513', 13),
('c0000001-0001-0001-0001-000000000014', 'Moviy', 'Голубой', '#87CEEB', 14),
('c0000001-0001-0001-0001-000000000015', 'Tilla', 'Бежевый', '#F5F5DC', 15)
ON CONFLICT (id) DO NOTHING;

-- ===========================================
-- CATEGORY FILTER ATTRIBUTES - SMARTFONLAR
-- Elektronika -> Smartfonlar (parent: Elektronika)
-- ===========================================
INSERT INTO category_filter_attributes (category_id, attribute_key, attribute_name_uz, attribute_name_ru, filter_type, options, unit, sort_order) VALUES
-- Smartfonlar uchun (category_id ni o'zgartirish kerak)
('11111111-1111-1111-1111-000000000007', 'ram', 'Operativ xotira', 'Оперативная память', 'chips', '["3 GB", "4 GB", "6 GB", "8 GB", "12 GB", "16 GB"]', 'GB', 1),
('11111111-1111-1111-1111-000000000007', 'storage', 'Ichki xotira', 'Встроенная память', 'chips', '["32 GB", "64 GB", "128 GB", "256 GB", "512 GB", "1 TB"]', 'GB', 2),
('11111111-1111-1111-1111-000000000007', 'screen_size', 'Ekran diagonali', 'Диагональ экрана', 'range', null, 'dyuym', 3),
('11111111-1111-1111-1111-000000000007', 'battery', 'Batareya sig''imi', 'Емкость аккумулятора', 'chips', '["3000 mAh gacha", "3000-4000 mAh", "4000-5000 mAh", "5000 mAh dan yuqori"]', 'mAh', 4),
('11111111-1111-1111-1111-000000000007', 'screen_type', 'Ekran turi', 'Тип экрана', 'chips', '["AMOLED", "Super AMOLED", "OLED", "IPS", "TFT"]', null, 5),
('11111111-1111-1111-1111-000000000007', 'os', 'Operatsion tizim', 'Операционная система', 'chips', '["Android", "iOS", "HarmonyOS"]', null, 6),
('11111111-1111-1111-1111-000000000007', 'network', 'Aloqa standarti', 'Стандарт связи', 'chips', '["4G LTE", "5G"]', null, 7),
('11111111-1111-1111-1111-000000000007', 'nfc', 'NFC', 'NFC', 'toggle', null, null, 8),
('11111111-1111-1111-1111-000000000007', 'dual_sim', 'Ikki SIM', 'Две SIM', 'toggle', null, null, 9)
ON CONFLICT DO NOTHING;

-- ===========================================
-- CATEGORY FILTER ATTRIBUTES - NOUTBUKLAR
-- ===========================================
INSERT INTO category_filter_attributes (category_id, attribute_key, attribute_name_uz, attribute_name_ru, filter_type, options, unit, sort_order) VALUES
('11111111-1111-1111-1111-000000000008', 'ram', 'Operativ xotira', 'Оперативная память', 'chips', '["4 GB", "8 GB", "16 GB", "32 GB", "64 GB"]', 'GB', 1),
('11111111-1111-1111-1111-000000000008', 'storage', 'SSD hajmi', 'Объем SSD', 'chips', '["128 GB", "256 GB", "512 GB", "1 TB", "2 TB"]', 'GB', 2),
('11111111-1111-1111-1111-000000000008', 'screen_size', 'Ekran diagonali', 'Диагональ экрана', 'chips', '["13.3\"", "14\"", "15.6\"", "16\"", "17.3\""]', 'dyuym', 3),
('11111111-1111-1111-1111-000000000008', 'processor', 'Protsessor', 'Процессор', 'chips', '["Intel Core i3", "Intel Core i5", "Intel Core i7", "Intel Core i9", "AMD Ryzen 5", "AMD Ryzen 7", "Apple M1", "Apple M2", "Apple M3"]', null, 4),
('11111111-1111-1111-1111-000000000008', 'graphics', 'Videokarta', 'Видеокарта', 'chips', '["Integrirlangan", "NVIDIA GeForce", "AMD Radeon"]', null, 5),
('11111111-1111-1111-1111-000000000008', 'os', 'Operatsion tizim', 'Операционная система', 'chips', '["Windows 11", "macOS", "Linux", "DOS"]', null, 6)
ON CONFLICT DO NOTHING;

-- ===========================================
-- CATEGORY FILTER ATTRIBUTES - TELEVIZORLAR
-- ===========================================
INSERT INTO category_filter_attributes (category_id, attribute_key, attribute_name_uz, attribute_name_ru, filter_type, options, unit, sort_order) VALUES
('11111111-1111-1111-1111-000000000009', 'screen_size', 'Ekran diagonali', 'Диагональ экрана', 'chips', '["32\"", "40\"", "43\"", "50\"", "55\"", "65\"", "75\"", "85\""]', 'dyuym', 1),
('11111111-1111-1111-1111-000000000009', 'resolution', 'Razreshenie', 'Разрешение', 'chips', '["HD", "Full HD", "4K UHD", "8K"]', null, 2),
('11111111-1111-1111-1111-000000000009', 'smart_tv', 'Smart TV', 'Smart TV', 'toggle', null, null, 3),
('11111111-1111-1111-1111-000000000009', 'screen_type', 'Ekran turi', 'Тип экрана', 'chips', '["LED", "OLED", "QLED", "Neo QLED"]', null, 4),
('11111111-1111-1111-1111-000000000009', 'refresh_rate', 'Yangilanish tezligi', 'Частота обновления', 'chips', '["60 Hz", "120 Hz", "144 Hz"]', 'Hz', 5)
ON CONFLICT DO NOTHING;

-- ===========================================
-- CATEGORY FILTER ATTRIBUTES - KIYIM
-- ===========================================
INSERT INTO category_filter_attributes (category_id, attribute_key, attribute_name_uz, attribute_name_ru, filter_type, options, unit, sort_order) VALUES
('11111111-1111-1111-1111-000000000004', 'size', 'O''lcham', 'Размер', 'chips', '["XS", "S", "M", "L", "XL", "XXL", "XXXL"]', null, 1),
('11111111-1111-1111-1111-000000000004', 'gender', 'Jins', 'Пол', 'chips', '["Erkaklar uchun", "Ayollar uchun", "Bolalar uchun", "Unisex"]', null, 2),
('11111111-1111-1111-1111-000000000004', 'material', 'Material', 'Материал', 'chips', '["Paxta", "Sintetik", "Jun", "Teri", "Ipak", "Poliester"]', null, 3),
('11111111-1111-1111-1111-000000000004', 'season', 'Mavsum', 'Сезон', 'chips', '["Yoz", "Qish", "Kuz-Bahor", "Doimiy"]', null, 4)
ON CONFLICT DO NOTHING;

-- ===========================================
-- CATEGORY FILTER ATTRIBUTES - POYABZAL
-- ===========================================
INSERT INTO category_filter_attributes (category_id, attribute_key, attribute_name_uz, attribute_name_ru, filter_type, options, unit, sort_order) VALUES
('11111111-1111-1111-1111-000000000005', 'shoe_size', 'O''lcham', 'Размер', 'chips', '["35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46"]', null, 1),
('11111111-1111-1111-1111-000000000005', 'gender', 'Jins', 'Пол', 'chips', '["Erkaklar uchun", "Ayollar uchun", "Bolalar uchun"]', null, 2),
('11111111-1111-1111-1111-000000000005', 'material', 'Material', 'Материал', 'chips', '["Teri", "Eko-teri", "Tekstil", "Sintetik", "Rezina"]', null, 3),
('11111111-1111-1111-1111-000000000005', 'season', 'Mavsum', 'Сезон', 'chips', '["Yoz", "Qish", "Kuz-Bahor", "Doimiy"]', null, 4),
('11111111-1111-1111-1111-000000000005', 'type', 'Turi', 'Тип', 'chips', '["Krossovkalar", "Tuflya", "Botinka", "Sandallar", "Shippaklar"]', null, 5)
ON CONFLICT DO NOTHING;

-- ===========================================
-- CATEGORY FILTER ATTRIBUTES - MAISHIY TEXNIKA
-- ===========================================
INSERT INTO category_filter_attributes (category_id, attribute_key, attribute_name_uz, attribute_name_ru, filter_type, options, unit, sort_order) VALUES
-- Muzlatgichlar
('11111111-1111-1111-1111-000000000014', 'volume', 'Hajmi', 'Объем', 'chips', '["150 L gacha", "150-250 L", "250-350 L", "350 L dan yuqori"]', 'L', 1),
('11111111-1111-1111-1111-000000000014', 'energy_class', 'Energiya sinfi', 'Класс энергопотребления', 'chips', '["A+++", "A++", "A+", "A", "B"]', null, 2),
('11111111-1111-1111-1111-000000000014', 'type', 'Turi', 'Тип', 'chips', '["Bir eshikli", "Ikki eshikli", "Side-by-Side", "French Door"]', null, 3),
('11111111-1111-1111-1111-000000000014', 'no_frost', 'No Frost', 'No Frost', 'toggle', null, null, 4),
-- Kir yuvish mashinalari
('11111111-1111-1111-1111-000000000015', 'load', 'Sig''im', 'Загрузка', 'chips', '["5 kg gacha", "5-7 kg", "7-9 kg", "9 kg dan yuqori"]', 'kg', 1),
('11111111-1111-1111-1111-000000000015', 'type', 'Turi', 'Тип', 'chips', '["Avtomat", "Yarim avtomat", "Quritgichli"]', null, 2),
('11111111-1111-1111-1111-000000000015', 'spin_speed', 'Siqish tezligi', 'Скорость отжима', 'chips', '["800 rpm", "1000 rpm", "1200 rpm", "1400 rpm"]', 'rpm', 3)
ON CONFLICT DO NOTHING;

-- ===========================================
-- UNIVERSAL FILTERS (all categories)
-- Barcha kategoriyalar uchun umumiy filtrlar
-- ===========================================
-- Bu filtrlar UI da hardcode qilinadi:
-- 1. Narx (dan/gacha) - Range
-- 2. Brend - Chips (brands jadvalidan)
-- 3. Rang - Color picker (color_options jadvalidan)
-- 4. Yetkazish muddati - Radio (Bugun, Ertaga, 7 kungacha, Muhim emas)
-- 5. Klik bilan yetkazish - Toggle
-- 6. Original - Toggle
-- 7. Reyting - Chips (4+, 4.5+)

-- ===========================================
-- RLS POLICIES
-- ===========================================
ALTER TABLE brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE color_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE category_filter_attributes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Brands are viewable by everyone" ON brands FOR SELECT USING (true);
CREATE POLICY "Colors are viewable by everyone" ON color_options FOR SELECT USING (true);
CREATE POLICY "Filter attributes are viewable by everyone" ON category_filter_attributes FOR SELECT USING (true);

-- ===========================================
-- HELPER FUNCTION: Get filtered products count
-- ===========================================
CREATE OR REPLACE FUNCTION get_filtered_products_count(
    p_category_id UUID,
    p_min_price NUMERIC DEFAULT NULL,
    p_max_price NUMERIC DEFAULT NULL,
    p_brand_ids UUID[] DEFAULT NULL,
    p_min_rating NUMERIC DEFAULT NULL,
    p_in_stock BOOLEAN DEFAULT NULL,
    p_original BOOLEAN DEFAULT NULL,
    p_click_delivery BOOLEAN DEFAULT NULL
)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)::INTEGER
        FROM products p
        WHERE p.category_id = p_category_id
          AND p.is_active = true
          AND (p_min_price IS NULL OR p.price >= p_min_price)
          AND (p_max_price IS NULL OR p.price <= p_max_price)
          AND (p_brand_ids IS NULL OR p.brand_id = ANY(p_brand_ids))
          AND (p_min_rating IS NULL OR p.rating >= p_min_rating)
          AND (p_in_stock IS NULL OR (p_in_stock = true AND p.stock > 0))
          AND (p_original IS NULL OR p.is_original = p_original)
          AND (p_click_delivery IS NULL OR p.is_click_delivery = p_click_delivery)
    );
END;
$$ LANGUAGE plpgsql;
