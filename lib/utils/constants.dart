import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Placeholder for app constants
class AppConstants {
  static const String appName = 'PawHealth';
  static const String apiBaseUrl = 'https://api.example.com';
}

// ─────────────────────────────────────────────────────────────────────────────
// Design System — Colors
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryDark = Color(0xFF6D28D9);

  // Backgrounds
  static const Color darkBg = Color(0xFF4C1D95);
  static const Color lightSurface = Color(0xFFF7F5FF);
  static const Color white = Color(0xFFFFFFFF);

  // Cards & Borders
  static const Color cardBorder = Color(0xFFEDE8F8);
  static const Color chipBg = Color(0xFFF3EFFF);
  static const Color socialBtnBg = Color(0xFFFAF8FF);

  // Inputs
  static const Color inputBorder = Color(0xFFE5E0F0);

  // Text
  static const Color mutedText = Color(0xFF5B4B8A);
  static const Color metaText = Color(0xFF9B8CB8);
  static const Color darkText = Color(0xFF1E1B2E);

  // Glow / decorative
  static const Color glowPurple = Color(0xFF7C3AED);

  // Badges
  static const Color badgePurpleBg = Color(0x597C3AED); // ~35% opacity
  static const Color badgePurpleText = Color(0xFFC4B5FD);

  // Health
  static const Color healthGreen = Color(0xFF15803D);
  static const Color healthGreenBg = Color(0xFFECFDF3);

  // Nav
  static const Color navInactive = Color(0xFFC4B5FD);

  // Status — Appointments
  static const Color pendingBg = Color(0xFFFEF3C7);
  static const Color pendingText = Color(0xFFB45309);
  static const Color confirmedBg = Color(0xFFEFF6FF);
  static const Color confirmedText = Color(0xFF1E40AF);
  static const Color completedBg = Color(0xFFF0FDF4);
  static const Color completedText = Color(0xFF166534);
  static const Color cancelledBg = Color(0xFFFEF2F2);
  static const Color cancelledText = Color(0xFF991B1B);
}

// ─────────────────────────────────────────────────────────────────────────────
// Design System — Fonts (Figtree only)
// ─────────────────────────────────────────────────────────────────────────────

class AppFonts {
  AppFonts._();

  // ── Base Figtree helper ──

  static TextStyle figtree({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.darkText,
    FontStyle fontStyle = FontStyle.normal,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.figtree(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // ── Aliases kept for compatibility (all route to Figtree) ──

  static TextStyle fraunces({
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.darkText,
    FontStyle fontStyle = FontStyle.normal,
    double? height,
  }) {
    return figtree(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
      height: height,
    );
  }

  static TextStyle dmSans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.darkText,
    double? height,
    double? letterSpacing,
  }) {
    return figtree(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle headline({
    double fontSize = 26,
    Color color = AppColors.darkText,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return figtree(fontSize: fontSize, color: color, fontWeight: fontWeight);
  }

  static TextStyle serifItalic({
    double fontSize = 22,
    Color color = Colors.white,
  }) {
    return figtree(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
      color: color,
    );
  }

  static TextStyle body({
    double fontSize = 14,
    Color color = AppColors.darkText,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return figtree(fontSize: fontSize, color: color, fontWeight: fontWeight);
  }

  static TextStyle bodyBold({
    double fontSize = 14,
    Color color = AppColors.darkText,
  }) {
    return figtree(fontSize: fontSize, fontWeight: FontWeight.w700, color: color);
  }

  static TextStyle caption({
    double fontSize = 12,
    Color color = AppColors.mutedText,
  }) {
    return figtree(fontSize: fontSize, color: color);
  }

  static TextStyle label({
    double fontSize = 11,
    Color color = AppColors.primary,
  }) {
    return figtree(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 0.08 * fontSize,
    );
  }

  static TextStyle button({
    double fontSize = 16,
    Color color = Colors.white,
  }) {
    return figtree(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Design System — Decorations
// ─────────────────────────────────────────────────────────────────────────────

class AppDecor {
  AppDecor._();

  /// Flat square icon chip (40×40 default, border-radius: 12)
  static BoxDecoration squareChip({
    Color color = AppColors.chipBg,
    double radius = 12,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Standard white card
  static BoxDecoration card({double radius = 16}) {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.cardBorder, width: 1),
    );
  }

  /// Dark card (for appointment cards, hero sections)
  static BoxDecoration darkCard({double radius = 20}) {
    return BoxDecoration(
      color: AppColors.darkBg,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Bottom-border-only input decoration
  static InputDecoration inputDeco({
    required String label,
    IconData? icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: null,
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: AppFonts.label(),
          ),
        ],
      ),
      prefixIcon: icon != null
          ? Icon(icon, color: AppColors.mutedText, size: 20)
          : null,
      suffixIcon: suffix,
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.inputBorder, width: 1.5),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.inputBorder, width: 1.5),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: false,
    );
  }

  /// Standard CTA button style
  static ButtonStyle ctaButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryDark,
      disabledBackgroundColor: AppColors.primaryDark.withValues(alpha: 0.5),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
    );
  }

  /// Social / outline button style
  static ButtonStyle outlineButton() {
    return OutlinedButton.styleFrom(
      backgroundColor: AppColors.socialBtnBg,
      side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14),
    );
  }

  /// Standardized AppBar for tab pages (bottom nav tabs)
  static AppBar tabAppBar({
    required String title,
    List<Widget>? actions,
  }) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(title, style: AppFonts.headline(fontSize: 22)),
      actions: actions,
    );
  }

  /// Standardized AppBar for pushed pages (with back button)
  static AppBar pageAppBar({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
  }) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.darkText),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(title, style: AppFonts.bodyBold(fontSize: 17)),
      centerTitle: true,
      actions: actions,
    );
  }
}
