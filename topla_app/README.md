# 🛒 TOPLA - O'zbekistondagi Zamonaviy E-commerce Ilovasi

![TOPLA Logo](assets/icon/app_icon.png)

> Flutter yordamida yaratilgan zamonaviy marketplace ilovasi

---

## Haqida

TOPLA - O'zbekistonda mahsulotlarni onlayn sotib olish va yetkazib berish uchun zamonaviy mobil ilova. Temu, Uzum, AliExpress kabi ilovalardan ilhomlangan holda, eng yaxshi UX amaliyotlari bilan yaratilgan.

## Xususiyatlar

### Xaridorlar uchun

- **Mahsulotlarni ko'rish** - Kategoriyalar, qidiruv, filtrlar
- **Flash Sale** - Vaqt cheklangan chegirmalar
- **Sevimlilar** - Mahsulotlarni saqlash
- **Savat** - Swipe to delete, miqdorni o'zgartirish
- **Buyurtma berish** - Bir necha bosqichli checkout
- **Manzillar** - GPS orqali avtomatik aniqlash
- **To'lov** - Naqd pul, Click, Payme, bank karta
- **Buyurtma kuzatish** - Real-time status

### Xavfsizlik

- **Biometrik kirish** - Face ID / Touch ID
- **SMS OTP** - Telefon raqamni tasdiqlash
- **Google Sign-In** - Tezkor kirish
- **Secure Storage** - Shifrlangan ma'lumotlar

### Zamonaviy UI/UX

- **Glassmorphism** dizayn
- **Shimmer loading** - Skeleton placeholder
- **Haptic feedback** - Taktil tebranishlar
- **Micro-animations** - Silliq animatsiyalar
- **Pull-to-refresh** - Yangilash
- **Empty states** - Lottie animatsiyalar

### Multivendor

- Vendor paneli (web)
- Admin paneli (web)
- Do'kon ochish imkoniyati

## O'rnatish

### Talablar

- Flutter SDK: ^3.6.1
- Dart: ^3.6.1
- Android Studio / VS Code
- Xcode (iOS uchun)

### 1. Repo ni clone qiling

```bash
git clone https://github.com/username/topla-app.git
cd topla-app
```

### 2. Dependencies ni o'rnating

```bash
flutter pub get
```

### 3. Environment sozlang

```bash
# Build qilishda environment variable lar:
flutter run --dart-define=ENV=dev
```

### 4. Ilovani ishga tushiring

```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## Arxitektura

```text
lib/
├── main.dart                 # Entry point
├── firebase_options.dart     # Firebase config
├── core/
│   ├── constants/           # App constants, colors, sizes
│   ├── localization/        # O'zbek/Rus tillari
│   ├── guards/              # Auth guards
│   └── utils/               # Utility functions
├── data/
│   └── repositories/        # Repository implementations
├── features/
│   ├── auth/               # Kirish ekrani
│   ├── home/               # Bosh sahifa
│   ├── catalog/            # Kategoriyalar
│   ├── product/            # Mahsulot details
│   ├── cart/               # Savat
│   ├── checkout/           # Buyurtma berish
│   ├── orders/             # Buyurtmalar
│   ├── favorites/          # Sevimlilar
│   ├── profile/            # Profil
│   └── ...
├── models/                  # Data models
├── providers/               # State management
├── services/                # API services
└── widgets/                 # Reusable widgets
```

### State Management

- **Provider** - Asosiy state management
- **GetIt** - Dependency Injection

### Arxitektura Pattern

- **Repository Pattern** - Data layer abstraction
- **Service Layer** - Business logic
- **Feature-based structure** - Modular code

## Texnologiyalar

| Kategoriya | Texnologiya |
| :--- | :--- |
| Framework | Flutter 3.6.1 |
| Backend | Node.js API (Fastify + Prisma) |
| Auth | Firebase Auth, OTP (Telegram/SMS) |
| Push Notifications | Firebase Messaging |
| State | Provider + GetIt |
| Navigation | go_router |
| Storage | flutter_secure_storage |
| Maps | flutter_map, geolocator |
| Animations | Lottie, shimmer |
| Icons | Iconsax, Phosphor |

## Asosiy Packages

```yaml
dependencies:
  firebase_core: ^4.4.0
  firebase_auth: ^6.1.4
  firebase_messaging: ^16.1.1
  provider: ^6.1.5
  go_router: ^16.1.0
  flutter_secure_storage: ^10.0.0
  local_auth: ^2.3.0
  geolocator: ^13.0.2
  lottie: ^3.3.1
  shimmer: ^3.0.0
```

## Konfiguratsiya

### Android Release Build

1. Keystore yarating:

   ```bash
   keytool -genkey -v -keystore topla-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias topla-release-key
   ```

2. `android/key.properties` yarating:

   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=topla-release-key
   storeFile=../keystore/topla-release.jks
   ```

3. Release APK yarating:

   ```bash
   flutter build apk --release
   ```

### iOS Build

```bash
flutter build ios --release
```

## Loyiha Tuzilishi

```text
topla_app/
├── android/              # Android native code
├── ios/                  # iOS native code
├── lib/                  # Dart source code
├── assets/               # Images, icons
├── test/                 # Unit tests
├── integration_test/     # E2E tests
└── pubspec.yaml         # Dependencies
```

## Testlar

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Coverage
flutter test --coverage
```

## Qo'llab-quvvatlanadigan Platformalar

| Platform | Minimal versiya |
| :--- | :--- |
| Android | 7.0 (API 24) |
| iOS | 12.0 |

## Hissa qo'shish

1. Fork qiling
2. Feature branch yarating (`git checkout -b feature/amazing-feature`)
3. Commit qiling (`git commit -m 'Add amazing feature'`)
4. Push qiling (`git push origin feature/amazing-feature`)
5. Pull Request oching

## Litsenziya

Bu loyiha xususiy litsenziya ostida. Barcha huquqlar himoyalangan.

## Aloqa

- **Email**: [support@topla.uz](mailto:support@topla.uz)
- **Telegram**: [@topla_support](https://t.me/topla_support)
- **Website**: [topla.uz](https://topla.uz)

---

Made with ❤️ in Uzbekistan
