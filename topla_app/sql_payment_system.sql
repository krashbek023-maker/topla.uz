-- =====================================================
-- TOPLA APP - To'lov Tizimi Database Schema
-- Asia Alliance Bank integratsiya uchun
-- =====================================================

-- 1. SAVED_CARDS - Saqlangan kartalar (tokenlar)
CREATE TABLE IF NOT EXISTS saved_cards (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    binding_id VARCHAR(100) NOT NULL UNIQUE, -- Bank tomonidan berilgan token
    masked_pan VARCHAR(25) NOT NULL, -- Masalan: 8600 **** **** 1234
    card_type VARCHAR(20) NOT NULL CHECK (card_type IN ('uzcard', 'humo', 'visa', 'mastercard', 'unknown')),
    expiry_date VARCHAR(5) NOT NULL, -- MM/YY
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_saved_cards_user ON saved_cards(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_cards_binding ON saved_cards(binding_id);

-- 2. TRANSACTIONS - To'lov tranzaksiyalari
CREATE TABLE IF NOT EXISTS transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    transaction_id VARCHAR(100) UNIQUE NOT NULL, -- Bank tranzaksiya ID
    amount DECIMAL(15, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'UZS',
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'held', 'completed', 'failed', 'reversed', 'refunded', 'cancelled')),
    provider VARCHAR(50) DEFAULT 'asia_alliance',
    card_type VARCHAR(20),
    masked_pan VARCHAR(25),
    error_message TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_transactions_order ON transactions(order_id);
CREATE INDEX IF NOT EXISTS idx_transactions_status ON transactions(status);
CREATE INDEX IF NOT EXISTS idx_transactions_created ON transactions(created_at);

-- 3. COMMISSION_SETTINGS - Komissiya sozlamalari
CREATE TABLE IF NOT EXISTS commission_settings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
    shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
    rate DECIMAL(5, 2) NOT NULL DEFAULT 10.00, -- Foiz (masalan, 10.00 = 10%)
    min_amount DECIMAL(15, 2) DEFAULT 0,
    max_amount DECIMAL(15, 2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Faqat bittasi bo'lishi mumkin: category YOKI shop
    CONSTRAINT check_one_target CHECK (
        (category_id IS NOT NULL AND shop_id IS NULL) OR
        (category_id IS NULL AND shop_id IS NOT NULL) OR
        (category_id IS NULL AND shop_id IS NULL) -- Default global setting
    )
);

-- 4. VENDOR_TRANSACTIONS - Vendor moliyaviy operatsiyalari
CREATE TABLE IF NOT EXISTS vendor_transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    shop_id UUID REFERENCES shops(id) ON DELETE CASCADE NOT NULL,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    payout_id UUID REFERENCES payouts(id) ON DELETE SET NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('order_income', 'commission', 'payout', 'refund', 'adjustment')),
    amount DECIMAL(15, 2) NOT NULL, -- Musbat = kirim, manfiy = chiqim
    balance_after DECIMAL(15, 2) NOT NULL, -- Operatsiyadan keyingi balans
    description TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vendor_transactions_shop ON vendor_transactions(shop_id);
CREATE INDEX IF NOT EXISTS idx_vendor_transactions_type ON vendor_transactions(type);
CREATE INDEX IF NOT EXISTS idx_vendor_transactions_created ON vendor_transactions(created_at);

