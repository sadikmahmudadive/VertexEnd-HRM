import 'package:flutter/material.dart';

/// Design-system color tokens, resolved per theme.
@immutable
class HrmColors extends ThemeExtension<HrmColors> {
  const HrmColors({
    required this.isDark,
    required this.primary50,
    required this.primary500,
    required this.primary600,
    required this.secondary500,
    required this.heroFrom,
    required this.heroTo,
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgSurfaceRaised,
    required this.bgSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnPrimary,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.info,
    required this.infoSoft,
    required this.neutral,
    required this.neutralSoft,
  });

  final bool isDark;
  final Color primary50;
  final Color primary500;
  final Color primary600;
  final Color secondary500;
  final Color heroFrom;
  final Color heroTo;
  final Color bgCanvas;
  final Color bgSurface;
  final Color bgSurfaceRaised;
  final Color bgSubtle;
  final Color borderDefault;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnPrimary;
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;
  final Color info;
  final Color infoSoft;
  final Color neutral;
  final Color neutralSoft;

  // Scale steps that are the same in both themes.
  static const Color primary100 = Color(0xFFE0E7FF);
  static const Color primary200 = Color(0xFFC7D2FE);
  static const Color primary300 = Color(0xFFA5B4FC);
  static const Color primary400 = Color(0xFF818CF8);
  static const Color primary700 = Color(0xFF3730A3);
  static const Color primary800 = Color(0xFF312E81);
  static const Color primary900 = Color(0xFF1E1B4B);
  static const Color onHero = Color(0xFFFFFFFF);

  // Leave-type colors.
  static const Color leaveAnnual = Color(0xFF4F46E5);
  static const Color leaveSick = Color(0xFFF43F5E);
  static const Color leaveParental = Color(0xFF14B8A6);
  static const Color leaveUnpaid = Color(0xFF64748B);
  static const Color leaveWfh = Color(0xFFF59E0B);
  static const Color leaveCompOff = Color(0xFF8B5CF6);

  static const HrmColors light = HrmColors(
    isDark: false,
    primary50: Color(0xFFEEF2FF),
    primary500: Color(0xFF4F46E5),
    primary600: Color(0xFF4338CA),
    secondary500: Color(0xFF14B8A6),
    heroFrom: Color(0xFF4F46E5),
    heroTo: Color(0xFF7C3AED),
    bgCanvas: Color(0xFFF8FAFC),
    bgSurface: Color(0xFFFFFFFF),
    bgSurfaceRaised: Color(0xFFFFFFFF),
    bgSubtle: Color(0xFFF1F5F9),
    borderDefault: Color(0xFFE2E8F0),
    borderStrong: Color(0xFFCBD5E1),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textTertiary: Color(0xFF94A3B8),
    textOnPrimary: Color(0xFFFFFFFF),
    success: Color(0xFF16A34A),
    successSoft: Color(0xFFDCFCE7),
    warning: Color(0xFFD97706),
    warningSoft: Color(0xFFFEF3C7),
    danger: Color(0xFFDC2626),
    dangerSoft: Color(0xFFFEE2E2),
    info: Color(0xFF0284C7),
    infoSoft: Color(0xFFE0F2FE),
    neutral: Color(0xFF64748B),
    neutralSoft: Color(0xFFF1F5F9),
  );

  static const HrmColors dark = HrmColors(
    isDark: true,
    primary50: Color(0xFF1E1B4B),
    primary500: Color(0xFF818CF8),
    primary600: Color(0xFFA5B4FC),
    secondary500: Color(0xFF2DD4BF),
    heroFrom: Color(0xFF4338CA),
    heroTo: Color(0xFF6D28D9),
    bgCanvas: Color(0xFF0B0F19),
    bgSurface: Color(0xFF131826),
    bgSurfaceRaised: Color(0xFF1B2133),
    bgSubtle: Color(0xFF1E2536),
    borderDefault: Color(0xFF2A3245),
    borderStrong: Color(0xFF3B455C),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textTertiary: Color(0xFF64748B),
    textOnPrimary: Color(0xFF0B0F19),
    success: Color(0xFF4ADE80),
    successSoft: Color(0xFF052E16),
    warning: Color(0xFFFBBF24),
    warningSoft: Color(0xFF3B2A05),
    danger: Color(0xFFF87171),
    dangerSoft: Color(0xFF3B0A0A),
    info: Color(0xFF38BDF8),
    infoSoft: Color(0xFF082F49),
    neutral: Color(0xFF94A3B8),
    neutralSoft: Color(0xFF1E2536),
  );

  LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [heroFrom, heroTo],
      );

  /// Soft glow used for the blurred mesh blobs behind headers.
  Color blob(Color base) => base.withValues(alpha: isDark ? 0.18 : 0.14);

  @override
  HrmColors copyWith() => this;

  @override
  HrmColors lerp(ThemeExtension<HrmColors>? other, double t) {
    if (other is! HrmColors) return this;
    return t < 0.5 ? this : other;
  }
}

extension HrmThemeContext on BuildContext {
  HrmColors get c => Theme.of(this).extension<HrmColors>()!;
}
