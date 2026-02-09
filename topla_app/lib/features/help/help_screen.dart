import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/constants.dart';
import '../legal/terms_screen.dart';
import '../legal/privacy_screen.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'Qanday buyurtma beraman?',
      'answer':
          'Mahsulotni tanlang, savatchaga qo\'shing va buyurtmani rasmiylashting. To\'lov usulini tanlang va manzilni kiriting.',
      'isExpanded': false,
    },
    {
      'question': 'Yetkazib berish qancha vaqt oladi?',
      'answer':
          'Toshkent shahri bo\'ylab 2-4 soat ichida. Viloyatlarga 1-3 kun ichida yetkazib beramiz.',
      'isExpanded': false,
    },
    {
      'question': 'Mahsulotni qaytarish mumkinmi?',
      'answer':
          'Ha, 14 kun ichida mahsulotni qaytarishingiz mumkin. Mahsulot ishlatilmagan va original qadoqda bo\'lishi kerak.',
      'isExpanded': false,
    },
    {
      'question': 'Cashback qanday ishlaydi?',
      'answer':
          'Har bir xarid uchun cashback olasiz. Cashbackni keyingi xaridlaringizda ishlatishingiz mumkin.',
      'isExpanded': false,
    },
    {
      'question': 'To\'lov qanday amalga oshiriladi?',
      'answer':
          'Naqd pul, UzCard, Humo, Click yoki Payme orqali to\'lashingiz mumkin.',
      'isExpanded': false,
    },
    {
      'question': 'Buyurtmani bekor qilsam bo\'ladimi?',
      'answer':
          'Ha, buyurtma jo\'natilmaguncha uni bekor qilishingiz mumkin. Ilovadagi buyurtmalar bo\'limidan bekor qiling.',
      'isExpanded': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Yordam',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            _buildHeaderBanner(),

            // Contact Options
            _buildContactOptions(),

            const SizedBox(height: 24),

            // FAQ Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Ko\'p so\'raladigan savollar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildFaqList(),

            const SizedBox(height: 24),

            // App Info
            _buildAppInfo(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yordam kerakmi?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Biz sizga 24/7 yordam berishga tayyormiz',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Iconsax.message_question,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildContactCard(
              icon: Iconsax.call,
              title: 'Qo\'ng\'iroq',
              subtitle: '+998 95 000 94 16',
              color: AppColors.success,
              onTap: () => _makePhoneCall('+998950009416'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildContactCard(
              icon: Iconsax.message,
              title: 'Telegram',
              subtitle: '@topla_admin',
              color: const Color(0xFF0088CC),
              onTap: () => _openTelegram(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _faqs.asMap().entries.map((entry) {
          final index = entry.key;
          final faq = entry.value;
          return Column(
            children: [
              _buildFaqItem(faq, index),
              if (index < _faqs.length - 1)
                Divider(height: 1, color: Colors.grey.shade200),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> faq, int index) {
    return ExpansionTile(
      title: Text(
        faq['question'],
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Iconsax.message_question,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            faq['answer'],
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Iconsax.document_text,
            title: 'Foydalanish shartlari',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsScreen()),
            ),
          ),
          Divider(height: 24, color: Colors.grey.shade200),
          _buildInfoRow(
            icon: Iconsax.shield_tick,
            title: 'Maxfiylik siyosati',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyScreen()),
            ),
          ),
          Divider(height: 24, color: Colors.grey.shade200),
          _buildInfoRow(
            icon: Iconsax.info_circle,
            title: 'Ilova haqida',
            trailing: Text(
              'v1.0.0',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          trailing ??
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade300,
                size: 28,
              ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Qo\'ng\'iroq qilishda xatolik'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openTelegram() async {
    final Uri telegramUri = Uri.parse('https://t.me/topla_admin');
    try {
      await launchUrl(telegramUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Telegramni ochishda xatolik'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