-- 5. PAYOUTS jadvalini yangilash (agar allaqachon mavjud bo'lsa)
ALTER TABLE payouts 
ADD COLUMN IF NOT EXISTS commission DECIMAL(15, 2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS net_amount DECIMAL(15, 2),
ADD COLUMN IF NOT EXISTS payment_method VARCHAR(30) DEFAULT 'bank_transfer',
ADD COLUMN IF NOT EXISTS payment_details JSONB,
ADD COLUMN IF NOT EXISTS processed_by UUID REFERENCES auth.users(id),
ADD COLUMN IF NOT EXISTS processed_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS notes TEXT;

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

ALTER TABLE saved_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE commission_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_transactions ENABLE ROW LEVEL SECURITY;

-- Saved Cards policies
CREATE POLICY "Users can view own cards" ON saved_cards 
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own cards" ON saved_cards 
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own cards" ON saved_cards 
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own cards" ON saved_cards 
    FOR DELETE USING (auth.uid() = user_id);

-- Transactions policies (faqat o'z buyurtmalari)
CREATE POLICY "Users can view own transactions" ON transactions 
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM orders 
            WHERE orders.id = transactions.order_id 
            AND orders.user_id = auth.uid()
        )
    );

-- Admin can view all
CREATE POLICY "Admins can view all transactions" ON transactions 
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE profiles.id = auth.uid() 
            AND profiles.role = 'admin'
        )
    );

-- Commission settings (admin only)
CREATE POLICY "Admins can manage commission settings" ON commission_settings 
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE profiles.id = auth.uid() 
            AND profiles.role = 'admin'
        )
    );

-- Vendor transactions (vendor o'z shop'ini ko'ra oladi)
CREATE POLICY "Vendors can view own shop transactions" ON vendor_transactions 
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM shops 
            WHERE shops.id = vendor_transactions.shop_id 
            AND shops.owner_id = auth.uid()
        )
    );

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

-- Buyurtma yakunlanganda vendor balansini yangilash
CREATE OR REPLACE FUNCTION update_vendor_balance_on_order_complete()
RETURNS TRIGGER AS $$
DECLARE
    v_shop_id UUID;
    v_order_total DECIMAL(15, 2);
    v_commission_rate DECIMAL(5, 2);
    v_commission_amount DECIMAL(15, 2);
    v_vendor_amount DECIMAL(15, 2);
    v_current_balance DECIMAL(15, 2);
