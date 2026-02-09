-- ============================================
-- TOPLA.APP Complete Database Setup
-- Multi-vendor marketplace full schema
-- ============================================

-- ==========================================
-- 1. ASOSIY JADVALLAR
-- ==========================================

-- Profiles jadvali (foydalanuvchilar)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    phone VARCHAR(20),
    full_name VARCHAR(100),
    email VARCHAR(255),
    avatar_url TEXT,
    role VARCHAR(20) DEFAULT 'customer' CHECK (role IN ('customer', 'vendor', 'admin', 'superadmin')),
    is_verified BOOLEAN DEFAULT FALSE,
    fcm_token TEXT,
    language VARCHAR(5) DEFAULT 'uz',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Kategoriyalar jadvali (asosiy va subkategoriyalar)
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    name_uz VARCHAR(100) NOT NULL,
    name_ru VARCHAR(100),
    icon VARCHAR(50),
    image_url TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Do'konlar jadvali
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
    balance DECIMAL(15,2) DEFAULT 0,
    commission_rate DECIMAL(5,4) DEFAULT 0.05, -- 5% default komissiya
    min_order_amount INT DEFAULT 0,
    delivery_fee INT DEFAULT 0,
    working_hours JSONB DEFAULT '{"mon": {"open": "09:00", "close": "21:00"}, "tue": {"open": "09:00", "close": "21:00"}, "wed": {"open": "09:00", "close": "21:00"}, "thu": {"open": "09:00", "close": "21:00"}, "fri": {"open": "09:00", "close": "21:00"}, "sat": {"open": "09:00", "close": "21:00"}, "sun": {"open": "09:00", "close": "21:00"}}',
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'suspended')),
    rejection_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Mahsulotlar jadvali
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id),
    subcategory_id UUID REFERENCES categories(id),
    name_uz VARCHAR(255) NOT NULL,
    name_ru VARCHAR(255),
    description_uz TEXT,
    description_ru TEXT,
    price DECIMAL(15,2) NOT NULL,
    old_price DECIMAL(15,2),
    images TEXT[] DEFAULT '{}',
    stock INT DEFAULT 0,
    sold_count INT DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0,
    review_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    is_flash_sale BOOLEAN DEFAULT FALSE,
    flash_sale_end TIMESTAMPTZ,
    cashback_percent INT DEFAULT 0,
    moderation_status VARCHAR(20) DEFAULT 'pending' CHECK (moderation_status IN ('pending', 'approved', 'rejected')),
    rejection_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Manzillar jadvali
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

-- Buyurtmalar jadvali
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id),
    address_id UUID REFERENCES addresses(id),
    status VARCHAR(30) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready', 'delivering', 'delivered', 'cancelled')),
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('cash', 'card', 'click', 'payme')),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    subtotal DECIMAL(15,2) NOT NULL,
    delivery_fee DECIMAL(15,2) DEFAULT 0,
    discount DECIMAL(15,2) DEFAULT 0,
    total DECIMAL(15,2) NOT NULL,
    delivery_time VARCHAR(20),
    scheduled_date DATE,
    scheduled_time_slot VARCHAR(20),
    comment TEXT,
    promo_code VARCHAR(50),
    paid_at TIMESTAMPTZ,
    confirmed_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    cancellation_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Buyurtma elementlari jadvali
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

-- Savat jadvali
CREATE TABLE IF NOT EXISTS cart_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    quantity INT DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

-- Sevimlilar jadvali
CREATE TABLE IF NOT EXISTS favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

-- ==========================================
-- 2. TO'LOV TIZIMLARI
-- ==========================================

-- Saqlangan kartalar jadvali
CREATE TABLE IF NOT EXISTS saved_cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    card_token TEXT NOT NULL,
    binding_id TEXT,
    masked_pan VARCHAR(20) NOT NULL,
    card_type VARCHAR(20) NOT NULL CHECK (card_type IN ('uzcard', 'humo', 'visa', 'mastercard')),
    expiry_date VARCHAR(10),
    card_holder VARCHAR(100),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tranzaksiyalar jadvali
CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id),
    user_id UUID REFERENCES profiles(id),
    card_id UUID REFERENCES saved_cards(id),
    type VARCHAR(20) NOT NULL CHECK (type IN ('payment', 'refund', 'payout')),
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'UZS',
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'success', 'failed', 'cancelled')),
    bank_transaction_id TEXT,
    payment_method VARCHAR(20),
    error_code VARCHAR(50),
    error_message TEXT,
    raw_response JSONB,
    processed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Komissiya sozlamalari
