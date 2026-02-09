-- =====================================================
-- TOPLA APP - DO'KON SOCIAL TIZIMLARI
-- Obuna, sharhlar, xabarlar
-- =====================================================

-- 1. DO'KON OBUNACHILARI (Followers)
-- =====================================================
CREATE TABLE IF NOT EXISTS shop_followers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, shop_id)
);

-- Shops jadvaliga followers_count qo'shish
ALTER TABLE shops ADD COLUMN IF NOT EXISTS followers_count INTEGER DEFAULT 0;

-- Followers count ni avtomatik yangilash uchun trigger
CREATE OR REPLACE FUNCTION update_shop_followers_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE shops SET followers_count = followers_count + 1 WHERE id = NEW.shop_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE shops SET followers_count = followers_count - 1 WHERE id = OLD.shop_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_shop_followers_count ON shop_followers;
CREATE TRIGGER trigger_shop_followers_count
    AFTER INSERT OR DELETE ON shop_followers
    FOR EACH ROW EXECUTE FUNCTION update_shop_followers_count();

-- RLS
ALTER TABLE shop_followers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all followers" ON shop_followers
    FOR SELECT USING (true);

CREATE POLICY "Users can follow shops" ON shop_followers
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unfollow shops" ON shop_followers
    FOR DELETE USING (auth.uid() = user_id);

-- Index
CREATE INDEX IF NOT EXISTS idx_shop_followers_user ON shop_followers(user_id);
CREATE INDEX IF NOT EXISTS idx_shop_followers_shop ON shop_followers(shop_id);

-- =====================================================
-- 2. DO'KON SHARHLARI (Reviews)
-- =====================================================
CREATE TABLE IF NOT EXISTS shop_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    images TEXT[], -- Rasm URL lari
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, shop_id, order_id)
);

-- Shop ratingni yangilash triggeri
CREATE OR REPLACE FUNCTION update_shop_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE shops 
    SET 
        rating = (SELECT COALESCE(AVG(rating), 0) FROM shop_reviews WHERE shop_id = NEW.shop_id),
        review_count = (SELECT COUNT(*) FROM shop_reviews WHERE shop_id = NEW.shop_id),
        updated_at = NOW()
    WHERE id = NEW.shop_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_shop_rating ON shop_reviews;
CREATE TRIGGER trigger_shop_rating
    AFTER INSERT OR UPDATE OR DELETE ON shop_reviews
    FOR EACH ROW EXECUTE FUNCTION update_shop_rating();

-- RLS
ALTER TABLE shop_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view reviews" ON shop_reviews
    FOR SELECT USING (true);

CREATE POLICY "Users can create reviews" ON shop_reviews
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reviews" ON shop_reviews
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own reviews" ON shop_reviews
    FOR DELETE USING (auth.uid() = user_id);

-- Index
CREATE INDEX IF NOT EXISTS idx_shop_reviews_shop ON shop_reviews(shop_id);
CREATE INDEX IF NOT EXISTS idx_shop_reviews_user ON shop_reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_shop_reviews_rating ON shop_reviews(rating);

-- =====================================================
-- 3. DO'KON XABARLARI (Chat)
-- =====================================================
CREATE TABLE IF NOT EXISTS shop_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    last_message TEXT,
    last_message_at TIMESTAMPTZ,
    user_unread_count INTEGER DEFAULT 0,
    shop_unread_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(shop_id, user_id)
);

CREATE TABLE IF NOT EXISTS shop_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES shop_conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    sender_type VARCHAR(10) NOT NULL CHECK (sender_type IN ('user', 'shop')),
    message TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'product', 'order')),
    attachment_url TEXT,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Last message yangilash triggeri
CREATE OR REPLACE FUNCTION update_conversation_last_message()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE shop_conversations 
    SET 
        last_message = NEW.message,
        last_message_at = NEW.created_at,
        updated_at = NOW(),
        user_unread_count = CASE 
            WHEN NEW.sender_type = 'shop' THEN user_unread_count + 1 
            ELSE user_unread_count 
        END,
        shop_unread_count = CASE 
            WHEN NEW.sender_type = 'user' THEN shop_unread_count + 1 
            ELSE shop_unread_count 
        END
    WHERE id = NEW.conversation_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_conversation_last_message ON shop_messages;
CREATE TRIGGER trigger_conversation_last_message
    AFTER INSERT ON shop_messages
    FOR EACH ROW EXECUTE FUNCTION update_conversation_last_message();

-- RLS
ALTER TABLE shop_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE shop_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own conversations" ON shop_conversations
    FOR SELECT USING (
        auth.uid() = user_id OR 
        auth.uid() IN (SELECT owner_id FROM shops WHERE id = shop_id)
    );

CREATE POLICY "Users can create conversations" ON shop_conversations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own messages" ON shop_messages
    FOR SELECT USING (
        conversation_id IN (
            SELECT id FROM shop_conversations 
            WHERE user_id = auth.uid() OR 
                  shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
        )
    );

CREATE POLICY "Users can send messages" ON shop_messages
    FOR INSERT WITH CHECK (
        sender_id = auth.uid() AND
        conversation_id IN (
            SELECT id FROM shop_conversations 
            WHERE user_id = auth.uid() OR 
                  shop_id IN (SELECT id FROM shops WHERE owner_id = auth.uid())
        )
    );

-- Index
CREATE INDEX IF NOT EXISTS idx_conversations_user ON shop_conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_conversations_shop ON shop_conversations(shop_id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON shop_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_created ON shop_messages(created_at DESC);

-- =====================================================
-- 4. FOYDALI FUNKSIYALAR
-- =====================================================

-- Foydalanuvchi obuna bo'lgan do'konlar
CREATE OR REPLACE FUNCTION get_user_followed_shops(p_user_id UUID)
RETURNS SETOF shops AS $$
BEGIN
    RETURN QUERY
    SELECT s.* FROM shops s
    INNER JOIN shop_followers sf ON s.id = sf.shop_id
    WHERE sf.user_id = p_user_id AND s.is_active = true
    ORDER BY sf.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Top do'konlar (followers bo'yicha)
CREATE OR REPLACE FUNCTION get_top_shops(p_limit INTEGER DEFAULT 10)
RETURNS SETOF shops AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM shops 
    WHERE is_active = true
    ORDER BY followers_count DESC, rating DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Do'kon statistikasi
CREATE OR REPLACE FUNCTION get_shop_stats(p_shop_id UUID)
RETURNS TABLE (
    total_products BIGINT,
    total_orders BIGINT,
    total_reviews BIGINT,
    avg_rating NUMERIC,
    followers_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (SELECT COUNT(*) FROM products WHERE shop_id = p_shop_id AND is_active = true),
        (SELECT COUNT(*) FROM order_items oi 
         INNER JOIN products p ON oi.product_id = p.id 
         WHERE p.shop_id = p_shop_id),
        (SELECT COUNT(*) FROM shop_reviews WHERE shop_id = p_shop_id),
        (SELECT COALESCE(AVG(rating), 0) FROM shop_reviews WHERE shop_id = p_shop_id),
        (SELECT s.followers_count FROM shops s WHERE s.id = p_shop_id);
END;
$$ LANGUAGE plpgsql;
