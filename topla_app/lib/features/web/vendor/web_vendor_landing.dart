import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/constants/constants.dart';
import '../widgets/web_header.dart';
import '../widgets/web_footer.dart';

/// Vendor landing sahifasi - do'kon ochish uchun
class WebVendorLanding extends StatelessWidget {
  const WebVendorLanding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const WebHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroSection(context),
                  _buildBenefitsSection(context),
                  _buildHowToStartSection(context),
                  _buildPricingSection(context),
                  _buildFAQSection(context),
                  _buildCTASection(context),
                  const WebFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 100 : 24,
        vertical: isWide ? 80 : 40,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '🏪 Sotuvchi bo\'ling',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'TOPLA da do\'koningizni\noching va daromad oling',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isWide ? 48 : 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 600,
            child: Text(
              'Minglab mijozlarga yeting, mahsulotlaringizni oson boshqaring va '
              'har oy barqaror daromad oling. Bepul ro\'yxatdan o\'ting!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/vendor/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Bepul ro\'yxatdan o\'tish',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/vendor/login'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Kirish',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 100 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          const Text(
            'Nima uchun TOPLA?',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _buildBenefitCard(
                Iconsax.people,
                '50,000+ mijozlar',
                'Tayyor mijozlar bazasiga ega bo\'ling, reklama uchun qo\'shimcha xarajat yo\'q',
                Colors.blue,
              ),
              _buildBenefitCard(
                Iconsax.wallet_money,
                'Past komissiya',
                'Boshqa platformalarga nisbatan eng past komissiya - atigi 5-10%',
                Colors.green,
              ),
              _buildBenefitCard(
                Iconsax.truck_fast,
                'Yetkazib berish',
                'Biz yetkazib berishni o\'zimiz tashkil qilamiz, siz faqat mahsulotni tayyor qiling',
                Colors.orange,
              ),
              _buildBenefitCard(
                Iconsax.chart_2,
                'Analitika',
                'Sotuvlar, mijozlar va mahsulotlar bo\'yicha batafsil analitika',
                Colors.purple,
              ),
              _buildBenefitCard(
                Iconsax.money_recive,
                'Tez to\'lov',
                'Har hafta hisobingizga pul o\'tkaziladi, kechikish yo\'q',
                Colors.teal,
              ),
              _buildBenefitCard(
                Iconsax.headphone,
                '24/7 qo\'llab-quvvatlash',
                'Har qanday savolingizga tezkor javob, muammolarni hal qilamiz',
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(
      IconData icon, String title, String description, Color color) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
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
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToStartSection(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 100 : 24,
        vertical: 80,
      ),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          const Text(
            'Qanday boshlash?',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 60),
          isWide
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStepCard(
                        1,
                        'Ro\'yxatdan o\'ting',
                        'Email va telefon bilan 2 daqiqada ro\'yxatdan o\'ting',
                        Iconsax.user_add),
                    _buildStepArrow(),
                    _buildStepCard(
                        2,
                        'Do\'konni sozlang',
                        'Do\'kon nomi, logotip va ma\'lumotlarni kiriting',
                        Iconsax.shop),
                    _buildStepArrow(),
                    _buildStepCard(
                        3,
                        'Mahsulot qo\'shing',
                        'Rasm, narx va tavsif bilan mahsulotlarni joylashtiring',
                        Iconsax.box_add),
                    _buildStepArrow(),
                    _buildStepCard(
                        4,
                        'Sotishni boshlang',
                        'Buyurtmalarni qabul qiling va daromad oling',
                        Iconsax.money_recive),
                  ],
                )
              : Column(
                  children: [
                    _buildStepCard(
                        1,
                        'Ro\'yxatdan o\'ting',
                        'Email va telefon bilan 2 daqiqada ro\'yxatdan o\'ting',
                        Iconsax.user_add),
                    const SizedBox(height: 24),
                    _buildStepCard(
                        2,
                        'Do\'konni sozlang',
                        'Do\'kon nomi, logotip va ma\'lumotlarni kiriting',
                        Iconsax.shop),
                    const SizedBox(height: 24),
                    _buildStepCard(
                        3,
                        'Mahsulot qo\'shing',
                        'Rasm, narx va tavsif bilan mahsulotlarni joylashtiring',
                        Iconsax.box_add),
                    const SizedBox(height: 24),
                    _buildStepCard(
                        4,
                        'Sotishni boshlang',
                        'Buyurtmalarni qabul qiling va daromad oling',
                        Iconsax.money_recive),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildStepCard(
      int step, String title, String description, IconData icon) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$step-qadam',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Icon(
        Iconsax.arrow_right_3,
        color: Colors.grey.shade400,
        size: 24,
      ),
    );
  }

  Widget _buildPricingSection(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 100 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          const Text(
            'Shaffof narxlar',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Yashirin to\'lovlar yo\'q, faqat sotuvdan komissiya',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 60),
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text(
                  'Komissiya',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '5-10%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'har bir sotuvdan',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                _buildPricingFeature('✓ Ro\'yxatdan o\'tish BEPUL'),
                _buildPricingFeature('✓ Oylik to\'lov YO\'Q'),
                _buildPricingFeature('✓ Cheksiz mahsulot'),
                _buildPricingFeature('✓ Yetkazib berish biz tomondan'),
                _buildPricingFeature('✓ 24/7 qo\'llab-quvvatlash'),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/vendor/register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Hozir boshlash',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 100 : 24,
        vertical: 80,
      ),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          const Text(
            'Ko\'p beriladigan savollar',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                _buildFAQItem(
                  'Ro\'yxatdan o\'tish uchun nima kerak?',
                  'Telefon raqam, email va pasport ma\'lumotlari kerak. Yuridik shaxslar uchun STIR va litsenziya talab qilinadi.',
                ),
                _buildFAQItem(
                  'Qancha vaqtda tasdiqlashadi?',
                  'Odatda 1-2 ish kuni ichida do\'koningiz tasdiqlanadi. Barcha hujjatlar to\'g\'ri bo\'lsa, tezroq ham bo\'lishi mumkin.',
                ),
                _buildFAQItem(
                  'Yetkazib berishni kim qiladi?',
                  'TOPLA o\'z kuryer xizmatiga ega. Siz mahsulotni tayyorlab berasiz, biz mijozga yetkazamiz.',
                ),
                _buildFAQItem(
                  'Pul qachon hisobga tushadi?',
                  'Har hafta payshanba kuni o\'tgan haftaning mablag\'lari hisobingizga o\'tkaziladi.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 100 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          const Text(
            'Tayyor boshlashga?',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '2 daqiqada ro\'yxatdan o\'ting va bugun sotishni boshlang',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/vendor/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Bepul ro\'yxatdan o\'tish',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
