-- =====================================================
-- TOPLA.UZ - TO'LIQ DATABASE SCHEMA
-- Ushbu schema Web, Mobile App va Admin panel uchun yagona
-- Supabase SQL Editor'da ishga tushiring
-- =====================================================

-- =====================================================
-- 1. PROFILES (Foydalanuvchilar profili)
-- =====================================================
CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE,
    full_name TEXT,
    phone TEXT,
    avatar_url TEXT,
    role VARCHAR(20) DEFAULT 'customer' CHECK (role IN ('admin', 'vendor', 'customer')),
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Trigger: Yangi user uchun profil yaratish
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, role)
    VALUES (
        new.id, 
        new.email,
        new.raw_user_meta_data->>'full_name',
        COALESCE(new.raw_user_meta_data->>'role', 'customer')
    );
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- 2. CATEGORIES (Kategoriyalar)
-- =====================================================
CREATE TABLE IF NOT EXISTS categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name_uz VARCHAR(100) NOT NULL,
    name_ru VARCHAR(100),
    slug VARCHAR(100) UNIQUE NOT NULL,
    icon TEXT,
    image_url TEXT,
    parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_categories_parent ON categories(parent_id);
CREATE INDEX IF NOT EXISTS idx_categories_slug ON categories(slug);

-- =====================================================
-- 3. SHOPS (Do'konlar)
-- =====================================================
CREATE TABLE IF NOT EXISTS shops (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    owner_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE,
    description TEXT,
    logo_url TEXT,
    banner_url TEXT,
    phone VARCHAR(20),
    email TEXT,
    address TEXT,
    city VARCHAR(50),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'rejected', 'blocked')),
    rejection_reason TEXT,
    commission_rate DECIMAL(5,2) DEFAULT 10.00,
    balance DECIMAL(15,2) DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0,
    total_orders INTEGER DEFAULT 0,
    total_products INTEGER DEFAULT 0,
    working_hours JSONB DEFAULT '{"mon": {"open": "09:00", "close": "18:00"}, "tue": {"open": "09:00", "close": "18:00"}, "wed": {"open": "09:00", "close": "18:00"}, "thu": {"open": "09:00", "close": "18:00"}, "fri": {"open": "09:00", "close": "18:00"}, "sat": {"open": "09:00", "close": "18:00"}, "sun": null}',
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_shops_owner ON shops(owner_id);
CREATE INDEX IF NOT EXISTS idx_shops_status ON shops(status);
CREATE INDEX IF NOT EXISTS idx_shops_slug ON shops(slug);

