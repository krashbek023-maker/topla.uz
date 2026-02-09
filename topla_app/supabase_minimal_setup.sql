-- ============================================
-- TOPLA.APP Minimal Database Setup
-- Faqat asosiy jadvallar - tez ishga tushirish uchun
-- ============================================

-- 1. Profiles jadvali
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    phone VARCHAR(20),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    full_name VARCHAR(100),
    email VARCHAR(255),
    avatar_url TEXT,
    role VARCHAR(20) DEFAULT 'customer' CHECK (role IN ('customer', 'vendor', 'admin', 'superadmin')),
    is_verified BOOLEAN DEFAULT FALSE,
    fcm_token TEXT,
    language VARCHAR(5) DEFAULT 'uz',
    cashback_balance DECIMAL(15,2) DEFAULT 0,
    coupons_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Kategoriyalar jadvali
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    name_uz VARCHAR(100),
    name_ru VARCHAR(100),
    icon VARCHAR(50),
    image_url TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Do'konlar jadvali
CREATE TABLE IF NOT EXISTS shops (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    logo_url TEXT,
    cover_url TEXT,
    phone VARCHAR(20),
    address TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    rating DECIMAL(3,2) DEFAULT 0,
    review_count INT DEFAULT 0,
    total_sales INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'approved',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Mahsulotlar jadvali
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id),
    subcategory_id UUID REFERENCES categories(id),
    name VARCHAR(255) NOT NULL,
    name_uz VARCHAR(255),
    name_ru VARCHAR(255),
    description TEXT,
    description_uz TEXT,
    description_ru TEXT,
    price DECIMAL(15,2) NOT NULL,
    old_price DECIMAL(15,2),
    images TEXT[] DEFAULT '{}',
    stock INT DEFAULT 0,
    sold_count INT DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0,
    review_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    is_flash_sale BOOLEAN DEFAULT FALSE,
    flash_sale_end TIMESTAMPTZ,
    cashback_percent INT DEFAULT 0,
    moderation_status VARCHAR(20) DEFAULT 'approved',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Cart items jadvali
CREATE TABLE IF NOT EXISTS cart_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    quantity INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

-- 6. Favorites jadvali
CREATE TABLE IF NOT EXISTS favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

-- 7. Manzillar jadvali
CREATE TABLE IF NOT EXISTS addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    full_address TEXT NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    apartment VARCHAR(50),
    entrance VARCHAR(50),
    floor VARCHAR(50),
    comment TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Orders jadvali
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id),
    address_id UUID REFERENCES addresses(id),
    status VARCHAR(30) DEFAULT 'pending',
    payment_method VARCHAR(20) DEFAULT 'cash',
    payment_status VARCHAR(20) DEFAULT 'pending',
    subtotal DECIMAL(15,2) NOT NULL,
    delivery_fee DECIMAL(15,2) DEFAULT 0,
    discount DECIMAL(15,2) DEFAULT 0,
    total DECIMAL(15,2) NOT NULL,
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. Order items jadvali
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    shop_id UUID REFERENCES shops(id),
    name VARCHAR(255) NOT NULL,
    image TEXT,
    price DECIMAL(15,2) NOT NULL,
    quantity INT NOT NULL,
    total DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. Banners jadvali
CREATE TABLE IF NOT EXISTS banners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255),
    image_url TEXT NOT NULL,
    link TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE banners ENABLE ROW LEVEL SECURITY;

-- Drop existing policies first
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
DROP POLICY IF EXISTS "Anyone can view categories" ON categories;
DROP POLICY IF EXISTS "Anyone can view shops" ON shops;
DROP POLICY IF EXISTS "Anyone can view products" ON products;
DROP POLICY IF EXISTS "Users can manage own cart" ON cart_items;
DROP POLICY IF EXISTS "Users can manage own favorites" ON favorites;
DROP POLICY IF EXISTS "Users can manage own addresses" ON addresses;
DROP POLICY IF EXISTS "Users can view own orders" ON orders;
DROP POLICY IF EXISTS "Users can insert own orders" ON orders;
DROP POLICY IF EXISTS "Users can view own order items" ON order_items;
DROP POLICY IF EXISTS "Anyone can view banners" ON banners;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Categories - hamma ko'ra oladi
CREATE POLICY "Anyone can view categories" ON categories FOR SELECT USING (true);

