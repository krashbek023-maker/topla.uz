-- =====================================================
-- ADMIN PANEL QOSHIMCHA JADVALLARI
-- Supabase Dashboard > SQL Editor da ishga tushiring
-- =====================================================

-- 1. BANNERS jadvali (Reklama bannerlari)
CREATE TABLE IF NOT EXISTS banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  title_ru VARCHAR(255),
  subtitle VARCHAR(255),
  subtitle_ru VARCHAR(255),
  image_url TEXT NOT NULL,
  link_type VARCHAR(20) DEFAULT 'none', -- none, product, category, url
  link_value TEXT, -- product_id, category_id, or external URL
  position INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,
  view_count INTEGER DEFAULT 0,
  click_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for banners
ALTER TABLE banners ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view active banners" ON banners;
CREATE POLICY "Anyone can view active banners"
  ON banners FOR SELECT
  USING (is_active = true AND (start_date IS NULL OR start_date <= NOW()) AND (end_date IS NULL OR end_date >= NOW()));

DROP POLICY IF EXISTS "Admins can manage banners" ON banners;
CREATE POLICY "Admins can manage banners"
  ON banners FOR ALL
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

-- 2. DELIVERY_ZONES jadvali (Yetkazib berish zonalari)
CREATE TABLE IF NOT EXISTS delivery_zones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  name_ru VARCHAR(100),
  city VARCHAR(100) NOT NULL,
  districts TEXT[], -- Tumanlar ro'yxati
  base_fee DECIMAL(10,2) DEFAULT 0,
  per_km_fee DECIMAL(10,2) DEFAULT 0,
  min_order_amount DECIMAL(10,2) DEFAULT 0,
  free_delivery_threshold DECIMAL(10,2), -- Bu summadan oshsa bepul
  estimated_time_min INTEGER DEFAULT 30, -- Daqiqalarda
  estimated_time_max INTEGER DEFAULT 60,
  is_active BOOLEAN DEFAULT TRUE,
  priority INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for delivery_zones
ALTER TABLE delivery_zones ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view active zones" ON delivery_zones;
CREATE POLICY "Anyone can view active zones"
  ON delivery_zones FOR SELECT
  USING (is_active = true);

DROP POLICY IF EXISTS "Admins can manage zones" ON delivery_zones;
CREATE POLICY "Admins can manage zones"
  ON delivery_zones FOR ALL
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

-- 3. APP_SETTINGS jadvali (Ilova sozlamalari)
CREATE TABLE IF NOT EXISTS app_settings (
  key VARCHAR(100) PRIMARY KEY,
  value JSONB NOT NULL,
  description TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  updated_by UUID REFERENCES profiles(id)
);

-- RLS for app_settings
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can read settings" ON app_settings;
CREATE POLICY "Anyone can read settings"
  ON app_settings FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Admins can update settings" ON app_settings;
CREATE POLICY "Admins can update settings"
  ON app_settings FOR ALL
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

-- Default sozlamalar
INSERT INTO app_settings (key, value, description) VALUES
  ('min_order_amount', '{"value": 50000}', 'Minimal buyurtma summasi (so''m)'),
  ('default_delivery_fee', '{"value": 15000}', 'Standart yetkazib berish narxi'),
  ('free_delivery_threshold', '{"value": 200000}', 'Bepul yetkazib berish chegarasi'),
  ('max_cashback_percent', '{"value": 10}', 'Maksimal cashback foizi'),
  ('commission_rate', '{"value": 10}', 'Standart komissiya foizi'),
  ('support_phone', '{"value": "+998901234567"}', 'Qo''llab-quvvatlash telefoni'),
  ('support_telegram', '{"value": "@topla_support"}', 'Telegram support'),
  ('app_version', '{"android": "1.0.0", "ios": "1.0.0"}', 'Ilova versiyasi'),
  ('maintenance_mode', '{"enabled": false, "message": ""}', 'Texnik ishlar rejimi')
ON CONFLICT (key) DO NOTHING;