CREATE TABLE IF NOT EXISTS commission_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    min_amount DECIMAL(15,2) DEFAULT 0,
    max_amount DECIMAL(15,2),
    rate DECIMAL(5,4) NOT NULL, -- 0.05 = 5%
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Vendor tranzaksiyalari
CREATE TABLE IF NOT EXISTS vendor_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(id),
    type VARCHAR(30) NOT NULL CHECK (type IN ('order_payment', 'payout', 'refund', 'commission', 'adjustment')),
    amount DECIMAL(15,2) NOT NULL,
    commission_amount DECIMAL(15,2) DEFAULT 0,
    commission_rate DECIMAL(5,4),
    balance_before DECIMAL(15,2),
    balance_after DECIMAL(15,2),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'cancelled')),
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ
);

-- Vendor to'lovlari (payouts)
CREATE TABLE IF NOT EXISTS shop_payouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
    amount DECIMAL(15,2) NOT NULL,
    card_number VARCHAR(20),
    card_holder VARCHAR(100),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')),
    bank_reference TEXT,
    processed_by UUID REFERENCES profiles(id),
    processed_at TIMESTAMPTZ,
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 3. ADMIN VA TIZIM JADVALLARI
-- ==========================================

-- Promo kodlar
CREATE TABLE IF NOT EXISTS promo_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) UNIQUE NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('percent', 'fixed')),
    value DECIMAL(10,2) NOT NULL,
    min_order DECIMAL(15,2) DEFAULT 0,
    max_discount DECIMAL(15,2),
    usage_limit INT,
    used_count INT DEFAULT 0,
    valid_from TIMESTAMPTZ DEFAULT NOW(),
    valid_until TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Bannerlar
CREATE TABLE IF NOT EXISTS banners (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255),
    image_url TEXT NOT NULL,
    link_type VARCHAR(20) CHECK (link_type IN ('product', 'category', 'shop', 'url', 'none')),
    link_value TEXT,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    starts_at TIMESTAMPTZ DEFAULT NOW(),
    ends_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Yetkazib berish zonalari
CREATE TABLE IF NOT EXISTS delivery_zones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    polygon JSONB, -- GeoJSON polygon
    delivery_fee DECIMAL(10,2) DEFAULT 0,
    min_order DECIMAL(15,2) DEFAULT 0,
    delivery_time VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Admin loglar
CREATE TABLE IF NOT EXISTS admin_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id UUID REFERENCES profiles(id),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id UUID,
    old_data JSONB,
    new_data JSONB,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ilova sozlamalari
CREATE TABLE IF NOT EXISTS app_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key VARCHAR(100) UNIQUE NOT NULL,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Bildirishnomalar
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    body TEXT,
    type VARCHAR(50),
    data JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Mahsulot moderatsiya loglari
CREATE TABLE IF NOT EXISTS product_moderation_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    admin_id UUID REFERENCES profiles(id),
    action VARCHAR(50) NOT NULL,
    previous_status VARCHAR(20),
    new_status VARCHAR(20),
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sharhlar
CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(id),
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    images TEXT[],
    is_anonymous BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE, -- Sotib olgan foydalanuvchi
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 4. INDEKSLAR
-- ==========================================

