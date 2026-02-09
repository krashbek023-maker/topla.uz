import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/constants/constants.dart';
import '../widgets/web_header.dart';
import '../widgets/web_footer.dart';

/// TOPLA.UZ asosiy landing sahifasi
class WebLandingPage extends StatelessWidget {
  const WebLandingPage({super.key});

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
                  _buildFeaturesSection(context),
                  _buildHowItWorksSection(context),
                  _buildStatsSection(context),
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
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.accent.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(child: _buildHeroContent(context, isWide)),
                const SizedBox(width: 60),
                Expanded(child: _buildHeroImage()),
              ],
            )
          : Column(
              children: [
                _buildHeroContent(context, isWide),
                const SizedBox(height: 40),
                _buildHeroImage(),
              ],
            ),
    );
  }

  Widget _buildHeroContent(BuildContext context, bool isWide) {
    return Column(
      crossAxisAlignment:
          isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '🚀 O\'zbekistonning yangi marketplace',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'TOPLA - Qulay xarid,\nTez yetkazib berish',
          textAlign: isWide ? TextAlign.start : TextAlign.center,
          style: TextStyle(
            fontSize: isWide ? 56 : 36,
            fontWeight: FontWeight.bold,
            height: 1.2,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Minglab mahsulotlar, ishonchli sotuvchilar va tez yetkazib berish. '
          'Ilovamizni yuklab oling yoki veb-saytimizdan xarid qiling.',
          textAlign: isWide ? TextAlign.start : TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade600,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            _buildAppStoreButton(
              'App Store',
              'assets/icon/app-store.png',
              () {},
            ),
            _buildAppStoreButton(
              'Google Play',
              'assets/icon/google-play.png',
              () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppStoreButton(String store, String icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              store.contains('App') ? Icons.apple : Icons.android,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yuklab olish',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                Text(
                  store,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 60,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: Colors.grey.shade100,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Text(
                      'T',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'TOPLA App',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
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
          const SizedBox(height: 16),
          Text(
            'Biz sizga eng yaxshi xarid tajribasini taqdim etamiz',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 60),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureCard(
                Iconsax.box_tick,
                'Sifatli mahsulotlar',
                'Faqat tekshirilgan sotuvchilardan original mahsulotlar',
                Colors.blue,
              ),
              _buildFeatureCard(
                Iconsax.truck_fast,
                'Tez yetkazib berish',
                'Toshkent bo\'ylab 1-2 soat ichida, viloyatlarga 1-3 kun',
                Colors.green,
              ),
              _buildFeatureCard(
                Iconsax.shield_tick,
                'Xavfsiz to\'lov',
                'Naqd, karta va Click/Payme orqali xavfsiz to\'lov',
                Colors.orange,
              ),
              _buildFeatureCard(
                Iconsax.medal_star,
                'Kafolat',
                'Barcha mahsulotlarga qaytarish kafolati',
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
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
            'Qanday ishlaydi?',
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
                    _buildStepCard(1, 'Mahsulot tanlang',
                        'Minglab mahsulotlar orasidan o\'zingizga keraklisini toping'),
                    _buildArrow(),
                    _buildStepCard(2, 'Buyurtma bering',
                        'Savatga qo\'shing va manzilni kiriting'),
                    _buildArrow(),
                    _buildStepCard(3, 'Yetkazib beramiz',
                        'Kuryer mahsulotni eshigingizgacha olib keladi'),
                  ],
                )
              : Column(
                  children: [
                    _buildStepCard(1, 'Mahsulot tanlang',
                        'Minglab mahsulotlar orasidan o\'zingizga keraklisini toping'),
                    const SizedBox(height: 24),
                    _buildStepCard(2, 'Buyurtma bering',
                        'Savatga qo\'shing va manzilni kiriting'),
                    const SizedBox(height: 24),
                    _buildStepCard(3, 'Yetkazib beramiz',
                        'Kuryer mahsulotni eshigingizgacha olib keladi'),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildStepCard(int step, String title, String description) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
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
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    return Icon(
      Iconsax.arrow_right_3,
      color: Colors.grey.shade400,
      size: 30,
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 100 : 24,
        vertical: 80,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
        ),
      ),
      child: Wrap(
        spacing: 60,
        runSpacing: 40,
        alignment: WrapAlignment.center,
        children: [
          _buildStatItem('10,000+', 'Mahsulotlar'),
          _buildStatItem('500+', 'Sotuvchilar'),
          _buildStatItem('50,000+', 'Mijozlar'),
          _buildStatItem('98%', 'Qoniqish'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return SizedBox(
      width: 180,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.9),
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
            'Do\'kon ochmoqchimisiz?',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'TOPLA platformasida do\'koningizni oching va minglab mijozlarga yeting',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/vendor');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Do\'kon ochish',
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
