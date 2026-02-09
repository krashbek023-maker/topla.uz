import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/constants/constants.dart';

/// Web sayt footeri
class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 100 : 24,
        vertical: 60,
      ),
      color: Colors.grey.shade900,
      child: Column(
        children: [
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildAboutSection()),
                    Expanded(
                        child: _buildLinksSection('Kompaniya', [
                      'Biz haqimizda',
                      'Blog',
                      'Vakansiyalar',
                      'Hamkorlik',
                    ])),
                    Expanded(
                        child: _buildLinksSection('Yordam', [
                      'Bog\'lanish',
                      'FAQ',
                      'Yetkazib berish',
                      'Qaytarish',
                    ])),
                    Expanded(
                        child: _buildLinksSection('Huquqiy', [
                      'Foydalanish shartlari',
                      'Maxfiylik siyosati',
                      'Cookie siyosati',
                    ])),
                    Expanded(child: _buildContactSection()),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAboutSection(),
                    const SizedBox(height: 40),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _buildLinksSection('Kompaniya', [
                          'Biz haqimizda',
                          'Blog',
                          'Vakansiyalar',
                        ])),
                        Expanded(
                            child: _buildLinksSection('Yordam', [
                          'Bog\'lanish',
                          'FAQ',
                          'Qaytarish',
                        ])),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildContactSection(),
                  ],
                ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade800),
              ),
            ),
            child: isWide
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '© 2026 TOPLA. Barcha huquqlar himoyalangan.',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          _buildSocialIcon(Iconsax.message, () {}),
                          _buildSocialIcon(Iconsax.instagram, () {}),
                          _buildSocialIcon(Iconsax.facebook, () {}),
                        ],
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialIcon(Iconsax.message, () {}),
                          _buildSocialIcon(Iconsax.instagram, () {}),
                          _buildSocialIcon(Iconsax.facebook, () {}),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '© 2026 TOPLA. Barcha huquqlar himoyalangan.',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'T',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'TOPLA',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'O\'zbekistonning zamonaviy online marketplace platformasi. '
          'Sifatli mahsulotlar, ishonchli sotuvchilar va tez yetkazib berish.',
          style: TextStyle(
            color: Colors.grey.shade400,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildLinksSection(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {},
                child: Text(
                  link,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bog\'lanish',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactItem(Iconsax.call, '+998 99 999 99 99'),
        _buildContactItem(Iconsax.sms, 'info@topla.uz'),
        _buildContactItem(Iconsax.location, 'Toshkent, O\'zbekiston'),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
