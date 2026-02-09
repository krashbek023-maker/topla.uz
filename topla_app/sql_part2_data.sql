-- =====================================================
-- QISM 2: RLS, FUNCTIONS, DATA
-- (QISM 1 dan keyin ishga tushiring)
-- =====================================================

-- INDEXES
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_active ON products(is_active);
CREATE INDEX idx_products_featured ON products(is_featured);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_cart_user ON cart_items(user_id);
CREATE INDEX idx_favorites_user ON favorites(user_id);

-- RLS ENABLE
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE banners ENABLE ROW LEVEL SECURITY;

-- POLICIES
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can view own addresses" ON addresses FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own addresses" ON addresses FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own addresses" ON addresses FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own addresses" ON addresses FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own orders" ON orders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own orders" ON orders FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own order items" ON order_items FOR SELECT 
    USING (EXISTS (SELECT 1 FROM orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid()));

CREATE POLICY "Users can manage own cart" ON cart_items FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own favorites" ON favorites FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Anyone can view reviews" ON reviews FOR SELECT USING (true);
CREATE POLICY "Users can insert own reviews" ON reviews FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Anyone can view categories" ON categories FOR SELECT USING (is_active = true);
CREATE POLICY "Anyone can view products" ON products FOR SELECT USING (is_active = true);
CREATE POLICY "Anyone can view banners" ON banners FOR SELECT USING (is_active = true);

-- FUNCTIONS
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.order_number = 'TOP' || TO_CHAR(NOW(), 'YYMMDD') || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGERS
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_order_number BEFORE INSERT ON orders FOR EACH ROW EXECUTE FUNCTION generate_order_number();

-- TEST DATA
INSERT INTO categories (name_uz, name_ru, icon, sort_order) VALUES
('Elektronika', 'Электроника', 'devices', 1),
('Kiyim', 'Одежда', 'checkroom', 2),
('Uy-rozgor', 'Дом и быт', 'home', 3),
('Gozallik', 'Красота', 'spa', 4),
('Bolalar', 'Детские', 'child_care', 5),
('Sport', 'Спорт', 'fitness_center', 6),
('Oziq-ovqat', 'Продукты', 'restaurant', 7),
('Avto', 'Авто', 'directions_car', 8);

INSERT INTO products (name_uz, name_ru, price, old_price, category_id, images, stock, rating, is_featured, is_active, cashback_percent) VALUES
('iPhone 15 Pro Max', 'iPhone 15 Pro Max', 15999000, 17500000, (SELECT id FROM categories WHERE name_uz = 'Elektronika'), ARRAY['https://picsum.photos/400/400?random=1'], 50, 4.8, true, true, 3),
('Samsung Galaxy S24', 'Samsung Galaxy S24', 14500000, 15999000, (SELECT id FROM categories WHERE name_uz = 'Elektronika'), ARRAY['https://picsum.photos/400/400?random=2'], 35, 4.7, true, true, 5),
('AirPods Pro 2', 'AirPods Pro 2', 2850000, 3200000, (SELECT id FROM categories WHERE name_uz = 'Elektronika'), ARRAY['https://picsum.photos/400/400?random=3'], 100, 4.9, true, true, 2),
('Nike Air Max', 'Nike Air Max', 890000, 1200000, (SELECT id FROM categories WHERE name_uz = 'Sport'), ARRAY['https://picsum.photos/400/400?random=4'], 80, 4.6, true, true, 4),
('Xiaomi Robot Vacuum', 'Xiaomi Robot Vacuum', 3200000, 4500000, (SELECT id FROM categories WHERE name_uz = 'Uy-rozgor'), ARRAY['https://picsum.photos/400/400?random=6'], 25, 4.7, true, true, 5);

INSERT INTO banners (title_uz, title_ru, subtitle_uz, subtitle_ru, image_url, action_type, sort_order, is_active) VALUES
('Katta chegirmalar!', 'Большие скидки!', '50% gacha chegirma', 'Скидки до 50%', 'https://picsum.photos/800/400?random=10', 'category', 1, true),
('Yangi kolleksiya', 'Новая коллекция', 'Bahorgi kiyimlar', 'Весенняя одежда', 'https://picsum.photos/800/400?random=11', 'category', 2, true),
('Flash Sale', 'Flash Sale', 'Faqat bugun!', 'Только сегодня!', 'https://picsum.photos/800/400?random=12', 'none', 3, true);

SELECT 'DATABASE TAYYOR! ✅' as status;
