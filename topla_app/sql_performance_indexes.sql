-- =====================================================
-- TOPLA APP - DATABASE INDEXES
-- Performance optimizatsiyasi uchun index'lar
-- =====================================================

-- ==============================
-- PRODUCTS TABLE INDEXES
-- ==============================

-- Kategoriya bo'yicha tez qidiruv
CREATE INDEX IF NOT EXISTS idx_products_category_id 
ON products(category_id);

-- Do'kon bo'yicha tez qidiruv
CREATE INDEX IF NOT EXISTS idx_products_shop_id 
ON products(shop_id);

-- Brend bo'yicha tez qidiruv
CREATE INDEX IF NOT EXISTS idx_products_brand_id 
ON products(brand_id);

-- Faol mahsulotlar filtri
CREATE INDEX IF NOT EXISTS idx_products_is_active 
ON products(is_active);

-- Flash sale mahsulotlar
CREATE INDEX IF NOT EXISTS idx_products_flash_sale 
ON products(is_flash_sale) WHERE is_flash_sale = true;

-- Featured mahsulotlar
CREATE INDEX IF NOT EXISTS idx_products_featured 
ON products(is_featured) WHERE is_featured = true;

-- Narx bo'yicha saralash (tez range query)
CREATE INDEX IF NOT EXISTS idx_products_price 
ON products(price);

-- Reyting bo'yicha saralash
CREATE INDEX IF NOT EXISTS idx_products_rating 
ON products(rating DESC);

-- Sotilgan soni bo'yicha saralash
CREATE INDEX IF NOT EXISTS idx_products_sold_count 
ON products(sold_count DESC);

-- Yaratilgan vaqt bo'yicha saralash (eng yangi)
CREATE INDEX IF NOT EXISTS idx_products_created_at 
ON products(created_at DESC);

-- Qidiruv uchun GIN index (FTS)
CREATE INDEX IF NOT EXISTS idx_products_search 
ON products USING gin(to_tsvector('simple', name_uz || ' ' || COALESCE(name_ru, '')));

