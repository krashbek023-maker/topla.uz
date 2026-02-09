-- =====================================================
-- SHOPS VA VENDOR JADVALLARI
-- Supabase Dashboard > SQL Editor da ishga tushiring
-- =====================================================

-- 1. profiles jadvaliga role ustuni qo'shish
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS role VARCHAR(20) DEFAULT 'user';

-- Role uchun index
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);

-- 2. shops jadvali
CREATE TABLE IF NOT EXISTS shops (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE,
  description TEXT,
  logo_url TEXT,
  banner_url TEXT,
  phone VARCHAR(20),
  email VARCHAR(255),
  address TEXT,
  city VARCHAR(100),
  is_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  verified_at TIMESTAMPTZ,
  commission_rate DECIMAL(5,2) DEFAULT 10.00,
  balance DECIMAL(12,2) DEFAULT 0.00,
  total_sales DECIMAL(12,2) DEFAULT 0.00,
  total_orders INTEGER DEFAULT 0,
  rating DECIMAL(3,2) DEFAULT 0.00,
  review_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Shops uchun indexlar
CREATE INDEX IF NOT EXISTS idx_shops_owner_id ON shops(owner_id);
CREATE INDEX IF NOT EXISTS idx_shops_slug ON shops(slug);
CREATE INDEX IF NOT EXISTS idx_shops_is_active ON shops(is_active);
CREATE INDEX IF NOT EXISTS idx_shops_is_verified ON shops(is_verified);

-- RLS policies for shops
ALTER TABLE shops ENABLE ROW LEVEL SECURITY;

-- Avval mavjud policylarni o'chirish
DROP POLICY IF EXISTS "Anyone can view active shops" ON shops;
DROP POLICY IF EXISTS "Owners can view own shop" ON shops;
DROP POLICY IF EXISTS "Users can create own shop" ON shops;
DROP POLICY IF EXISTS "Owners can update own shop" ON shops;

-- Har kim ko'ra oladi (active do'konlar)
CREATE POLICY "Anyone can view active shops"
  ON shops FOR SELECT
  USING (is_active = true);

-- Owner o'z do'konini ko'radi
CREATE POLICY "Owners can view own shop"
  ON shops FOR SELECT
  USING (auth.uid() = owner_id);

-- Owner o'z do'konini yaratadi
CREATE POLICY "Users can create own shop"
  ON shops FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

-- Owner o'z do'konini yangilaydi
CREATE POLICY "Owners can update own shop"
  ON shops FOR UPDATE
  USING (auth.uid() = owner_id);

-- 3. shop_payouts jadvali (to'lov so'rovlari)
CREATE TABLE IF NOT EXISTS shop_payouts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
  amount DECIMAL(12,2) NOT NULL,
  status VARCHAR(20) DEFAULT 'pending', -- pending, approved, rejected, completed
  payment_method VARCHAR(50), -- card, cash
  card_number VARCHAR(20),
  card_holder VARCHAR(255),
  note TEXT,
  admin_note TEXT,
  processed_at TIMESTAMPTZ,
  processed_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for payouts
ALTER TABLE shop_payouts ENABLE ROW LEVEL SECURITY;

-- Avval mavjud policylarni o'chirish
DROP POLICY IF EXISTS "Shop owners can view own payouts" ON shop_payouts;
DROP POLICY IF EXISTS "Shop owners can create payouts" ON shop_payouts;

CREATE POLICY "Shop owners can view own payouts"
  ON shop_payouts FOR SELECT
  USING (shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid()));

CREATE POLICY "Shop owners can create payouts"
  ON shop_payouts FOR INSERT
  WITH CHECK (shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid()));

-- 4. shop_commissions jadvali (komissiya tarixi)
CREATE TABLE IF NOT EXISTS shop_commissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
  order_id UUID REFERENCES orders(id),
  order_amount DECIMAL(12,2) NOT NULL,
  commission_rate DECIMAL(5,2) NOT NULL,
  commission_amount DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS for commissions
ALTER TABLE shop_commissions ENABLE ROW LEVEL SECURITY;

-- Avval mavjud policylarni o'chirish
DROP POLICY IF EXISTS "Shop owners can view own commissions" ON shop_commissions;

