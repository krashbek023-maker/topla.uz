import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../widgets/notification_permission_dialog.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingData> _getPages(BuildContext context) {
    return [
      OnboardingData(
        lottieAsset: 'assets/lottie/onboarding/onboarding_1.json',
        title: context.l10n.translate('onboarding_1_title'),
        description: context.l10n.translate('onboarding_1_desc'),
        color: AppColors.primary,
      ),
      OnboardingData(
        lottieAsset: 'assets/lottie/onboarding/onboarding_2.json',
        title: context.l10n.translate('onboarding_2_title'),
        description: context.l10n.translate('onboarding_2_desc'),
        color: AppColors.accent,
      ),
      OnboardingData(
        lottieAsset: 'assets/lottie/onboarding/onboarding_3.json',
        title: context.l10n.translate('onboarding_3_title'),
        description: context.l10n.translate('onboarding_3_desc'),
        color: AppColors.success,
      ),
      OnboardingData(
        lottieAsset: 'assets/lottie/onboarding/onboarding_4.json',
        title: context.l10n.translate('onboarding_4_title'),
        description: context.l10n.translate('onboarding_4_desc'),
        color: AppColors.primary,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed(List<OnboardingData> pages) {
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: AppSizes.animNormal,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    if (!mounted) return;

    // Bildirishnoma ruxsatini so'rash
    await showNotificationPermissionDialog(context);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    context.l10n.translate('skip'),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(data: pages[index]);
                },
              ),
            ),

            // Bottom section
            Padding(
              padding: const EdgeInsets.all(AppSizes.xl),
              child: Column(
                children: [
                  // Page indicator
                  DotsIndicator(
                    dotsCount: pages.length,
                    position: _currentPage.toDouble(),
                    decorator: DotsDecorator(
                      activeColor: pages[_currentPage].color,
                      color: Colors.grey.shade300,
                      size: const Size.square(8),
                      activeSize: const Size(32, 8),
                      activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      spacing: const EdgeInsets.symmetric(horizontal: 3),
                    ),
                  ),

                  const SizedBox(height: AppSizes.xxl),

                  // Next/Start button
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeightLg,
                    child: ElevatedButton(
                      onPressed: () => _onNextPressed(pages),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pages[_currentPage].color,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == pages.length - 1
                                ? context.l10n.translate('get_started')
                                : context.l10n.next,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Icon(
                            _currentPage == pages.length - 1
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String lottieAsset;
  final String title;
  final String description;
  final Color color;

  OnboardingData({
    required this.lottieAsset,
    required this.title,
    required this.description,
    required this.color,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animatsiya
          SizedBox(
            width: 280,
            height: 280,
            child: Lottie.asset(
              data.lottieAsset,
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),

          const SizedBox(height: AppSizes.xl),

          // Sarlavha
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: data.color,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: AppSizes.md),

          // Tavsif
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
