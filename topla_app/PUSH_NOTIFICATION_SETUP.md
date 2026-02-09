# 🔔 Push Notification Sozlash Qo'llanmasi

Admin buyurtma statusini o'zgartirganda foydalanuvchiga push notification yuborish uchun quyidagi qadamlarni bajaring:

## 1️⃣ Firebase Server Key olish

1. [Firebase Console](https://console.firebase.google.com/) ga kiring
2. TOPLA loyihangizni tanlang
3. ⚙️ **Project Settings** > **Cloud Messaging** tabiga o'ting
4. **Cloud Messaging API (Legacy)** bo'limida **Server key** ni ko'chirib oling
   - Agar ko'rinmasa, "Manage API in Google Cloud Console" ni bosib enable qiling

## 2️⃣ Supabase SQL Migration

1. [Supabase Dashboard](https://supabase.com/dashboard) ga kiring
2. Loyihangizni tanlang
3. **SQL Editor** ga o'ting
4. `sql_push_notifications.sql` faylining barcha kodini nusxalab, ishga tushiring

## 3️⃣ Supabase Edge Function Deploy

### Variant A: Supabase CLI orqali (tavsiya etiladi)

```bash
# Supabase CLI o'rnatish (agar yo'q bo'lsa)
npm install -g supabase

# Login
supabase login

# Project ga ulaning
supabase link --project-ref boelyisgkvwwqwjbaxyx

# Edge Function deploy
supabase functions deploy send-push-notification
```

### Variant B: Dashboard orqali

1. Supabase Dashboard > **Edge Functions**
2. **New Function** tugmasini bosing
3. Function nomi: `send-push-notification`
4. `supabase/functions/send-push-notification/index.ts` faylining kodini joylashtiring
5. **Deploy** tugmasini bosing

## 4️⃣ Environment Variables sozlash

Supabase Dashboard > **Settings** > **Edge Functions** > **Function Secrets**:

| Nomi                  | Qiymati                                 |
|-----------------------|-----------------------------------------|
| `FIREBASE_SERVER_KEY` | Firebase Console dan olgan Server key   |

## 5️⃣ Testlash

1. Flutter ilovada biror foydalanuvchi sifatida login bo'ling
2. Buyurtma bering
3. Admin panelga kiring
4. Buyurtma statusini "Tasdiqlangan" ga o'zgartiring
5. Foydalanuvchi telefoniga push notification kelishi kerak! 🎉

## ⚠️ Muhim eslatmalar

- Push notification faqat **Android** da ishlaydi (iOS uchun APNs sozlash kerak)
- Ilova **yopiq** bo'lsa ham notification keladi
- FCM token har safar login bo'lganda bazaga saqlanadi
- Notification tarixini `notifications` jadvalida ko'rish mumkin

## 🐛 Xatoliklarni tuzatish

### "FCM token not found" xatosi

- Foydalanuvchi notification ruxsatini bermagan
- AuthProvider da `NotificationService().initialize()` chaqirilmagan

### Notification kelmayapti

1. Firebase Console da Cloud Messaging API enable ekanligini tekshiring
2. `FIREBASE_SERVER_KEY` to'g'ri sozlanganini tekshiring
3. Edge Function logs ni ko'ring: Supabase Dashboard > Edge Functions > Logs

### "FIREBASE_SERVER_KEY is not set" xatosi

- Supabase Dashboard > Settings > Edge Functions > Function Secrets da key qo'shing