CREATE POLICY "Shop owners can view own commissions"
  ON shop_commissions FOR SELECT
  USING (shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid()));

-- 5. products jadvaliga shop_id qo'shish (agar yo'q bo'lsa)
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS shop_id UUID REFERENCES shops(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_products_shop_id ON products(shop_id);

-- 6. Function: Do'kon yaratilganda owner role ni vendor qilish
CREATE OR REPLACE FUNCTION update_user_role_to_vendor()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE profiles SET role = 'vendor' WHERE id = NEW.owner_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS shop_created_trigger ON shops;
CREATE TRIGGER shop_created_trigger
  AFTER INSERT ON shops
  FOR EACH ROW
  EXECUTE FUNCTION update_user_role_to_vendor();

-- 7. Function: Buyurtma yakunlanganda do'kon statistikasini yangilash
CREATE OR REPLACE FUNCTION update_shop_stats_on_order()
RETURNS TRIGGER AS $$
DECLARE
  v_shop_id UUID;
  v_commission_rate DECIMAL(5,2);
  v_commission_amount DECIMAL(12,2);
BEGIN
  -- Faqat delivered statusga o'tganda
  IF NEW.status = 'delivered' AND OLD.status != 'delivered' THEN
    -- Order itemlardan shop_id olish
    FOR v_shop_id, v_commission_rate IN
      SELECT DISTINCT p.shop_id, COALESCE(s.commission_rate, 10)
      FROM order_items oi
      JOIN products p ON p.id = oi.product_id
      JOIN shops s ON s.id = p.shop_id
      WHERE oi.order_id = NEW.id AND p.shop_id IS NOT NULL
    LOOP
      -- Shu do'konning buyurtmadagi summasi
      SELECT SUM(oi.quantity * oi.price)
      INTO v_commission_amount
      FROM order_items oi
      JOIN products p ON p.id = oi.product_id
      WHERE oi.order_id = NEW.id AND p.shop_id = v_shop_id;
      
      -- Komissiya hisoblash
      v_commission_amount := v_commission_amount * v_commission_rate / 100;
      
      -- Do'kon statistikasini yangilash
      UPDATE shops SET
        total_orders = total_orders + 1,
        total_sales = total_sales + v_commission_amount,
        balance = balance + (v_commission_amount * (100 - v_commission_rate) / 100)
      WHERE id = v_shop_id;
      
      -- Komissiya tarixiga yozish
      INSERT INTO shop_commissions (shop_id, order_id, order_amount, commission_rate, commission_amount)
      VALUES (v_shop_id, NEW.id, v_commission_amount * 100 / v_commission_rate, v_commission_rate, v_commission_amount);
    END LOOP;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS order_delivered_shop_stats ON orders;
CREATE TRIGGER order_delivered_shop_stats
  AFTER UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION update_shop_stats_on_order();

-- 8. Slug yaratish funksiyasi
CREATE OR REPLACE FUNCTION generate_shop_slug()
RETURNS TRIGGER AS $$
DECLARE
  base_slug TEXT;
  final_slug TEXT;
  counter INTEGER := 0;
BEGIN
  -- Nomdan slug yaratish
  base_slug := lower(regexp_replace(NEW.name, '[^a-zA-Z0-9]', '-', 'g'));
  base_slug := regexp_replace(base_slug, '-+', '-', 'g');
  base_slug := trim(both '-' from base_slug);
  
  final_slug := base_slug;
  
  -- Takrorlanmasin
  WHILE EXISTS (SELECT 1 FROM shops WHERE slug = final_slug AND id != COALESCE(NEW.id, '00000000-0000-0000-0000-000000000000'::uuid)) LOOP
    counter := counter + 1;
    final_slug := base_slug || '-' || counter;
  END LOOP;
  
  NEW.slug := final_slug;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS shop_slug_trigger ON shops;
CREATE TRIGGER shop_slug_trigger
  BEFORE INSERT OR UPDATE OF name ON shops
  FOR EACH ROW
  EXECUTE FUNCTION generate_shop_slug();

-- =====================================================
-- TAYYOR! Endi do'kon ochish ishlaydi
-- =====================================================
