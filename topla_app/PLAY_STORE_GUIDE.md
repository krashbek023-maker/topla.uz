# 🚀 Play Store Nashr Qilish Qo'llanmasi

Bu qo'llanma TOPLA ilovasini Google Play Store'ga chiqarish uchun bosqichma-bosqich ko'rsatmalar beradi.

---

## 📋 Nashr Oldidan Tekshirish Ro'yxati

### ✅ Kod Tayyorligi

- [x] Release signing konfiguratsiyasi
- [x] ProGuard/R8 qoidalari
- [x] Debug loglar olib tashlangan
- [x] Test ma'lumotlari olib tashlangan
- [x] Versiya raqami yangilangan (1.0.0+1)

### ✅ Huquqiy Hujjatlar

- [x] Privacy Policy ([https://topla.uz/privacy](https://topla.uz/privacy))
- [x] Terms of Service ([https://topla.uz/terms](https://topla.uz/terms))
- [x] Ilova ichidagi huquqiy sahifalar

### ✅ Hujjatlar

- [x] README.md
- [x] Play Store listing matnlari
- [x] Data Safety dokumentatsiyasi

---

## 🔐 1-BOSQICH: Keystore Yaratish

### Keystore generatsiya qilish

```bash
# Keystore yaratish (faqat bir marta)
keytool -genkey -v -keystore topla-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias topla

# Keyin so'raladigan ma'lumotlarni kiriting:
# - Keystore password (xavfsiz parol)
# - Ism familiya
# - Tashkilot
# - Shahar, Viloyat, Davlat kodi (UZ)
```

### key.properties faylini yaratish

```properties
storePassword=SIZNING_STORE_PAROLINGIZ
keyPassword=SIZNING_KEY_PAROLINGIZ
keyAlias=topla
storeFile=../topla-release-key.jks
```

> ⚠️ **MUHIM**: key.properties va .jks fayllarini Git'ga QOSHMA! Ular allaqachon .gitignore'da.

---

## 📦 2-BOSQICH: Release APK/AAB Yaratish

### App Bundle (tavsiya etiladi)

```bash
cd topla_app
flutter build appbundle --release
```

Natija: `build/app/outputs/bundle/release/app-release.aab`

### APK (agar kerak bo'lsa)

```bash
flutter build apk --release --split-per-abi
```

Natija: `build/app/outputs/flutter-apk/` papkasida

---

## 🌐 3-BOSQICH: Google Play Console

### 3.1. Developer Hisobi Ochish

1. [https://play.google.com/console](https://play.google.com/console) ga boring
2. $25 bir martalik to'lov qiling
3. Developer hisobini yarating

### 3.2. Yangi Ilova Yaratish

1. **"Create app"** tugmasini bosing
2. Ma'lumotlarni kiriting:
   - **App name:** TOPLA
   - **Default language:** O'zbekcha (uz)
   - **App or game:** App
   - **Free or paid:** Free

### 3.3. Store Listing

**Main store listing:**

| Maydon | Qiymat |
| :--- | :--- |
| App name | TOPLA |
| Short description | TOPLA - Tez va qulay onlayn xarid. Minglab mahsulotlar, tez yetkazib berish! 🛒 |
| Full description | PLAY_STORE_LISTING.md'dan nusxalang |

**Graphics:**

| Asset | O'lcham | Format |
| :--- | :--- | :--- |
| App icon | 512x512 | PNG (32-bit, alpha) |
| Feature graphic | 1024x500 | PNG/JPG |
| Phone screenshots | 1080x1920 (min 2) | PNG/JPG |
| Tablet screenshots | 1920x1200 (ixtiyoriy) | PNG/JPG |

### 3.4. App Content

#### Privacy Policy

- URL: `https://topla.uz/privacy`

#### Ads

- Ilova reklamasiz

#### App Access

- Test login ma'lumotlarini qo'shing:
  - Phone: +998 90 000 00 00
  - OTP: 123456 (test mode uchun)

#### Content Rating

- Content rating questionnaire'ni to'ldiring
- PLAY_STORE_DATA_SAFETY.md'dagi javoblardan foydalaning

#### Target Audience

- 18 yosh va undan kattalar
- Bolalarga mo'ljallanmagan

#### Data Safety

- PLAY_STORE_DATA_SAFETY.md dokumentidan foydalaning

---

## 🧪 4-BOSQICH: Testing

### 4.1. Internal Testing (1-kun)

1. **Testing → Internal testing** ga boring
2. Testerlar qo'shing (email orqali)
3. AAB faylini yuklang
4. Review 1-2 kun

### 4.2. Closed Testing (1 hafta)

1. **Testing → Closed testing** ga boring
2. "Manage track" → testerlar qo'shing
3. Feedback yig'ing
4. Xatolarni tuzating

### 4.3. Open Testing (ixtiyoriy)

1. Kattaroq auditoriyaga oching
2. 1000+ foydalanuvchi
3. Stability monitoring

---

## 🚀 5-BOSQICH: Production Release

### 5.1. Release Notes

```text
🎉 TOPLA 1.0.0

Birinchi versiya!

✨ Asosiy funksiyalar:
• Minglab mahsulotlarni ko'ring
• Qulay kategoriyalar
• Tez qidiruv
• Savat va buyurtma berish
• Onlayn to'lov (Click, Payme)
• Yetkazib berish kuzatuvi

🔒 Xavfsizlik:
• Biometrik kirish
• Xavfsiz to'lov

📞 Qo'llab-quvvatlash: support@topla.uz
```

### 5.2. Rollout Strategy

1. **Staged rollout** tanlang
2. 10% dan boshlang
3. Crash rate kuzating
4. 3-5 kun ichida 100% ga ko'taring

---

## 📊 6-BOSQICH: Post-Launch

### Monitoring

- **Firebase Crashlytics:** Crash'larni kuzating
- **Firebase Analytics:** Foydalanish statistikasi
- **Play Console:** ANR, crash rate, reviews

### Review Javoblari

Barcha reviewlarga javob bering:

- 1-2 yulduz: Muammoni so'rang, hal qiling
- 3-4 yulduz: Rahmat ayting, takomillashtirish haqida so'rang
- 5 yulduz: Rahmat ayting!

### Updates

- Minor fixes: har hafta
- Feature updates: har oy
- Major versions: har 3 oy

---

## 🆘 Umumiy Muammolar

### 1. Upload xatosi

```text
Error: The Android App Bundle was not signed
```

**Yechim:** key.properties to'g'ri konfiguratsiya qiling va qayta build qiling.

### 2. Versiya konflikti

```text
Error: Version code already exists
```

**Yechim:** pubspec.yaml'da build number'ni oshiring (1.0.0+2)

### 3. Target SDK warning

```text
Warning: Your app targets API level 33
```

**Yechim:** build.gradle'da targetSdk ni 34 qiling.

### 4. 64-bit requirement

```text
Error: This release is not compliant with the Google Play 64-bit requirement
```

**Yechim:** Flutter avtomatik 64-bit support qiladi, `--split-per-abi` bilan build qiling.

---

## 📞 Yordam

- **Google Play Developer Support:** [https://support.google.com/googleplay/android-developer/](https://support.google.com/googleplay/android-developer/)
- **Flutter Documentation:** [https://docs.flutter.dev/deployment/android](https://docs.flutter.dev/deployment/android)
- **TOPLA Support:** [playstore@topla.uz](mailto:playstore@topla.uz)