-- Shops - hamma ko'ra oladi
CREATE POLICY "Anyone can view shops" ON shops FOR SELECT USING (true);

-- Products - hamma ko'ra oladi
CREATE POLICY "Anyone can view products" ON products FOR SELECT USING (true);

-- Cart items - faqat o'z savatini
CREATE POLICY "Users can manage own cart" ON cart_items FOR ALL USING (auth.uid() = user_id);

-- Favorites - faqat o'z sevimlilarini
CREATE POLICY "Users can manage own favorites" ON favorites FOR ALL USING (auth.uid() = user_id);

-- Addresses - faqat o'z manzillarini
CREATE POLICY "Users can manage own addresses" ON addresses FOR ALL USING (auth.uid() = user_id);

-- Orders - faqat o'z buyurtmalarini
CREATE POLICY "Users can view own orders" ON orders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own orders" ON orders FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Order items - faqat o'z buyurtmalarini
CREATE POLICY "Users can view own order items" ON order_items FOR SELECT 
    USING (EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()));

-- Banners - hamma ko'ra oladi
CREATE POLICY "Anyone can view banners" ON banners FOR SELECT USING (true);

-- ============================================
-- TRIGGER: Auto profile on signup
-- ============================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, avatar_url)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name'),
        COALESCE(NEW.raw_user_meta_data->>'avatar_url', NEW.raw_user_meta_data->>'picture')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================
-- TEST DATA: Kategoriyalar
-- ============================================
INSERT INTO categories (id, name_uz, name_ru, slug, icon, sort_order, is_active) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Elektronika', 'Электроника', 'elektronika', 'devices', 1, true),
    ('22222222-2222-2222-2222-222222222222', 'Kiyim-kechak', 'Одежда', 'kiyim-kechak', 'checkroom', 2, true),
    ('33333333-3333-3333-3333-333333333333', 'Oziq-ovqat', 'Продукты', 'oziq-ovqat', 'restaurant', 3, true),
    ('44444444-4444-4444-4444-444444444444', 'Uy-rozgor', 'Дом и быт', 'uy-rozgor', 'home', 4, true),
    ('55555555-5555-5555-5555-555555555555', 'Gozallik', 'Красота', 'gozallik', 'spa', 5, true)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- TEST DATA: Demo do'kon
-- ============================================
INSERT INTO shops (id, name, description, status) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Demo Do''kon', 'Test uchun demo do''kon', 'approved')
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- TEST DATA: Namuna mahsulotlar
-- ============================================
INSERT INTO products (shop_id, category_id, name, name_uz, name_ru, description, price, old_price, stock, is_active, is_featured) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Smartfon', 'Smartfon', 'Смартфон', 'Zamonaviy smartfon', 2500000, 3000000, 10, true, true),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'Noutbuk', 'Noutbuk', 'Ноутбук', 'Kuchli noutbuk', 8000000, 9000000, 5, true, true),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'Ko''ylak', 'Ko''ylak', 'Рубашка', 'Chiroyli ko''ylak', 150000, 200000, 20, true, false),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '33333333-3333-3333-3333-333333333333', 'Non', 'Non', 'Хлеб', 'Yangi pishirilgan non', 5000, NULL, 100, true, false),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '44444444-4444-4444-4444-444444444444', 'Stul', 'Stul', 'Стул', 'Qulay stul', 350000, 400000, 15, true, false)
ON CONFLICT DO NOTHING;

-- ============================================
-- TEST DATA: Banner
-- ============================================
INSERT INTO banners (title, image_url, link, sort_order, is_active) VALUES
    ('Chegirmalar', 'https://via.placeholder.com/800x400/10B981/FFFFFF?text=50%+OFF', '/promotions', 1, true),
    ('Yangi mahsulotlar', 'https://via.placeholder.com/800x400/3B82F6/FFFFFF?text=NEW+ARRIVALS', '/new', 2, true)
ON CONFLICT DO NOTHING;