-- =====================================================
-- 4. PRODUCTS (Mahsulotlar)
-- =====================================================
CREATE TABLE IF NOT EXISTS products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    shop_id UUID REFERENCES shops(id) ON DELETE CASCADE NOT NULL,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    name_uz VARCHAR(200) NOT NULL,
    name_ru VARCHAR(200),
    description_uz TEXT,
    description_ru TEXT,
    slug VARCHAR(250),
    sku VARCHAR(50),
    price DECIMAL(15,2) NOT NULL,
    compare_price DECIMAL(15,2),
    cost_price DECIMAL(15,2),
    quantity INTEGER DEFAULT 0,
    min_order_quantity INTEGER DEFAULT 1,
    max_order_quantity INTEGER,
    unit VARCHAR(20) DEFAULT 'dona',
    weight DECIMAL(10,3),
    images JSONB DEFAULT '[]',
    thumbnail_url TEXT,
    attributes JSONB DEFAULT '{}',
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'draft')),
    rejection_reason TEXT,
    is_active BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    views INTEGER DEFAULT 0,
    sold_count INTEGER DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_products_shop ON products(shop_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
CREATE INDEX IF NOT EXISTS idx_products_slug ON products(slug);
CREATE INDEX IF NOT EXISTS idx_products_price ON products(price);

-- =====================================================
-- 5. PRODUCT_VARIANTS (Mahsulot variantlari - rang, razmer)
-- =====================================================
CREATE TABLE IF NOT EXISTS product_variants (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
    name VARCHAR(100) NOT NULL,
    sku VARCHAR(50),
    price DECIMAL(15,2),
    quantity INTEGER DEFAULT 0,
    attributes JSONB DEFAULT '{}',
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_variants_product ON product_variants(product_id);

-- =====================================================
-- 6. ADDRESSES (Yetkazib berish manzillari)
-- =====================================================
CREATE TABLE IF NOT EXISTS addresses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    name VARCHAR(100),
    phone VARCHAR(20),
    city VARCHAR(50),
    district VARCHAR(100),
    street TEXT,
    house VARCHAR(20),
    apartment VARCHAR(20),
    entrance VARCHAR(10),
    floor VARCHAR(10),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_addresses_user ON addresses(user_id);

-- =====================================================
-- 7. ORDERS (Buyurtmalar)
-- =====================================================
CREATE TABLE IF NOT EXISTS orders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    shop_id UUID REFERENCES shops(id) ON DELETE SET NULL,
    address_id UUID REFERENCES addresses(id) ON DELETE SET NULL,
    
    -- Snapshot of delivery address
    delivery_address JSONB,
    
    -- Contact info
    customer_name VARCHAR(100),
    customer_phone VARCHAR(20),
    customer_email TEXT,
    
    -- Amounts
    subtotal DECIMAL(15,2) NOT NULL DEFAULT 0,
    delivery_fee DECIMAL(15,2) DEFAULT 0,
    discount DECIMAL(15,2) DEFAULT 0,
    total DECIMAL(15,2) NOT NULL DEFAULT 0,
    
    -- Commission
    commission_amount DECIMAL(15,2) DEFAULT 0,
    vendor_amount DECIMAL(15,2) DEFAULT 0,
    
    -- Status
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready', 'delivering', 'delivered', 'cancelled', 'refunded')),
    payment_method VARCHAR(20) DEFAULT 'cash' CHECK (payment_method IN ('cash', 'card', 'payme', 'click', 'uzum')),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    
    -- Delivery
    delivery_type VARCHAR(20) DEFAULT 'delivery' CHECK (delivery_type IN ('delivery', 'pickup')),
    scheduled_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    
    -- Notes
    customer_note TEXT,
    admin_note TEXT,
    cancellation_reason TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_shop ON orders(shop_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_number ON orders(order_number);
CREATE INDEX IF NOT EXISTS idx_orders_created ON orders(created_at DESC);

-- Function to generate order number
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS trigger AS $$
BEGIN
    NEW.order_number := 'ORD-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_order_number ON orders;
CREATE TRIGGER set_order_number
    BEFORE INSERT ON orders
    FOR EACH ROW
    WHEN (NEW.order_number IS NULL)
    EXECUTE FUNCTION generate_order_number();

-- =====================================================
-- 8. ORDER_ITEMS (Buyurtma elementlari)
-- =====================================================
CREATE TABLE IF NOT EXISTS order_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    variant_id UUID REFERENCES product_variants(id) ON DELETE SET NULL,
    
    -- Snapshot of product at order time
    product_name VARCHAR(200) NOT NULL,
    product_image TEXT,
    variant_name VARCHAR(100),
    
    quantity INTEGER NOT NULL DEFAULT 1,
    price DECIMAL(15,2) NOT NULL,
    total DECIMAL(15,2) NOT NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);

-- =====================================================
-- 9. CART (Savat)
-- =====================================================
CREATE TABLE IF NOT EXISTS cart_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
    variant_id UUID REFERENCES product_variants(id) ON DELETE SET NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, product_id, variant_id)
);

CREATE INDEX IF NOT EXISTS idx_cart_user ON cart_items(user_id);

