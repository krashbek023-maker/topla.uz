-- =====================================================
-- TOPLA.APP - Qo'shimcha jadvallar (Addresses & Promo Codes)
-- =====================================================

-- ==================== ADDRESSES ====================
-- Foydalanuvchi manzillari

CREATE TABLE IF NOT EXISTS public.addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(50) NOT NULL DEFAULT 'Uy',
    address TEXT NOT NULL,
    apartment VARCHAR(20),
    entrance VARCHAR(20),
    floor VARCHAR(20),
    intercom VARCHAR(50),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_addresses_user_id ON public.addresses(user_id);
CREATE INDEX IF NOT EXISTS idx_addresses_is_default ON public.addresses(is_default);

-- RLS policies for addresses
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;

-- Users can view their own addresses
CREATE POLICY "Users can view own addresses" ON public.addresses
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own addresses
CREATE POLICY "Users can insert own addresses" ON public.addresses
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own addresses
CREATE POLICY "Users can update own addresses" ON public.addresses
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own addresses
CREATE POLICY "Users can delete own addresses" ON public.addresses
    FOR DELETE USING (auth.uid() = user_id);

-- ==================== PROMO CODES ====================
-- Promokodlar

CREATE TABLE IF NOT EXISTS public.promo_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE,
    discount_type VARCHAR(20) NOT NULL DEFAULT 'percent', -- 'percent' or 'fixed'
    discount_value DECIMAL(10, 2) NOT NULL,
    min_order_amount DECIMAL(10, 2),
    max_discount DECIMAL(10, 2),
    usage_limit INTEGER,
    usage_count INTEGER DEFAULT 0,
    per_user_limit INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    starts_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for promo codes
CREATE INDEX IF NOT EXISTS idx_promo_codes_code ON public.promo_codes(code);
CREATE INDEX IF NOT EXISTS idx_promo_codes_is_active ON public.promo_codes(is_active);

-- Promo code usage tracking
CREATE TABLE IF NOT EXISTS public.promo_code_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    promo_code_id UUID NOT NULL REFERENCES public.promo_codes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
    used_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for promo code usage
CREATE INDEX IF NOT EXISTS idx_promo_usage_user ON public.promo_code_usage(user_id);
CREATE INDEX IF NOT EXISTS idx_promo_usage_promo ON public.promo_code_usage(promo_code_id);

-- RLS policies for promo codes
ALTER TABLE public.promo_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.promo_code_usage ENABLE ROW LEVEL SECURITY;

-- Everyone can view active promo codes
CREATE POLICY "Public can view active promo codes" ON public.promo_codes
    FOR SELECT USING (is_active = true);

-- Only admins can manage promo codes
CREATE POLICY "Admins can manage promo codes" ON public.promo_codes
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role IN ('admin', 'super_admin')
        )
    );

-- Users can view their own promo code usage
CREATE POLICY "Users can view own promo usage" ON public.promo_code_usage
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own promo code usage
CREATE POLICY "Users can insert promo usage" ON public.promo_code_usage
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ==================== FUNCTION: Increment promo usage ====================
CREATE OR REPLACE FUNCTION public.increment_promo_usage(promo_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.promo_codes
    SET usage_count = COALESCE(usage_count, 0) + 1,
        updated_at = NOW()
    WHERE id = promo_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==================== SAMPLE PROMO CODES ====================
INSERT INTO public.promo_codes (code, discount_type, discount_value, min_order_amount, max_discount, usage_limit, per_user_limit, expires_at)
VALUES 
    ('TOPLA10', 'percent', 10, 50000, 50000, 1000, 3, NOW() + INTERVAL '1 year'),
    ('YANGI2024', 'percent', 15, 100000, 100000, 500, 1, NOW() + INTERVAL '6 months'),
    ('BEPUL20', 'fixed', 20000, 80000, NULL, 200, 1, NOW() + INTERVAL '3 months')
ON CONFLICT (code) DO NOTHING;

-- ==================== UPDATE: Add address_id to orders ====================
-- Make sure orders table has address_id column
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'orders' AND column_name = 'address_id'
    ) THEN
        ALTER TABLE public.orders ADD COLUMN address_id UUID REFERENCES public.addresses(id);
    END IF;
END $$;
