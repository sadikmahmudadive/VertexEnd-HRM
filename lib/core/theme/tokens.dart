import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// Spacing scale (4 pt base) from the HRM design system.
abstract final class Sp {
  static const double s0 = 0;
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
}

/// Radius scale.
abstract final class Rd {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double full = 999;

  static BorderRadius get rXs => BorderRadius.circular(xs);
  static BorderRadius get rSm => BorderRadius.circular(sm);
  static BorderRadius get rMd => BorderRadius.circular(md);
  static BorderRadius get rLg => BorderRadius.circular(lg);
  static BorderRadius get rXl => BorderRadius.circular(xl);
  static BorderRadius get rFull => BorderRadius.circular(full);
  static const BorderRadius sheetTop =
      BorderRadius.vertical(top: Radius.circular(xl));
}

/// Component sizes.
abstract final class Sz {
  static const double touchMin = 44;
  static const double buttonLg = 52;
  static const double buttonMd = 44;
  static const double buttonSm = 36;
  static const double input = 52;
  static const double tabBar = 68;
  static const double fab = 56;
  static const double glassBlur = 24;
  static const double glassOpacity = 0.72;
  static const double disabledOpacity = 0.4;
  static const double scrimOpacity = 0.4;
}

/// Motion tokens.
abstract final class Motion {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration base = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
  static const Curve standard = Cubic(0.2, 0.8, 0.2, 1);
  static const Curve spring = Cubic(0.2, 0.9, 0.25, 1.05);
}