-- Composite index: Kategoriya + Faol + Narx (eng ko'p ishlatiladigan filter kombinatsiyasi)
CREATE INDEX IF NOT EXISTS idx_products_category_active_price 
ON products(category_id, is_active, price);

-- ==============================
-- CATEGORIES TABLE INDEXES
-- ==============================

-- Parent kategoriya bo'yicha
CREATE INDEX IF NOT EXISTS idx_categories_parent_id 
ON categories(parent_id);

-- Faol kategoriyalar
CREATE INDEX IF NOT EXISTS idx_categories_is_active 
ON categories(is_active);

-- Saralash tartibi
CREATE INDEX IF NOT EXISTS idx_categories_sort_order 
ON categories(sort_order);

-- ==============================
-- ORDERS TABLE INDEXES
-- ==============================

-- Foydalanuvchi buyurtmalari
CREATE INDEX IF NOT EXISTS idx_orders_user_id 
ON orders(user_id);

-- Buyurtma holati
CREATE INDEX IF NOT EXISTS idx_orders_status 
ON orders(status);

-- Buyurtma sanasi
CREATE INDEX IF NOT EXISTS idx_orders_created_at 
ON orders(created_at DESC);

-- Foydalanuvchi + Holat (profil sahifasida filter)
CREATE INDEX IF NOT EXISTS idx_orders_user_status 
ON orders(user_id, status);

-- ==============================
-- ORDER_ITEMS TABLE INDEXES
-- ==============================

-- Buyurtma bo'yicha itemlar
CREATE INDEX IF NOT EXISTS idx_order_items_order_id 
ON order_items(order_id);

-- Mahsulot bo'yicha (statistika uchun)
CREATE INDEX IF NOT EXISTS idx_order_items_product_id 
ON order_items(product_id);

-- ==============================
-- CART_ITEMS TABLE INDEXES
-- ==============================

-- Foydalanuvchi savati
CREATE INDEX IF NOT EXISTS idx_cart_items_user_id 
ON cart_items(user_id);

-- Mahsulot bo'yicha (stock tekshiruv uchun)
CREATE INDEX IF NOT EXISTS idx_cart_items_product_id 
ON cart_items(product_id);

-- Foydalanuvchi + Mahsulot (unique constraint)
CREATE UNIQUE INDEX IF NOT EXISTS idx_cart_items_user_product 
ON cart_items(user_id, product_id);

-- ==============================
-- FAVORITES TABLE INDEXES
-- ==============================

-- Foydalanuvchi sevimlilar
CREATE INDEX IF NOT EXISTS idx_favorites_user_id 
ON favorites(user_id);

-- Foydalanuvchi + Mahsulot (unique constraint)
CREATE UNIQUE INDEX IF NOT EXISTS idx_favorites_user_product 
ON favorites(user_id, product_id);

-- ==============================
-- REVIEWS TABLE INDEXES
-- ==============================

-- Mahsulot sharhlari
CREATE INDEX IF NOT EXISTS idx_reviews_product_id 
ON reviews(product_id);

-- Foydalanuvchi sharhlari
CREATE INDEX IF NOT EXISTS idx_reviews_user_id 
ON reviews(user_id);

-- Reyting bo'yicha filter
CREATE INDEX IF NOT EXISTS idx_reviews_rating 
ON reviews(rating);

-- ==============================
-- ADDRESSES TABLE INDEXES
-- ==============================

-- Foydalanuvchi manzillari
CREATE INDEX IF NOT EXISTS idx_addresses_user_id 
ON addresses(user_id);

-- Asosiy manzil
CREATE INDEX IF NOT EXISTS idx_addresses_is_default 
ON addresses(user_id, is_default) WHERE is_default = true;

-- ==============================
-- PROFILES TABLE INDEXES
-- ==============================

-- Telefon raqami bo'yicha (login uchun)
CREATE INDEX IF NOT EXISTS idx_profiles_phone 
ON profiles(phone);

-- Email bo'yicha (login uchun)
CREATE INDEX IF NOT EXISTS idx_profiles_email 
ON profiles(email);

-- Referral kod
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_referral_code 
ON profiles(referral_code) WHERE referral_code IS NOT NULL;

-- ==============================
-- SHOPS TABLE INDEXES
-- ==============================

-- Do'kon egasi
CREATE INDEX IF NOT EXISTS idx_shops_owner_id 
ON shops(owner_id);

-- Faol do'konlar
CREATE INDEX IF NOT EXISTS idx_shops_is_active 
ON shops(is_active);

-- Do'kon nomi bo'yicha qidiruv
CREATE INDEX IF NOT EXISTS idx_shops_name 
ON shops USING gin(to_tsvector('simple', name));

-- ==============================
-- BANNERS TABLE INDEXES
-- ==============================

-- Faol bannerlar
CREATE INDEX IF NOT EXISTS idx_banners_is_active 
ON banners(is_active);

-- Saralash tartibi
CREATE INDEX IF NOT EXISTS idx_banners_sort_order 
ON banners(sort_order);

-- Muddatli bannerlar
CREATE INDEX IF NOT EXISTS idx_banners_dates 
ON banners(start_date, end_date);

-- ==============================
-- ANALYZE (statistika yangilash)
-- ==============================

ANALYZE products;
ANALYZE categories;
ANALYZE orders;
ANALYZE order_items;
ANALYZE cart_items;
ANALYZE favorites;
ANALYZE reviews;
ANALYZE addresses;
ANALYZE profiles;

-- =====================================================
-- ESLATMA: 
-- Bu index'larni production bazaga qo'shishdan oldin
-- staging muhitda test qiling!
-- 
-- Index'lar disk hajmini oshiradi lekin query tezligini 
-- sezilarli darajada oshiradi.
-- =====================================================