BEGIN
    -- Faqat 'delivered' statusiga o'zgarganda
    IF NEW.status = 'delivered' AND OLD.status != 'delivered' THEN
        v_shop_id := NEW.shop_id;
        v_order_total := NEW.total;
        
        -- Agar shop_id bo'lsa
        IF v_shop_id IS NOT NULL THEN
            -- Komissiya stavkasini olish (shop'dan yoki default)
            SELECT COALESCE(s.commission_rate, 10.00) INTO v_commission_rate
            FROM shops s WHERE s.id = v_shop_id;
            
            -- Hisoblash
            v_commission_amount := v_order_total * v_commission_rate / 100;
            v_vendor_amount := v_order_total - v_commission_amount;
            
            -- Joriy balansni olish
            SELECT balance INTO v_current_balance 
            FROM shops WHERE id = v_shop_id;
            
            -- Shop balansini yangilash
            UPDATE shops 
            SET balance = balance + v_vendor_amount,
                updated_at = NOW()
            WHERE id = v_shop_id;
            
            -- Vendor transaction yozish (kirim)
            INSERT INTO vendor_transactions (
                shop_id, order_id, type, amount, balance_after, description
            ) VALUES (
                v_shop_id, 
                NEW.id, 
                'order_income', 
                v_vendor_amount,
                v_current_balance + v_vendor_amount,
                'Buyurtma #' || NEW.order_number || ' dan tushum'
            );
            
            -- Komissiya yozish (chiqim sifatida)
            INSERT INTO vendor_transactions (
                shop_id, order_id, type, amount, balance_after, description
            ) VALUES (
                v_shop_id, 
                NEW.id, 
                'commission', 
                -v_commission_amount,
                v_current_balance + v_vendor_amount, -- Balans allaqachon yangilangan
                'Buyurtma #' || NEW.order_number || ' komissiya (' || v_commission_rate || '%)'
            );
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger
DROP TRIGGER IF EXISTS trigger_update_vendor_balance ON orders;
CREATE TRIGGER trigger_update_vendor_balance
    AFTER UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_vendor_balance_on_order_complete();

-- Payout yaratilganda balansdan yechish
CREATE OR REPLACE FUNCTION deduct_balance_on_payout()
RETURNS TRIGGER AS $$
DECLARE
    v_current_balance DECIMAL(15, 2);
BEGIN
    -- Faqat yangi payout yaratilganda
    IF TG_OP = 'INSERT' THEN
        -- Joriy balansni tekshirish
        SELECT balance INTO v_current_balance 
        FROM shops WHERE id = NEW.shop_id;
        
        -- Balans yetarlimi?
        IF v_current_balance < NEW.amount THEN
            RAISE EXCEPTION 'Balans yetarli emas. Mavjud: %, So''ralgan: %', v_current_balance, NEW.amount;
        END IF;
        
        -- Net amount hisoblash (agar berilmagan bo'lsa)
        IF NEW.net_amount IS NULL THEN
            NEW.net_amount := NEW.amount - COALESCE(NEW.commission, 0);
        END IF;
    END IF;
    
    -- Payout 'completed' bo'lganda balansdan yechish
    IF TG_OP = 'UPDATE' AND NEW.status = 'completed' AND OLD.status != 'completed' THEN
        -- Balansdan yechish
        UPDATE shops 
        SET balance = balance - NEW.amount,
            updated_at = NOW()
        WHERE id = NEW.shop_id;
        
        -- Joriy balansni olish
        SELECT balance INTO v_current_balance 
        FROM shops WHERE id = NEW.shop_id;
        
        -- Vendor transaction yozish
        INSERT INTO vendor_transactions (
            shop_id, payout_id, type, amount, balance_after, description
        ) VALUES (
            NEW.shop_id, 
            NEW.id, 
            'payout', 
            -NEW.amount,
            v_current_balance,
            'Pul yechish #' || NEW.id::text
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger
DROP TRIGGER IF EXISTS trigger_deduct_balance_on_payout ON payouts;
CREATE TRIGGER trigger_deduct_balance_on_payout
    BEFORE INSERT OR UPDATE ON payouts
    FOR EACH ROW
    EXECUTE FUNCTION deduct_balance_on_payout();

-- =====================================================
-- DEFAULT DATA
-- =====================================================

-- Default global komissiya (10%)
INSERT INTO commission_settings (rate, is_active)
VALUES (10.00, true)
ON CONFLICT DO NOTHING;

-- =====================================================
-- HELPER VIEWS
-- =====================================================

-- Vendor balans va statistika
CREATE OR REPLACE VIEW vendor_balance_summary AS
SELECT 
    s.id AS shop_id,
    s.name AS shop_name,
    s.owner_id,
    s.balance AS current_balance,
    COALESCE(SUM(CASE WHEN vt.type = 'order_income' THEN vt.amount ELSE 0 END), 0) AS total_income,
    COALESCE(SUM(CASE WHEN vt.type = 'commission' THEN ABS(vt.amount) ELSE 0 END), 0) AS total_commission,
    COALESCE(SUM(CASE WHEN vt.type = 'payout' THEN ABS(vt.amount) ELSE 0 END), 0) AS total_payouts,
    COUNT(DISTINCT CASE WHEN vt.type = 'order_income' THEN vt.order_id END) AS total_orders
FROM shops s
LEFT JOIN vendor_transactions vt ON s.id = vt.shop_id
GROUP BY s.id, s.name, s.owner_id, s.balance;

-- Bugungi tranzaksiyalar statistikasi (admin uchun)
CREATE OR REPLACE VIEW daily_transaction_stats AS
SELECT 
    DATE(created_at) AS date,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS successful,
    SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) AS failed,
    SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END) AS total_amount,
    AVG(CASE WHEN status = 'completed' THEN amount END) AS avg_amount
FROM transactions
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;
