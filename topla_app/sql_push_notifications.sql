-- =====================================================
-- PUSH NOTIFICATIONS UCHUN SQL MIGRATION
-- Supabase Dashboard > SQL Editor da ishga tushiring
-- =====================================================

-- 1. profiles jadvaliga fcm_token ustuni qo'shish
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- 2. notifications jadvali (tarix uchun)
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT DEFAULT 'order', -- order, promo, system
  data JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS policies for notifications
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);

-- 3. Function: Buyurtma statusini yangilaganda notification yaratish
CREATE OR REPLACE FUNCTION create_order_notification()
RETURNS TRIGGER AS $$
DECLARE
  order_number TEXT;
  notification_title TEXT;
  notification_body TEXT;
BEGIN
  -- Faqat status o'zgarganda
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    -- Buyurtma raqamini olish
    order_number := NEW.order_number;
    
    -- Status bo'yicha xabar
    CASE NEW.status
      WHEN 'confirmed' THEN
        notification_title := 'Buyurtma tasdiqlandi ✅';
        notification_body := 'Sizning #' || order_number || ' raqamli buyurtmangiz tasdiqlandi.';
      WHEN 'processing' THEN
        notification_title := 'Buyurtma tayyorlanmoqda 📦';
        notification_body := '#' || order_number || ' raqamli buyurtmangiz tayyorlanmoqda.';
      WHEN 'shipping' THEN
        notification_title := 'Buyurtma yo''lda 🚚';
        notification_body := '#' || order_number || ' raqamli buyurtmangiz yetkazib berilmoqda.';
      WHEN 'delivered' THEN
        notification_title := 'Buyurtma yetkazildi 🎉';
        notification_body := '#' || order_number || ' raqamli buyurtmangiz muvaffaqiyatli yetkazildi.';
      WHEN 'cancelled' THEN
        notification_title := 'Buyurtma bekor qilindi ❌';
        notification_body := '#' || order_number || ' raqamli buyurtmangiz bekor qilindi.';
      ELSE
        RETURN NEW;
    END CASE;
    
    -- Notification yaratish
    INSERT INTO notifications (user_id, title, body, type, data)
    VALUES (
      NEW.user_id,
      notification_title,
      notification_body,
      'order',
      jsonb_build_object(
        'order_id', NEW.id,
        'order_number', order_number,
        'status', NEW.status
      )
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger yaratish
DROP TRIGGER IF EXISTS order_status_notification_trigger ON orders;
CREATE TRIGGER order_status_notification_trigger
  AFTER UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION create_order_notification();

-- =====================================================
-- MUHIM: Supabase Edge Function yaratish kerak
-- Push notification yuborish uchun quyidagi Edge Function ni 
-- Supabase Dashboard > Edge Functions da yarating
-- =====================================================

/*
Edge Function nomi: send-push-notification

Kodni quyida berilgan send-push-notification.ts faylidan oling.

Environment variables (Supabase Dashboard > Settings > Edge Functions):
- FIREBASE_SERVER_KEY: Firebase Console > Project Settings > Cloud Messaging > Server key
*/
