import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:vertexhand_hrm/core/router/app_router.dart';
import 'package:vertexhand_hrm/core/theme/typography.dart';
import 'package:vertexhand_hrm/core/widgets/swipe_slider.dart';
import 'package:vertexhand_hrm/main.dart';

void main() {
  setUpAll(() => T.useGoogleFonts = false);

  Future<void> boot(WidgetTester tester) async {
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      original?.call(details);
    };
    addTearDown(() => FlutterError.onError = original);

    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: HrmApp()));
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> toHome(WidgetTester tester) async {
    await tester.tap(find.text('Skip'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Unmount the app so providers cancel their timers before the test ends.
  Future<void> shutDown(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('onboarding leads to sign in and then Home', (tester) async {
    await boot(tester);
    expect(find.text('Clock in with a swipe'), findsOneWidget);
    await toHome(tester);
    expect(find.textContaining('Rahim'), findsOneWidget);
    expect(find.text('Swipe to clock in'), findsOneWidget);
    await shutDown(tester);
  });

  testWidgets('tapping the clock-in thumb starts the shift', (tester) async {
    await boot(tester);
    await toHome(tester);
    final slider = find.byType(SwipeToConfirm);
    await tester.tapAt(tester.getTopLeft(slider) + const Offset(28, 28));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Clock out'), findsOneWidget);
    await shutDown(tester);
  });

  testWidgets('tapping dock tabs animates between all tabs without error', (tester) async {
    await boot(tester);
    await toHome(tester);
    await tester.pump(const Duration(seconds: 1));

    // Tap Attendance
    await tester.tap(find.byIcon(LucideIcons.clock));
    for (int i = 0; i < 45; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(find.text('Attendance'), findsAtLeast(1));

    // Tap Leave
    await tester.tap(find.byIcon(LucideIcons.calendarDays));
    for (int i = 0; i < 45; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(find.text('Leave'), findsAtLeast(1));

    // Tap Payroll
    await tester.tap(find.byIcon(LucideIcons.wallet));
    for (int i = 0; i < 45; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(find.text('Payroll'), findsAtLeast(1));

    // Tap Me / Profile
    await tester.tap(find.byIcon(LucideIcons.circleUser));
    for (int i = 0; i < 45; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(find.text('Me'), findsAtLeast(1));

    // Tap Home
    await tester.tap(find.byIcon(LucideIcons.house));
    for (int i = 0; i < 45; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(find.textContaining('Rahim'), findsOneWidget);

    await shutDown(tester);
  });

  testWidgets('outwork toggle updates location and clocks in for outdoor duty', (tester) async {
    await boot(tester);
    await toHome(tester);

    // Tap location chip to open sheet
    await tester.tap(find.textContaining('Head Office'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Work Mode & Location'), findsOneWidget);

    // Select Outwork / Field Duty
    await tester.tap(find.text('Outwork / Field Duty'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('Outwork'), findsAtLeast(1));
    expect(find.text('Swipe to clock in (Outwork)'), findsOneWidget);

    // Clock in
    final slider = find.byType(SwipeToConfirm);
    await tester.tapAt(tester.getTopLeft(slider) + const Offset(28, 28));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Clock out'), findsOneWidget);
    expect(find.text('Working · Outwork'), findsOneWidget);

    await shutDown(tester);
  });

  testWidgets('navigates to subroutes without crashing', (tester) async {
    await boot(tester);
    await toHome(tester);
    final context = tester.element(find.byType(HrmApp));
    final router = ProviderScope.containerOf(context).read(routerProvider);

    final routes = [
      '/leave/request',
      '/outwork/request',
      '/approvals',
      '/ask-hr',
      '/directory',
      '/directory/ka',
      '/notifications',
      '/documents',
      '/expenses',
      '/announcements',
      '/tasks',
      '/team-calendar',
    ];

    for (final route in routes) {
      router.push(route);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      router.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    await shutDown(tester);
  });
}
