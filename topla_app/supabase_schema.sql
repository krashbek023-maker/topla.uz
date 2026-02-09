-- =====================================================
-- TOPLA APP - Supabase Database Schema
-- Bu SQL ni Supabase SQL Editor'da ishga tushiring
-- =====================================================

-- 1. CATEGORIES - Kategoriyalar jadvali
CREATE TABLE categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name_uz VARCHAR(100) NOT NULL,
    name_ru VARCHAR(100) NOT NULL,
    icon VARCHAR(50),
    image_url TEXT,
    parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. PRODUCTS - Mahsulotlar jadvali
CREATE TABLE products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name_uz VARCHAR(255) NOT NULL,
    name_ru VARCHAR(255) NOT NULL,
    description_uz TEXT,
    description_ru TEXT,
    price DECIMAL(12, 2) NOT NULL,
    old_price DECIMAL(12, 2),
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    images TEXT[] DEFAULT '{}',
    stock INT DEFAULT 0,
    sold_count INT DEFAULT 0,
    rating DECIMAL(2, 1) DEFAULT 0,
    review_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    is_flash_sale BOOLEAN DEFAULT false,
    flash_sale_end TIMESTAMP WITH TIME ZONE,
    cashback_percent INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. BANNERS - Banner reklama jadvali
CREATE TABLE banners (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title_uz VARCHAR(255),
    title_ru VARCHAR(255),
    subtitle_uz VARCHAR(255),
    subtitle_ru VARCHAR(255),
    image_url TEXT NOT NULL,
    action_type VARCHAR(50) DEFAULT 'none', -- none, product, category, url
    action_value TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    start_date TIMESTAMP WITH TIME ZONE,
    end_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. PROFILES - Foydalanuvchi profillari (Supabase Auth bilan bog'liq)
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name VARCHAR(100),
    phone VARCHAR(20),
    avatar_url TEXT,
    birth_date DATE,
    gender VARCHAR(10),
    referral_code VARCHAR(20) UNIQUE,
    referred_by UUID REFERENCES profiles(id),
    cashback_balance DECIMAL(12, 2) DEFAULT 0,
    total_orders INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. ADDRESSES - Manzillar jadvali
CREATE TABLE addresses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title VARCHAR(50) NOT NULL, -- Uy, Ish, etc.
    full_address TEXT NOT NULL,
    city VARCHAR(100),
    district VARCHAR(100),
    street VARCHAR(255),
    house VARCHAR(50),
    apartment VARCHAR(50),
    entrance VARCHAR(20),
    floor VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. ORDERS - Buyurtmalar jadvali
CREATE TABLE orders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    address_id UUID REFERENCES addresses(id) ON DELETE SET NULL,
    status VARCHAR(30) DEFAULT 'pending', -- pending, confirmed, processing, shipping, delivered, cancelled
    subtotal DECIMAL(12, 2) NOT NULL,
    delivery_fee DECIMAL(12, 2) DEFAULT 0,
    discount DECIMAL(12, 2) DEFAULT 0,
    cashback_used DECIMAL(12, 2) DEFAULT 0,
    total DECIMAL(12, 2) NOT NULL,
    payment_method VARCHAR(30), -- cash, payme, click, uzum
    payment_status VARCHAR(20) DEFAULT 'pending', -- pending, paid, failed
    delivery_date DATE,
    delivery_time_slot VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. ORDER_ITEMS - Buyurtma tarkibi
CREATE TABLE order_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    product_name VARCHAR(255) NOT NULL,
    product_image TEXT,
    price DECIMAL(12, 2) NOT NULL,
    quantity INT NOT NULL,
    total DECIMAL(12, 2) NOT NULL
);

-- 8. CART_ITEMS - Savat
CREATE TABLE cart_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
    quantity INT DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

-- 9. FAVORITES - Sevimlilar
CREATE TABLE favorites (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

-- 10. REVIEWS - Sharhlar
CREATE TABLE reviews (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    images TEXT[] DEFAULT '{}',
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- INDEXES - Tezlik uchun indekslar
-- =====================================================

CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_active ON products(is_active);
CREATE INDEX idx_products_featured ON products(is_featured);
CREATE INDEX idx_products_flash_sale ON products(is_flash_sale);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_cart_user ON cart_items(user_id);
CREATE INDEX idx_favorites_user ON favorites(user_id);
CREATE INDEX idx_reviews_product ON reviews(product_id);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) - Xavfsizlik
-- =====================================================

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Addresses policies
CREATE POLICY "Users can view own addresses" ON addresses FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own addresses" ON addresses FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own addresses" ON addresses FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own addresses" ON addresses FOR DELETE USING (auth.uid() = user_id);

-- Orders policies
CREATE POLICY "Users can view own orders" ON orders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own orders" ON orders FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Order items policies
CREATE POLICY "Users can view own order items" ON order_items FOR SELECT 
    USING (EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()));

-- Cart policies
CREATE POLICY "Users can manage own cart" ON cart_items FOR ALL USING (auth.uid() = user_id);

-- Favorites policies
CREATE POLICY "Users can manage own favorites" ON favorites FOR ALL USING (auth.uid() = user_id);

-- Reviews policies
CREATE POLICY "Anyone can view reviews" ON reviews FOR SELECT USING (true);
CREATE POLICY "Users can insert own reviews" ON reviews FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own reviews" ON reviews FOR UPDATE USING (auth.uid() = user_id);

-- Public read access for products, categories, banners
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE banners ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view categories" ON categories FOR SELECT USING (is_active = true);
CREATE POLICY "Anyone can view products" ON products FOR SELECT USING (is_active = true);
CREATE POLICY "Anyone can view banners" ON banners FOR SELECT USING (is_active = true);

-- =====================================================
-- FUNCTIONS - Yordamchi funksiyalar
-- =====================================================

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Generate order number
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.order_number = 'TOP' || TO_CHAR(NOW(), 'YYMMDD') || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_order_number BEFORE INSERT ON orders FOR EACH ROW EXECUTE FUNCTION generate_order_number();

-- Generate referral code for new users
CREATE OR REPLACE FUNCTION generate_referral_code()
RETURNS TRIGGER AS $$
BEGIN
    NEW.referral_code = 'TOP' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 6));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_referral_code BEFORE INSERT ON profiles FOR EACH ROW EXECUTE FUNCTION generate_referral_code();

