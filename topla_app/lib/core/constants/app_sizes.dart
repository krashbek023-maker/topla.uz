import 'package:flutter/material.dart';

/// TOPLA App o'lchamlari va spacing'lari
class AppSizes {
  AppSizes._();

  // === PADDING va MARGIN ===
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // === BORDER RADIUS ===
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 100.0;

  // === ICON SIZES ===
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 28.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;

  // === BUTTON SIZES ===
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightLg = 52.0;
  static const double buttonHeightXl = 56.0;

  // === INPUT SIZES ===
  static const double inputHeight = 48.0;
  static const double inputHeightLg = 56.0;

  // === AVATAR SIZES ===
  static const double avatarXs = 24.0;
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 80.0;
  static const double avatarXxl = 120.0;

  // === CARD SIZES ===
  static const double cardElevation = 2.0;
  static const double cardElevationHigh = 8.0;

  // === PRODUCT CARD ===
  static const double productCardWidth = 170.0;
  static const double productCardHeight = 320.0;
  static const double productImageHeight = 160.0;

  // === CATEGORY ITEM ===
  static const double categoryItemSize = 72.0;
  static const double categoryIconSize = 40.0;

  // === BANNER ===
  static const double bannerHeight = 200.0;
  static const double bannerHeightLg = 240.0;

  // === BOTTOM NAV ===
  static const double bottomNavHeight = 64.0;
  static const double bottomNavIconSize = 24.0;

  // === APP BAR ===
  static const double appBarHeight = 56.0;
  static const double appBarHeightLg = 64.0;

  // === MAX WIDTHS ===
  static const double maxContentWidth = 600.0;
  static const double maxFormWidth = 400.0;

  // === ANIMATION DURATIONS ===
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // === BORDER RADIUS PRESETS ===
  static BorderRadius get borderRadiusXs => BorderRadius.circular(radiusXs);
  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusXxl => BorderRadius.circular(radiusXxl);

  // === EDGE INSETS PRESETS ===
  static EdgeInsets get paddingXs => const EdgeInsets.all(xs);
  static EdgeInsets get paddingSm => const EdgeInsets.all(sm);
  static EdgeInsets get paddingMd => const EdgeInsets.all(md);
  static EdgeInsets get paddingLg => const EdgeInsets.all(lg);
  static EdgeInsets get paddingXl => const EdgeInsets.all(xl);
  static EdgeInsets get paddingXxl => const EdgeInsets.all(xxl);

  static EdgeInsets get paddingHorizontalSm =>
      const EdgeInsets.symmetric(horizontal: sm);
  static EdgeInsets get paddingHorizontalMd =>
      const EdgeInsets.symmetric(horizontal: md);
  static EdgeInsets get paddingHorizontalLg =>
      const EdgeInsets.symmetric(horizontal: lg);
  static EdgeInsets get paddingHorizontalXl =>
      const EdgeInsets.symmetric(horizontal: xl);

  static EdgeInsets get paddingVerticalSm =>
      const EdgeInsets.symmetric(vertical: sm);
  static EdgeInsets get paddingVerticalMd =>
      const EdgeInsets.symmetric(vertical: md);
  static EdgeInsets get paddingVerticalLg =>
      const EdgeInsets.symmetric(vertical: lg);
  static EdgeInsets get paddingVerticalXl =>
      const EdgeInsets.symmetric(vertical: xl);
}
