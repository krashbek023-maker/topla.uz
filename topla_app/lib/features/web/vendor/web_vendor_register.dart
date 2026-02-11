import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/services/api_client.dart';
import '../../../core/constants/constants.dart';
import '../widgets/web_header.dart';
import '../widgets/web_footer.dart';

/// Vendor ro'yxatdan o'tish sahifasi
class WebVendorRegister extends StatefulWidget {
  const WebVendorRegister({super.key});

  @override
  State<WebVendorRegister> createState() => _WebVendorRegisterState();
}

class _WebVendorRegisterState extends State<WebVendorRegister> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Shaxsiy ma'lumotlar
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Step 2: Do'kon ma'lumotlari
  final _shopNameController = TextEditingController();
  final _shopDescriptionController = TextEditingController();
  final _shopAddressController = TextEditingController();
  String? _selectedCategory;

  // Step 3: Hujjatlar
  final _innController = TextEditingController();
  final _licenseController = TextEditingController();
  bool _isLegalEntity = false;
  bool _agreedToTerms = false;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> _categories = [
    'Oziq-ovqat',
    'Elektronika',
    'Kiyim-kechak',
    'Go\'zallik',
    'Uy-ro\'zg\'or',
    'Sport',
    'Bolalar uchun',
    'Kitoblar',
    'Boshqa',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _shopNameController.dispose();
    _shopDescriptionController.dispose();
    _shopAddressController.dispose();
    _innController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          const WebHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 100 : 24,
                      vertical: 40,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Do\'kon ochish',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '3 oddiy qadamda ro\'yxatdan o\'ting',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildStepper(),
                        const SizedBox(height: 40),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 600),
                          padding: const EdgeInsets.all(32),
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
                          child: Form(
                            key: _formKey,
                            child: SizedBox(
                              height: 500,
                              child: PageView(
                                controller: _pageController,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _buildStep1(),
                                  _buildStep2(),
                                  _buildStep3(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const WebFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepIndicator(0, 'Shaxsiy', Iconsax.user),
        _buildStepLine(0),
        _buildStepIndicator(1, 'Do\'kon', Iconsax.shop),
        _buildStepLine(1),
        _buildStepIndicator(2, 'Hujjatlar', Iconsax.document),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.grey.shade200,
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: AppColors.primary, width: 3)
                : null,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.grey.shade400,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppColors.primary : Colors.grey.shade400,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = _currentStep > step;

    return Container(
      width: 60,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shaxsiy ma\'lumotlar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _fullNameController,
            label: 'To\'liq ism',
            icon: Iconsax.user,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Ismingizni kiriting' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Telefon raqam',
            icon: Iconsax.call,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Telefon raqamni kiriting';
              if (value!.length < 9) return 'Noto\'g\'ri raqam';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Iconsax.sms,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Email kiriting';
              if (!value!.contains('@')) return 'Noto\'g\'ri email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _passwordController,
            label: 'Parol',
            icon: Iconsax.lock,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Parol kiriting';
              if (value!.length < 6) return 'Kamida 6 ta belgi';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Parolni tasdiqlang',
            icon: Iconsax.lock,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Iconsax.eye_slash : Iconsax.eye,
              ),
              onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Parollar mos emas';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Do\'kon ma\'lumotlari',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _shopNameController,
            label: 'Do\'kon nomi',
            icon: Iconsax.shop,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Do\'kon nomini kiriting' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Kategoriya',
              prefixIcon: const Icon(Iconsax.category),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _categories.map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
            validator: (value) => value == null ? 'Kategoriya tanlang' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _shopDescriptionController,
            label: 'Do\'kon tavsifi',
            icon: Iconsax.document_text,
            maxLines: 3,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Tavsif kiriting' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _shopAddressController,
            label: 'Manzil',
            icon: Iconsax.location,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Manzil kiriting' : null,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _buildBackButton()),
              const SizedBox(width: 16),
              Expanded(child: _buildNextButton()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hujjatlar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Yuridik shaxs'),
            subtitle: const Text('Agar kompaniya bo\'lsa'),
            value: _isLegalEntity,
            onChanged: (value) => setState(() => _isLegalEntity = value),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          if (_isLegalEntity) ...[
            _buildTextField(
              controller: _innController,
              label: 'STIR (INN)',
              icon: Iconsax.document,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (_isLegalEntity && (value?.isEmpty ?? true)) {
                  return 'STIR kiriting';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _licenseController,
              label: 'Litsenziya raqami',
              icon: Iconsax.document_1,
            ),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Iconsax.info_circle, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Jismoniy shaxslar uchun pasport nusxasi talab qilinadi. '
                    'Uni ro\'yxatdan o\'tgandan keyin yuklashingiz mumkin.',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          CheckboxListTile(
            value: _agreedToTerms,
            onChanged: (value) =>
                setState(() => _agreedToTerms = value ?? false),
            title: const Text(
              'Foydalanish shartlari va maxfiylik siyosatiga roziman',
              style: TextStyle(fontSize: 14),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: _buildBackButton()),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _agreedToTerms && !_isLoading ? _register : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Ro\'yxatdan o\'tish',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildBackButton() {
    return OutlinedButton(
      onPressed: () {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _currentStep--);
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text('Orqaga'),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: _nextStep,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Keyingisi',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_fullNameController.text.isEmpty ||
          _phoneController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barcha maydonlarni to\'ldiring')),
        );
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parollar mos emas')),
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (_shopNameController.text.isEmpty ||
          _selectedCategory == null ||
          _shopAddressController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barcha maydonlarni to\'ldiring')),
        );
        return;
      }
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep++);
  }

  Future<void> _register() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shartlarga rozilik bering')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ApiClient();

      // 1. Vendor ro'yxatdan o'tkazish + do'kon yaratish
      await api.post('/auth/vendor/register', body: {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'shopName': _shopNameController.text.trim(),
        'shopDescription': _shopDescriptionController.text.trim(),
        'shopAddress': _shopAddressController.text.trim(),
        'category': _selectedCategory,
        'isLegalEntity': _isLegalEntity,
        if (_isLegalEntity) 'inn': _innController.text.trim(),
        if (_isLegalEntity) 'license': _licenseController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Muvaffaqiyatli! Do\'koningiz ko\'rib chiqilmoqda'),
            backgroundColor: Colors.green,
          ),
        );

        // Login sahifasiga yo'naltirish
        Navigator.pushReplacementNamed(context, '/vendor/login');
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