CREATE INDEX IF NOT EXISTS idx_products_shop ON products(shop_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_subcategory ON products(subcategory_id);
CREATE INDEX IF NOT EXISTS idx_products_active ON products(is_active, moderation_status);
CREATE INDEX IF NOT EXISTS idx_products_search ON products USING gin(to_tsvector('simple', name_uz || ' ' || COALESCE(name_ru, '')));

CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_shop ON order_items(shop_id);

CREATE INDEX IF NOT EXISTS idx_cart_user ON cart_items(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites(user_id);

CREATE INDEX IF NOT EXISTS idx_transactions_order ON transactions(order_id);
CREATE INDEX IF NOT EXISTS idx_transactions_user ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_vendor_transactions_shop ON vendor_transactions(shop_id);

CREATE INDEX IF NOT EXISTS idx_categories_parent ON categories(parent_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id, is_read);

-- ==========================================
-- 5. FUNKSIYALAR
-- ==========================================

-- Profil avtomatik yaratish (auth.users trigger uchun)
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO profiles (id, phone, email, role)
    VALUES (
        NEW.id, 
        NEW.phone,
        NEW.email,
        'customer'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Buyurtma yaratilganda order_items shop_id va total hisoblash
CREATE OR REPLACE FUNCTION set_order_item_details()
RETURNS TRIGGER AS $$
BEGIN
    -- Shop ID ni mahsulotdan olish
    SELECT shop_id INTO NEW.shop_id FROM products WHERE id = NEW.product_id;
    -- Total hisoblash
    NEW.total := NEW.price * NEW.quantity;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS order_item_details_trigger ON order_items;
CREATE TRIGGER order_item_details_trigger
    BEFORE INSERT ON order_items
    FOR EACH ROW EXECUTE FUNCTION set_order_item_details();

-- Buyurtma yakunlanganda vendor balansini yangilash
CREATE OR REPLACE FUNCTION update_vendor_balance_on_order()
RETURNS TRIGGER AS $$
DECLARE
    v_shop RECORD;
    v_order_total DECIMAL(15,2);
    v_commission DECIMAL(15,2);
    v_net_amount DECIMAL(15,2);
BEGIN
    IF NEW.status = 'delivered' AND NEW.payment_status = 'paid' AND 
       (OLD.status IS NULL OR OLD.status != 'delivered') THEN
        
        -- Har bir shop uchun
        FOR v_shop IN 
            SELECT shop_id, SUM(total) as shop_total
            FROM order_items 
            WHERE order_id = NEW.id
            GROUP BY shop_id
        LOOP
            IF v_shop.shop_id IS NOT NULL THEN
                -- Komissiya hisoblash
                SELECT commission_rate INTO v_commission 
                FROM shops WHERE id = v_shop.shop_id;
                
                v_commission := COALESCE(v_commission, 0.05);
                v_net_amount := v_shop.shop_total * (1 - v_commission);
                
                -- Vendor tranzaksiya yaratish
                INSERT INTO vendor_transactions (
                    shop_id, order_id, type, amount, 
                    commission_amount, commission_rate, status
                ) VALUES (
                    v_shop.shop_id, NEW.id, 'order_payment', v_net_amount,
                    v_shop.shop_total * v_commission, v_commission, 'completed'
                );
                
                -- Shop balansini yangilash
                UPDATE shops 
                SET balance = balance + v_net_amount,
                    total_sales = total_sales + 1,
                    updated_at = NOW()
                WHERE id = v_shop.shop_id;
            END IF;
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS vendor_balance_update_trigger ON orders;
CREATE TRIGGER vendor_balance_update_trigger
    AFTER UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_vendor_balance_on_order();

-- Mahsulot reyting yangilash
CREATE OR REPLACE FUNCTION update_product_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE products 
    SET rating = (SELECT AVG(rating) FROM reviews WHERE product_id = NEW.product_id),
        review_count = (SELECT COUNT(*) FROM reviews WHERE product_id = NEW.product_id)
    WHERE id = NEW.product_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS product_rating_trigger ON reviews;
CREATE TRIGGER product_rating_trigger
    AFTER INSERT OR UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_product_rating();

-- Updated_at avtomatik yangilash
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger yaratish
DO $$
DECLARE
    t text;
BEGIN
    FOR t IN 
        SELECT table_name FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name IN ('profiles', 'shops', 'products', 'orders', 'addresses', 'cart_items', 'saved_cards', 'reviews')
    LOOP
        EXECUTE format('
            DROP TRIGGER IF EXISTS update_%I_updated_at ON %I;
            CREATE TRIGGER update_%I_updated_at
                BEFORE UPDATE ON %I
                FOR EACH ROW EXECUTE FUNCTION update_updated_at();
        ', t, t, t, t);
    END LOOP;
END;
$$;

-- ==========================================
-- 6. RLS (Row Level Security)
-- ==========================================

-- RLS yoqish
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE shop_payouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Profiles
CREATE POLICY "Profiles: public read" ON profiles FOR SELECT USING (true);
CREATE POLICY "Profiles: own update" ON profiles FOR UPDATE USING (auth.uid() = id);

-- Shops
CREATE POLICY "Shops: public read active" ON shops FOR SELECT USING (is_active = true OR owner_id = auth.uid());
CREATE POLICY "Shops: owner manage" ON shops FOR ALL USING (owner_id = auth.uid());

-- Products
CREATE POLICY "Products: public read active" ON products FOR SELECT USING (
    (is_active = true AND moderation_status = 'approved') 
    OR shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
);
CREATE POLICY "Products: vendor manage" ON products FOR ALL USING (
    shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
);

-- Orders
CREATE POLICY "Orders: own read" ON orders FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Orders: own insert" ON orders FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Orders: vendor read" ON orders FOR SELECT USING (
    id IN (SELECT order_id FROM order_items WHERE shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid()))
);

-- Order Items
CREATE POLICY "Order Items: order owner read" ON order_items FOR SELECT USING (
    order_id IN (SELECT id FROM orders WHERE user_id = auth.uid())
    OR shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
);

-- Addresses
CREATE POLICY "Addresses: own all" ON addresses FOR ALL USING (user_id = auth.uid());

-- Cart Items
CREATE POLICY "Cart: own all" ON cart_items FOR ALL USING (user_id = auth.uid());

-- Favorites
CREATE POLICY "Favorites: own all" ON favorites FOR ALL USING (user_id = auth.uid());

-- Saved Cards
CREATE POLICY "Cards: own all" ON saved_cards FOR ALL USING (user_id = auth.uid());

-- Transactions
CREATE POLICY "Transactions: own read" ON transactions FOR SELECT USING (user_id = auth.uid());

-- Vendor Transactions
CREATE POLICY "Vendor Transactions: shop owner read" ON vendor_transactions FOR SELECT USING (
    shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
);

-- Shop Payouts
CREATE POLICY "Payouts: shop owner read" ON shop_payouts FOR SELECT USING (
    shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
);
CREATE POLICY "Payouts: shop owner insert" ON shop_payouts FOR INSERT WITH CHECK (
    shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
);

-- Notifications
CREATE POLICY "Notifications: own all" ON notifications FOR ALL USING (user_id = auth.uid());

-- Reviews
CREATE POLICY "Reviews: public read" ON reviews FOR SELECT USING (true);
CREATE POLICY "Reviews: own manage" ON reviews FOR ALL USING (user_id = auth.uid());

-- Public tables (no RLS)
-- Categories, Banners, Promo codes - public read

-- ==========================================
-- 7. BOSHLANG'ICH MA'LUMOTLAR
-- ==========================================

-- Komissiya sozlamalari
INSERT INTO commission_settings (min_amount, max_amount, rate, is_active) VALUES
(0, 1000000, 0.08, true),      -- 8% kichik buyurtmalar uchun
(1000000, 5000000, 0.06, true), -- 6% o'rta buyurtmalar
(5000000, NULL, 0.05, true)     -- 5% katta buyurtmalar
ON CONFLICT DO NOTHING;

-- Ilova sozlamalari
INSERT INTO app_settings (key, value, description) VALUES
('min_order_amount', '20000', 'Minimal buyurtma summasi'),
('default_delivery_fee', '10000', 'Standart yetkazib berish narxi'),
('free_delivery_threshold', '100000', 'Bepul yetkazib berish chegarasi'),
('app_version', '"1.0.0"', 'Joriy ilova versiyasi'),
('maintenance_mode', 'false', 'Texnik ishlar rejimi'),
('support_phone', '"+998901234567"', 'Qo''llab-quvvatlash telefoni'),
('support_email', '"support@topla.uz"', 'Qo''llab-quvvatlash email')
ON CONFLICT (key) DO NOTHING;

-- Asosiy kategoriyalar
INSERT INTO categories (name_uz, name_ru, icon, sort_order) VALUES
('Oziq-ovqat', 'Продукты', 'restaurant', 1),
('Ichimliklar', 'Напитки', 'local_cafe', 2),
('Go''zallik', 'Красота', 'spa', 3),
('Sog''liq', 'Здоровье', 'favorite', 4),
('Uy-ro''zg''or', 'Товары для дома', 'home', 5),
('Elektronika', 'Электроника', 'devices', 6),
('Kiyim', 'Одежда', 'checkroom', 7),
('Sport', 'Спорт', 'sports_soccer', 8)
ON CONFLICT DO NOTHING;

-- ==========================================
-- 8. STORAGE BUCKETS
-- ==========================================

-- Supabase Storage buckets yaratish (SQL orqali)
-- Bu qismni Supabase Dashboard > Storage dan qo'lda yarating:
-- 1. products - mahsulot rasmlari
-- 2. shops - do'kon logolari va cover rasmlari
-- 3. avatars - foydalanuvchi avatarlari
-- 4. banners - banner rasmlari
-- 5. categories - kategoriya rasmlari

-- Storage RLS policies (Supabase dashboard orqali sozlash kerak)

SELECT 'Database setup completed successfully!' as status;