-- Update product rating after review
CREATE OR REPLACE FUNCTION update_product_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE products SET 
        rating = (SELECT AVG(rating) FROM reviews WHERE product_id = NEW.product_id),
        review_count = (SELECT COUNT(*) FROM reviews WHERE product_id = NEW.product_id)
    WHERE id = NEW.product_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_rating_on_review AFTER INSERT OR UPDATE ON reviews FOR EACH ROW EXECUTE FUNCTION update_product_rating();

-- =====================================================
-- SAMPLE DATA - Test ma'lumotlari
-- =====================================================

-- Kategoriyalar
INSERT INTO categories (name_uz, name_ru, icon, sort_order) VALUES
('Elektronika', 'Электроника', 'devices', 1),
('Kiyim', 'Одежда', 'checkroom', 2),
('Uy-ro''zg''or', 'Дом и быт', 'home', 3),
('Go''zallik', 'Красота', 'spa', 4),
('Bolalar', 'Детские', 'child_care', 5),
('Sport', 'Спорт', 'fitness_center', 6),
('Oziq-ovqat', 'Продукты', 'restaurant', 7),
('Avto', 'Авто', 'directions_car', 8);

-- Mahsulotlar (namuna)
INSERT INTO products (name_uz, name_ru, description_uz, description_ru, price, old_price, category_id, images, stock, rating, review_count, is_featured, cashback_percent) VALUES
('iPhone 15 Pro Max', 'iPhone 15 Pro Max', 'Apple iPhone 15 Pro Max 256GB', 'Apple iPhone 15 Pro Max 256GB', 15999000, 17500000, (SELECT id FROM categories WHERE name_uz = 'Elektronika'), ARRAY['https://picsum.photos/400/400?random=1'], 50, 4.8, 124, true, 3),
('Samsung Galaxy S24', 'Samsung Galaxy S24', 'Samsung Galaxy S24 Ultra 512GB', 'Samsung Galaxy S24 Ultra 512GB', 14500000, 15999000, (SELECT id FROM categories WHERE name_uz = 'Elektronika'), ARRAY['https://picsum.photos/400/400?random=2'], 35, 4.7, 89, true, 5),
('AirPods Pro 2', 'AirPods Pro 2', 'Apple AirPods Pro 2-avlod', 'Apple AirPods Pro 2-поколение', 2850000, 3200000, (SELECT id FROM categories WHERE name_uz = 'Elektronika'), ARRAY['https://picsum.photos/400/400?random=3'], 100, 4.9, 256, true, 2),
('Nike Air Max', 'Nike Air Max', 'Nike Air Max 270 erkaklar krossovkasi', 'Nike Air Max 270 мужские кроссовки', 890000, 1200000, (SELECT id FROM categories WHERE name_uz = 'Sport'), ARRAY['https://picsum.photos/400/400?random=4'], 80, 4.6, 78, false, 4),
('Ayollar ko''ylagi', 'Женское платье', 'Zamonaviy yozgi ko''ylak', 'Современное летнее платье', 299000, 450000, (SELECT id FROM categories WHERE name_uz = 'Kiyim'), ARRAY['https://picsum.photos/400/400?random=5'], 150, 4.5, 45, true, 3),
('Xiaomi Robot Vacuum', 'Xiaomi Robot Vacuum', 'Xiaomi Mi Robot Vacuum changyutgich', 'Xiaomi Mi Robot Vacuum пылесос', 3200000, 4500000, (SELECT id FROM categories WHERE name_uz = 'Uy-ro''zg''or'), ARRAY['https://picsum.photos/400/400?random=6'], 25, 4.7, 167, true, 5),
('Bolalar o''yinchoq', 'Детская игрушка', 'LEGO Constructor bolalar uchun', 'LEGO Constructor для детей', 450000, 550000, (SELECT id FROM categories WHERE name_uz = 'Bolalar'), ARRAY['https://picsum.photos/400/400?random=7'], 200, 4.8, 92, false, 2),
('Parfum', 'Парфюм', 'Versace Eros erkaklar parfumi', 'Versace Eros мужской парфюм', 680000, 850000, (SELECT id FROM categories WHERE name_uz = 'Go''zallik'), ARRAY['https://picsum.photos/400/400?random=8'], 60, 4.6, 134, true, 3);

-- Bannerlar
INSERT INTO banners (title_uz, title_ru, subtitle_uz, subtitle_ru, image_url, action_type, sort_order) VALUES
('Katta chegirmalar!', 'Большие скидки!', '50% gacha chegirma', 'Скидки до 50%', 'https://picsum.photos/800/400?random=10', 'category', 1),
('Yangi kolleksiya', 'Новая коллекция', 'Bahorgi kiyimlar', 'Весенняя одежда', 'https://picsum.photos/800/400?random=11', 'category', 2),
('Flash Sale', 'Flash Sale', 'Faqat bugun!', 'Только сегодня!', 'https://picsum.photos/800/400?random=12', 'none', 3);

-- =====================================================
-- STORAGE BUCKETS - Rasm saqlash
-- =====================================================
-- Supabase Dashboard > Storage > Create bucket:
-- 1. "products" - public
-- 2. "banners" - public  
-- 3. "avatars" - public

SELECT 'Database setup completed successfully! ✅' as status;
