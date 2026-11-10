import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type scale from the design system (Inter).
abstract final class T {
  /// Tests set this to false so no font is fetched over the network.
  static bool useGoogleFonts = true;

  static TextStyle _s(double size, double line, FontWeight w, [double ls = 0]) {
    final base = TextStyle(
      fontSize: size,
      height: line / size,
      fontWeight: w,
      letterSpacing: ls,
    );
    if (!useGoogleFonts) return base;
    return GoogleFonts.inter(
      fontSize: size,
      height: line / size,
      fontWeight: w,
      letterSpacing: ls,
    );
  }

  static TextStyle get display => _s(34, 40, FontWeight.w700, -0.5);
  static TextStyle get h1 => _s(28, 34, FontWeight.w700, -0.4);
  static TextStyle get h2 => _s(22, 28, FontWeight.w600, -0.2);
  static TextStyle get h3 => _s(18, 24, FontWeight.w600, -0.1);
  static TextStyle get bodyLg => _s(17, 24, FontWeight.w400);
  static TextStyle get body => _s(15, 22, FontWeight.w400);
  static TextStyle get bodyStrong => _s(15, 22, FontWeight.w600);
  static TextStyle get label => _s(14, 20, FontWeight.w500, 0.1);
  static TextStyle get caption => _s(12, 16, FontWeight.w500, 0.2);
  static TextStyle get overline => _s(11, 14, FontWeight.w600, 0.8);
}

extension TextStyleX on TextStyle {
  TextStyle col(Color c) => copyWith(color: c);
  TextStyle get tnum =>
      copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
  TextStyle weight(FontWeight w) => copyWith(fontWeight: w);
  TextStyle size(double s) => copyWith(fontSize: s, height: (s * 1.4) / s);
}