-- 4. ADMIN_LOGS jadvali (Admin harakatlari tarixi) - agar yo'q bo'lsa
CREATE TABLE IF NOT EXISTS admin_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID REFERENCES profiles(id),
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(50), -- product, order, shop, user, etc.
  entity_id UUID,
  details JSONB,
  ip_address VARCHAR(45),
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_admin_logs_admin_id ON admin_logs(admin_id);
CREATE INDEX IF NOT EXISTS idx_admin_logs_action ON admin_logs(action);
CREATE INDEX IF NOT EXISTS idx_admin_logs_created_at ON admin_logs(created_at DESC);

-- RLS for admin_logs
ALTER TABLE admin_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view logs" ON admin_logs;
CREATE POLICY "Admins can view logs"
  ON admin_logs FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

DROP POLICY IF EXISTS "Admins can insert logs" ON admin_logs;
CREATE POLICY "Admins can insert logs"
  ON admin_logs FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

-- 5. PROMO_CODES jadvalini yangilash (agar mavjud bo'lsa)
-- Agar promo_codes jadvali yo'q bo'lsa yaratish
CREATE TABLE IF NOT EXISTS promo_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  discount_type VARCHAR(20) NOT NULL, -- percent, fixed
  discount_value DECIMAL(10,2) NOT NULL,
  min_order_amount DECIMAL(10,2) DEFAULT 0,
  max_discount_amount DECIMAL(10,2), -- Faqat percent uchun
  usage_limit INTEGER, -- Umumiy ishlatish limiti
  per_user_limit INTEGER DEFAULT 1, -- Har bir foydalanuvchi uchun
  usage_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  starts_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  applicable_categories UUID[], -- Faqat shu kategoriyalar uchun
  applicable_products UUID[], -- Faqat shu mahsulotlar uchun
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_promo_codes_code ON promo_codes(code);
CREATE INDEX IF NOT EXISTS idx_promo_codes_active ON promo_codes(is_active);

-- RLS for promo_codes
ALTER TABLE promo_codes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can validate promo codes" ON promo_codes;
CREATE POLICY "Anyone can validate promo codes"
  ON promo_codes FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Admins can manage promo codes" ON promo_codes;
CREATE POLICY "Admins can manage promo codes"
  ON promo_codes FOR ALL
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

-- 6. PROMO_CODE_USAGE jadvali
CREATE TABLE IF NOT EXISTS promo_code_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  promo_code_id UUID NOT NULL REFERENCES promo_codes(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  order_id UUID REFERENCES orders(id),
  discount_amount DECIMAL(10,2) NOT NULL,
  used_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(promo_code_id, order_id)
);

CREATE INDEX IF NOT EXISTS idx_promo_usage_user ON promo_code_usage(user_id);
CREATE INDEX IF NOT EXISTS idx_promo_usage_code ON promo_code_usage(promo_code_id);

-- 7. Trigger: Promo kod ishlatilganda usage_count ni oshirish
CREATE OR REPLACE FUNCTION increment_promo_usage()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE promo_codes 
  SET usage_count = usage_count + 1 
  WHERE id = NEW.promo_code_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS promo_usage_trigger ON promo_code_usage;
CREATE TRIGGER promo_usage_trigger
  AFTER INSERT ON promo_code_usage
  FOR EACH ROW
  EXECUTE FUNCTION increment_promo_usage();

-- 8. View: Admin dashboard statistikasi
CREATE OR REPLACE VIEW admin_dashboard_stats AS
SELECT
  (SELECT COUNT(*) FROM profiles WHERE role = 'user') as total_users,
  (SELECT COUNT(*) FROM profiles WHERE role = 'vendor') as total_vendors,
  (SELECT COUNT(*) FROM shops WHERE is_active = true) as active_shops,
  (SELECT COUNT(*) FROM products WHERE is_active = true) as active_products,
  (SELECT COUNT(*) FROM products WHERE moderation_status = 'pending') as pending_products,
  (SELECT COUNT(*) FROM orders WHERE created_at >= CURRENT_DATE) as today_orders,
  (SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE created_at >= CURRENT_DATE) as today_revenue,
  (SELECT COUNT(*) FROM orders WHERE created_at >= DATE_TRUNC('month', CURRENT_DATE)) as month_orders,
  (SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE created_at >= DATE_TRUNC('month', CURRENT_DATE)) as month_revenue,
  (SELECT COUNT(*) FROM shop_payouts WHERE status = 'pending') as pending_payouts;

-- =====================================================
-- TAYYOR!
-- =====================================================
