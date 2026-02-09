-- =====================================================
-- TOPLA APP - Database Reset Script
-- DIQQAT: Bu barcha ma'lumotlarni o'chiradi!
-- =====================================================

-- Avval barcha jadvallarni o'chirish (teskari tartibda)
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS favorites CASCADE;
DROP TABLE IF EXISTS cart_items CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS addresses CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;
DROP TABLE IF EXISTS banners CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

-- Triggerlar va funksiyalarni o'chirish
DROP TRIGGER IF EXISTS update_categories_updated_at ON categories;
DROP TRIGGER IF EXISTS update_products_updated_at ON products;
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
DROP TRIGGER IF EXISTS update_orders_updated_at ON orders;
DROP TRIGGER IF EXISTS set_order_number ON orders;
DROP TRIGGER IF EXISTS set_referral_code ON profiles;
DROP TRIGGER IF EXISTS update_rating_on_review ON reviews;

DROP FUNCTION IF EXISTS update_updated_at();
DROP FUNCTION IF EXISTS generate_order_number();
DROP FUNCTION IF EXISTS generate_referral_code();
DROP FUNCTION IF EXISTS update_product_rating();

SELECT 'All tables dropped! Now run the main schema.' as status;
