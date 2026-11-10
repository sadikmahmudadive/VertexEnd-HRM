import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'typography.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(HrmColors.light, Brightness.light);
  static ThemeData dark() => _build(HrmColors.dark, Brightness.dark);

  static ThemeData _build(HrmColors c, Brightness b) {
    final scheme = ColorScheme(
      brightness: b,
      primary: c.primary500,
      onPrimary: c.textOnPrimary,
      secondary: c.secondary500,
      onSecondary: c.textOnPrimary,
      error: c.danger,
      onError: c.textOnPrimary,
      surface: c.bgSurface,
      onSurface: c.textPrimary,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bgCanvas,
      canvasColor: c.bgCanvas,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerColor: c.borderDefault,
      extensions: [c],
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      }),
      appBarTheme: AppBarTheme(
        backgroundColor: c.bgCanvas,
        elevation: 0,
        systemOverlayStyle:
            b == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.primary500,
        selectionColor: c.primary500.withValues(alpha: 0.25),
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: c.textPrimary,
        displayColor: c.textPrimary,
        fontFamily: T.body.fontFamily,
      ),
    );
  }
}
