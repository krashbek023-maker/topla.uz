import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/constants/constants.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foydalanish shartlari'),
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
              'TOPLA FOYDALANISH SHARTLARI',
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
              '1. UMUMIY QOIDALAR',
              '''1.1. Ushbu Foydalanish shartlari (keyingi o'rinlarda - "Shartlar") TOPLA mobil ilovasi (keyingi o'rinlarda - "Ilova") xizmatlaridan foydalanish qoidalarini belgilaydi.

1.2. Ilovadan foydalanish orqali Siz ushbu Shartlarni to'liq o'qib chiqqaningizni va ularga rozligingizni tasdiqlaysiz.

1.3. TOPLA - bu multi-vendor marketplace platforma bo'lib, turli do'konlardan mahsulotlarni bitta joyda sotib olish imkonini beradi.

1.4. Ilova operatori: TOPLA MCHJ, STIR: 123456789, Manzil: O'zbekiston Respublikasi, Toshkent shahri, Yunusobod tumani.''',
            ),
            _buildSection(
              '2. RO\'YXATDAN O\'TISH VA HISOB',
              '''2.1. Ilovadan foydalanish uchun telefon raqamingiz orqali ro'yxatdan o'tishingiz kerak.

2.2. Siz taqdim etgan ma'lumotlarning to'g'riligi va dolzarbligiga javobgarsiz.

2.3. Hisobingizning xavfsizligini ta'minlash sizning mas'uliyatingizdir. Parol yoki SMS kodlarini boshqalar bilan bo'lishmang.

2.4. Biz quyidagi hollarda hisobingizni to'xtatish yoki o'chirish huquqini saqlab qolamiz:
  - Shartlarni buzganingizda
  - Firibgarlik faoliyatida shubha bo'lganda
  - Uzoq vaqt faoliyatsizlik holatida''',
            ),
            _buildSection(
              '3. BUYURTMA VA TO\'LOV',
              '''3.1. Buyurtma berish orqali Siz ko'rsatilgan narxda mahsulotlarni sotib olishga rozlik bildirasiz.

3.2. Narxlar so'mda ko'rsatiladi va QQS kiritilgan.

3.3. To'lov usullari:
  - Naqd pul (yetkazib berish vaqtida)
  - Plastik kartalar (UzCard, HUMO, Visa, Mastercard)
  
3.4. Karta orqali to'lov Asia Alliance Bank tomonidan xavfsiz ekvayring xizmati orqali amalga oshiriladi.

3.5. To'lov muvaffaqiyatli amalga oshirilgach, buyurtma tasdiqlanadi.

3.6. Buyurtmani bekor qilish shartlari:
  - Yetkazib berishdan oldin - to'liq qaytarish
  - Yetkazib berish jarayonida - yetkazib berish xarajatlari ushlab qolinishi mumkin''',
            ),
            _buildSection(
              '4. YETKAZIB BERISH',
              '''4.1. Yetkazib berish Toshkent shahri va viloyat markazlarida amalga oshiriladi.

4.2. Yetkazib berish vaqti buyurtma berishda ko'rsatiladi.

4.3. Yetkazib berish narxi buyurtma summasiga qarab belgilanadi.

4.4. Yetkazib berish kechikishi holatlari:
  - Fors-major holatlar
  - Transport muammolari
  - Manzil aniq bo'lmasligi

4.5. Mahsulotni qabul qilishda tekshirib ko'ring. Shikastlangan yoki noto'g'ri mahsulotlar haqida darhol xabar bering.''',
            ),
            _buildSection(
              '5. QAYTARISH VA ALMASHTIRISH',
              '''5.1. Mahsulotlarni qabul qilganingizdan so'ng 14 kun ichida qaytarishingiz mumkin (iste'mol mollari bundan mustasno).

5.2. Qaytarish shartlari:
  - Mahsulot original qadoqda bo'lishi kerak
  - Foydalanilmagan bo'lishi kerak
  - Chek yoki buyurtma raqami talab qilinadi

5.3. Qaytarish uchun ilovadagi "Mening buyurtmalarim" bo'limida ariza qoldiring.

5.4. Pul mablag'lari 3-5 ish kuni ichida qaytariladi.''',
            ),
            _buildSection(
              '6. SOTUVCHILAR (VENDORLAR)',
              '''6.1. TOPLA platformasida turli sotuvchilar mahsulotlarini sotadi.

6.2. Har bir mahsulot uchun sotuvchi javobgardir.

6.3. TOPLA sotuvchilarni tekshiradi, ammo mahsulot sifatiga kafolat bermaydi.

6.4. Sotuvchi bilan bog'liq muammolar bo'lsa, TOPLA qo'llab-quvvatlash xizmatiga murojaat qiling.''',
            ),
            _buildSection(
              '7. INTELLEKTUAL MULK',
              '''7.1. Ilovadagi barcha kontent, dizayn, logotiplar TOPLA intellektual mulki hisoblanadi.

7.2. Kontentni ruxsatsiz nusxalash, tarqatish yoki o'zgartirish taqiqlanadi.

7.3. Sotuvchilar o'z mahsulot ma'lumotlari uchun javobgardir.''',
            ),
            _buildSection(
              '8. JAVOBGARLIKNI CHEKLASH',
              '''8.1. TOPLA quyidagilar uchun javobgar emas:
  - Sotuvchilar tomonidan taqdim etilgan mahsulot sifati
  - Uchinchi tomon xizmatlari (to'lov tizimlari, yetkazib berish)
  - Fors-major holatlar
  - Foydalanuvchi xatosi

8.2. TOPLA javobgarligi buyurtma summasi bilan cheklangan.''',
            ),
            _buildSection(
              '9. SHARTLARNI O\'ZGARTIRISH',
              '''9.1. Biz ushbu Shartlarni istalgan vaqtda o'zgartirish huquqini saqlab qolamiz.

9.2. O'zgarishlar haqida ilova orqali xabar beriladi.

9.3. O'zgarishlardan so'ng ilovadan foydalanishni davom ettirishingiz yangi shartlarga rozligingizni bildiradi.''',
            ),
            _buildSection(
              '10. BOG\'LANISH',
              '''Savollar yoki shikoyatlar uchun:
              
📧 Email: support@topla.uz
📞 Telefon: +998 90 123 45 67
💬 Telegram: @topla_support

Ish vaqti: Dushanba - Shanba, 09:00 - 21:00''',
            ),
            const SizedBox(height: AppSizes.xl),
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Text(
                      'Ilovadan foydalanish orqali Siz ushbu shartlarga rozlik bildirasiz.',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
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