-- =====================================================
-- 10. FAVORITES (Sevimlilar)
-- =====================================================
CREATE TABLE IF NOT EXISTS favorites (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites(user_id);

-- =====================================================
-- 11. REVIEWS (Sharhlar)
-- =====================================================
CREATE TABLE IF NOT EXISTS reviews (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    images JSONB DEFAULT '[]',
    is_verified BOOLEAN DEFAULT false,
    reply TEXT,
    replied_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reviews_product ON reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_reviews_shop ON reviews(shop_id);

-- =====================================================
-- 12. BANNERS (Reklama bannerlari)
-- =====================================================
CREATE TABLE IF NOT EXISTS banners (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title VARCHAR(100),
    description TEXT,
    image_url TEXT NOT NULL,
    mobile_image_url TEXT,
    link_type VARCHAR(20) CHECK (link_type IN ('product', 'category', 'shop', 'url', 'none')),
    link_value TEXT,
    position VARCHAR(20) DEFAULT 'home' CHECK (position IN ('home', 'category', 'shop')),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    starts_at TIMESTAMP WITH TIME ZONE,
    ends_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 13. PROMO_CODES (Promo kodlar)
-- =====================================================
CREATE TABLE IF NOT EXISTS promo_codes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    discount_type VARCHAR(20) CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value DECIMAL(15,2) NOT NULL,
    min_order_amount DECIMAL(15,2) DEFAULT 0,
    max_discount DECIMAL(15,2),
    usage_limit INTEGER,
    used_count INTEGER DEFAULT 0,
    user_limit INTEGER DEFAULT 1,
    shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT true,
    starts_at TIMESTAMP WITH TIME ZONE,
    ends_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_promo_code ON promo_codes(code);

-- =====================================================
-- 14. PAYOUTS (Sotuvchilarga to'lovlar)
-- =====================================================
CREATE TABLE IF NOT EXISTS payouts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    shop_id UUID REFERENCES shops(id) ON DELETE CASCADE NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'rejected')),
    payment_method VARCHAR(20) DEFAULT 'card',
    card_number VARCHAR(20),
    card_holder VARCHAR(100),
    bank_name VARCHAR(50),
    reference_number VARCHAR(50),
    admin_note TEXT,
    processed_at TIMESTAMP WITH TIME ZONE,
    processed_by UUID REFERENCES profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payouts_shop ON payouts(shop_id);
CREATE INDEX IF NOT EXISTS idx_payouts_status ON payouts(status);

-- =====================================================
-- 15. NOTIFICATIONS (Bildirishnomalar)
-- =====================================================
CREATE TABLE IF NOT EXISTS notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    body TEXT,
    type VARCHAR(50),
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(is_read);

-- =====================================================
-- 16. DELIVERY_ZONES (Yetkazib berish zonalari)
-- =====================================================
CREATE TABLE IF NOT EXISTS delivery_zones (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    districts TEXT[],
    delivery_fee DECIMAL(15,2) DEFAULT 0,
    min_order_amount DECIMAL(15,2) DEFAULT 0,
    estimated_time VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 17. SETTINGS (Tizim sozlamalari)
-- =====================================================
CREATE TABLE IF NOT EXISTS settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Default settings
INSERT INTO settings (key, value, description) VALUES
('commission_rate', '10', 'Default commission rate for new shops'),
('min_payout_amount', '100000', 'Minimum payout amount in UZS'),
('order_auto_cancel_minutes', '30', 'Auto cancel pending orders after X minutes'),
('contact_phone', '"+998901234567"', 'Support phone number'),
('contact_email', '"support@topla.uz"', 'Support email')
ON CONFLICT (key) DO NOTHING;

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE payouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Public profiles viewable" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- Categories - public read
CREATE POLICY "Categories are viewable by everyone" ON categories FOR SELECT USING (true);

-- Shops policies
CREATE POLICY "Active shops viewable" ON shops FOR SELECT USING (status = 'active' OR owner_id = auth.uid());
CREATE POLICY "Vendors manage own shop" ON shops FOR ALL USING (owner_id = auth.uid());

-- Products policies
CREATE POLICY "Approved products viewable" ON products FOR SELECT USING (status = 'approved' AND is_active = true);
CREATE POLICY "Shop owners manage products" ON products FOR ALL USING (
    shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
);

-- Orders policies
CREATE POLICY "Users view own orders" ON orders FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Vendors view shop orders" ON orders FOR SELECT USING (
    shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
);
CREATE POLICY "Users create orders" ON orders FOR INSERT WITH CHECK (user_id = auth.uid());

-- Order items
CREATE POLICY "View order items" ON order_items FOR SELECT USING (
    order_id IN (SELECT id FROM orders WHERE user_id = auth.uid() OR shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid()))
);

-- Cart policies
CREATE POLICY "Users manage own cart" ON cart_items FOR ALL USING (user_id = auth.uid());

-- Favorites policies
CREATE POLICY "Users manage own favorites" ON favorites FOR ALL USING (user_id = auth.uid());

-- Addresses policies
CREATE POLICY "Users manage own addresses" ON addresses FOR ALL USING (user_id = auth.uid());

-- Reviews policies
CREATE POLICY "Reviews viewable" ON reviews FOR SELECT USING (true);
CREATE POLICY "Users create reviews" ON reviews FOR INSERT WITH CHECK (user_id = auth.uid());

-- Payouts policies
CREATE POLICY "Vendors view own payouts" ON payouts FOR SELECT USING (
    shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
);
CREATE POLICY "Vendors request payouts" ON payouts FOR INSERT WITH CHECK (
    shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
);

-- Notifications policies
CREATE POLICY "Users view own notifications" ON notifications FOR ALL USING (user_id = auth.uid());

-- Banners - public read
CREATE POLICY "Banners viewable" ON banners FOR SELECT USING (is_active = true);

-- Promo codes - public read active
CREATE POLICY "Active promo codes viewable" ON promo_codes FOR SELECT USING (is_active = true);

-- Delivery zones - public read
CREATE POLICY "Delivery zones viewable" ON delivery_zones FOR SELECT USING (is_active = true);

-- =====================================================
-- ADMIN FULL ACCESS (Service Role orqali)
-- Admin panel Service Role key ishlatadi
-- =====================================================

-- =====================================================
-- UPDATED_AT TRIGGER
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
DO $$
DECLARE
    t TEXT;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.columns 
        WHERE column_name = 'updated_at' 
        AND table_schema = 'public'
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS update_%I_updated_at ON %I', t, t);
        EXECUTE format('CREATE TRIGGER update_%I_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION update_updated_at_column()', t, t);
    END LOOP;
END;
$$;

-- =====================================================
-- INITIAL DATA
-- =====================================================

-- Kategoriyalar
INSERT INTO categories (name_uz, name_ru, slug, icon, sort_order) VALUES
('Elektronika', 'Электроника', 'elektronika', '📱', 1),
('Kiyim-kechak', 'Одежда', 'kiyim-kechak', '👕', 2),
('Uy-ro''zg''or', 'Товары для дома', 'uy-rozgor', '🏠', 3),
('Oziq-ovqat', 'Продукты питания', 'oziq-ovqat', '🍎', 4),
('Go''zallik', 'Красота', 'gozallik', '💄', 5),
('Salomatlik', 'Здоровье', 'salomatlik', '💊', 6),
('Sport', 'Спорт', 'sport', '⚽', 7),
('Bolalar', 'Детские товары', 'bolalar', '🧸', 8),
('Avtomobil', 'Автотовары', 'avtomobil', '🚗', 9),
('Kitoblar', 'Книги', 'kitoblar', '📚', 10)
ON CONFLICT (slug) DO NOTHING;

-- Subcategories for Elektronika
INSERT INTO categories (name_uz, name_ru, slug, parent_id, sort_order) 
SELECT 'Smartfonlar', 'Смартфоны', 'smartfonlar', id, 1 FROM categories WHERE slug = 'elektronika'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO categories (name_uz, name_ru, slug, parent_id, sort_order) 
SELECT 'Noutbuklar', 'Ноутбуки', 'noutbuklar', id, 2 FROM categories WHERE slug = 'elektronika'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO categories (name_uz, name_ru, slug, parent_id, sort_order) 
SELECT 'Televizorlar', 'Телевизоры', 'televizorlar', id, 3 FROM categories WHERE slug = 'elektronika'
ON CONFLICT (slug) DO NOTHING;

INSERT INTO categories (name_uz, name_ru, slug, parent_id, sort_order) 
SELECT 'Aksessuarlar', 'Аксессуары', 'aksessuarlar', id, 4 FROM categories WHERE slug = 'elektronika'
ON CONFLICT (slug) DO NOTHING;

-- =====================================================
-- DONE! ✅
-- =====================================================
