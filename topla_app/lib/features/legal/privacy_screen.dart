import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/constants.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maxfiylik siyosati'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TOPLA MAXFIYLIK SIYOSATI',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'So\'nggi yangilangan: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            _buildSection(
              '1. KIRISH',
              '''Ushbu Maxfiylik siyosati TOPLA ilovasi ("biz", "bizning") foydalanuvchilarning ("siz", "sizning") shaxsiy ma'lumotlarini qanday yig'ishi, ishlatishi, saqlashi va himoya qilishini tushuntiradi.

Ilovadan foydalanish orqali Siz ushbu siyosatga rozlik bildirasiz.

TOPLA O'zbekiston Respublikasi qonunchiligiga, shu jumladan "Shaxsga doir ma'lumotlar to'g'risida"gi qonunga muvofiq ishlaydi.''',
            ),

            _buildSection(
              '2. YIG\'ILADIGAN MA\'LUMOTLAR',
              '''2.1. Siz taqdim etadigan ma'lumotlar:
• Telefon raqami (ro'yxatdan o'tish uchun)
• Ism va familiya
• Yetkazib berish manzillari
• Email (ixtiyoriy)

2.2. Avtomatik yig'iladigan ma'lumotlar:
• Qurilma identifikatori
• IP manzil
• Ilova foydalanish statistikasi
• Geolokatsiya (ruxsat berilganda)

2.3. To'lov ma'lumotlari:
• Karta raqamining oxirgi 4 raqami
• Karta turi (UzCard, HUMO, Visa, Mastercard)
• Karta amal qilish muddati

⚠️ MUHIM: Biz to'liq karta raqamlarini saqlamaymiz. To'lovlar Asia Alliance Bank xavfsiz serverlari orqali amalga oshiriladi.''',
            ),

            _buildSection(
              '3. MA\'LUMOTLARDAN FOYDALANISH',
              '''Sizning ma'lumotlaringiz quyidagi maqsadlarda ishlatiladi:

✓ Buyurtmalarni qayta ishlash va yetkazib berish
✓ Hisobingizni boshqarish
✓ Sizga xabar yuborish (buyurtma holati, aksiyalar)
✓ Xizmat sifatini yaxshilash
✓ Firibgarlikni oldini olish
✓ Qonuniy talablarni bajarish

Biz sizning ma'lumotlaringizni sizning rozligingiz bilan reklama maqsadlarida ishlatishimiz mumkin. Siz istalgan vaqtda obunani bekor qilishingiz mumkin.''',
            ),

            _buildSection(
              '4. MA\'LUMOTLARNI ULASHISH',
              '''Sizning ma'lumotlaringiz quyidagilar bilan ulashilishi mumkin:

🏪 SOTUVCHILAR (Vendorlar)
• Buyurtmangizni bajarish uchun zarur ma'lumotlar
• Ism, manzil, telefon raqami

🚚 YETKAZIB BERISH XIZMATI
• Kuryer buyurtmani yetkazib berish uchun manzilingizni oladi

💳 TO'LOV PROVAYDERLARI
• Asia Alliance Bank - to'lovlarni qayta ishlash
• To'lov ma'lumotlari xavfsiz uzatiladi

📊 ANALITIKA XIZMATLARI
• Firebase Analytics - foydalanish statistikasi
• Anonim va yig'ma ma'lumotlar

Biz ma'lumotlaringizni uchinchi tomonlarga sotmaymiz yoki ijaraga bermaymiz.''',
            ),

            _buildSection(
              '5. MA\'LUMOTLAR XAVFSIZLIGI',
              '''Sizning ma'lumotlaringizni himoya qilish uchun biz:

🔐 Texnik choralar:
• SSL/TLS shifrlash
• Xavfsiz serverlar (AWS, Cloud)
• Muntazam xavfsizlik auditi
• Ma'lumotlarni shifrlash

👥 Tashkiliy choralar:
• Cheklangan kirish huquqi
• Xodimlar o'qitilgan
• Maxfiylik shartnomarlari

💳 To'lov xavfsizligi:
• PCI DSS standartlariga muvofiq
• 3D Secure texnologiyasi
• Tokenizatsiya (karta ma'lumotlari saqlanmaydi)''',
            ),

            _buildSection(
              '6. MA\'LUMOTLARNI SAQLASH MUDDATI',
              '''• Aktiv hisob ma'lumotlari - hisob faol bo'lguncha
• Buyurtma tarixi - 5 yil (soliq qonunchiligiga muvofiq)
• To'lov yozuvlari - 5 yil
• Faoliyatsiz hisob - 2 yildan so'ng o'chirilishi mumkin

Siz istalgan vaqtda ma'lumotlaringizni o'chirishni so'rashingiz mumkin.''',
            ),

            _buildSection(
              '7. SIZNING HUQUQLARINGIZ',
              '''O'zbekiston qonunchiligiga muvofiq sizda quyidagi huquqlar mavjud:

✅ Kirish huquqi
Ma'lumotlaringiz qanday ishlatilayotganini bilish

✅ Tuzatish huquqi
Noto'g'ri ma'lumotlarni tuzattirish

✅ O'chirish huquqi
Ma'lumotlaringizni o'chirishni so'rash

✅ Cheklash huquqi
Ma'lumotlardan foydalanishni cheklash

✅ Ko'chirish huquqi
Ma'lumotlaringiz nusxasini olish

✅ E'tiroz huquqi
Marketing xabarlaridan voz kechish

Huquqlaringizdan foydalanish uchun: support@topla.uz''',
            ),

            _buildSection(
              '8. COOKIES VA KUZATISH',
              '''Ilova quyidagilardan foydalanadi:

📱 Mahalliy saqlash:
• Sessiya ma'lumotlari
• Afzalliklar (til, mavzu)
• Kesh (tezroq yuklash uchun)

📊 Analitika:
• Firebase Analytics
• Foydalanuvchi identifikatori
• Qurilma ma'lumotlari

Siz qurilma sozlamalarida analitikani o'chirishingiz mumkin.''',
            ),

            _buildSection(
              '9. BOLALAR MAXFIYLIGI',
              '''TOPLA 18 yoshdan kichik shaxslarga mo'ljallanmagan.

Biz ataylab 18 yoshgacha bo'lgan shaxslardan ma'lumot yig'maymiz. Agar siz voyaga yetmagan foydalanuvchi ma'lumotlarini topganingizni bilsangiz, bizga xabar bering.''',
            ),

            _buildSection(
              '10. XALQARO MA\'LUMOT UZATISH',
              '''Sizning ma'lumotlaringiz O'zbekiston Respublikasi hududida joylashgan serverlarda saqlanadi.

Ba'zi xizmat ko'rsatuvchilar (Firebase) xalqaro serverlarda ma'lumotlarni qayta ishlashi mumkin. Bunday hollarda tegishli himoya choralari ko'riladi.''',
            ),

            _buildSection(
              '11. SIYOSATNI O\'ZGARTIRISH',
              '''Biz ushbu Maxfiylik siyosatini istalgan vaqtda yangilashimiz mumkin.

O'zgarishlar haqida:
• Ilova orqali bildirishnoma
• Email xabari (muhim o'zgarishlar)

Yangilangan sana sahifa boshida ko'rsatiladi.''',
            ),

            _buildSection(
              '12. BOG\'LANISH',
              '''Maxfiylik savollaringiz uchun:

📧 Email: privacy@topla.uz
📞 Telefon: +998 90 123 45 67
📍 Manzil: O'zbekiston, Toshkent shahri, Yunusobod tumani

Ma'lumotlar bo'yicha mas'ul shaxs:
Topla Privacy Team
privacy@topla.uz''',
            ),

            const SizedBox(height: AppSizes.xl),

            // Ma'lumotlar himoyasi badge
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Iconsax.shield_tick,
                    color: AppColors.success,
                    size: 48,
                  ),
                  const SizedBox(height: AppSizes.md),
                  const Text(
                    'Sizning ma\'lumotlaringiz xavfsiz',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'Biz sizning shaxsiy ma\'lumotlaringizni himoya qilish uchun eng so\'nggi texnologiyalardan foydalanamiz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.xl * 2),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
