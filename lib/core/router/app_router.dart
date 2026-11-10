import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/announcements/announcements_screen.dart';
import '../../features/approvals/approvals_screen.dart';
import '../../features/ask_hr/ask_hr_screen.dart';
import '../../features/attendance/attendance_screen.dart';
import '../../features/attendance/outwork_request_sheet.dart';
import '../../features/auth/sign_in_screen.dart';
import '../../features/directory/directory_screen.dart';
import '../../features/directory/employee_screen.dart';
import '../../features/documents/documents_screen.dart';
import '../../features/expenses/expenses_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../../features/team_calendar/team_calendar_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/leave/leave_request_sheet.dart';
import '../../features/leave/leave_screen.dart';
import '../../features/leave/leave_sent_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/payroll/payroll_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../state/app_state.dart';
import '../ui.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/signin', builder: (_, _) => const SignInScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/attendance', builder: (_, _) => const AttendanceScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/leave', builder: (_, _) => const LeaveScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/payroll', builder: (_, _) => const PayrollScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          ]),
        ],
      ),
      GoRoute(
        path: '/leave/request',
        parentNavigatorKey: _rootKey,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black.withValues(alpha: Sz.scrimOpacity),
          transitionDuration: const Duration(milliseconds: 450),
          child: const LeaveRequestSheet(),
          transitionsBuilder: (context, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      ),
      GoRoute(
        path: '/leave/sent',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const LeaveSentScreen(),
      ),
      GoRoute(
        path: '/outwork/request',
        parentNavigatorKey: _rootKey,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black.withValues(alpha: Sz.scrimOpacity),
          transitionDuration: const Duration(milliseconds: 450),
          child: const OutworkRequestSheet(),
          transitionsBuilder: (context, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      ),
      GoRoute(
          path: '/approvals',
          parentNavigatorKey: _rootKey,
          builder: (_, _) => const ApprovalsScreen()),
      GoRoute(
          path: '/ask-hr',
          parentNavigatorKey: _rootKey,
          builder: (_, _) => const AskHrScreen()),
      GoRoute(
        path: '/directory',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const DirectoryScreen(),
        routes: [
          GoRoute(
            path: ':id',
            parentNavigatorKey: _rootKey,
            builder: (_, state) => EmployeeScreen(id: state.pathParameters['id'] ?? ''),
          ),
        ],
      ),
      GoRoute(
          path: '/notifications',
          parentNavigatorKey: _rootKey,
          builder: (_, _) => const NotificationsScreen()),
      GoRoute(
          path: '/documents',
          parentNavigatorKey: _rootKey,
          builder: (_, _) => const DocumentsScreen()),
      GoRoute(
          path: '/expenses',
          parentNavigatorKey: _rootKey,
          builder: (_, _) => const ExpensesScreen()),
      GoRoute(
          path: '/announcements',
          parentNavigatorKey: _rootKey,
          builder: (_, _) => const AnnouncementsScreen()),
      GoRoute(
          path: '/tasks',
          parentNavigatorKey: _rootKey,
          builder: (_, _) => const TasksScreen()),
      GoRoute(
          path: '/team-calendar',
          parentNavigatorKey: _rootKey,
          builder: (_, _) => const TeamCalendarScreen()),
    ],
  );
});

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingApprovalsProvider);
    return Scaffold(
      backgroundColor: context.c.bgCanvas,
      body: Stack(
        children: [
          shell,
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingDock(
              index: shell.currentIndex,
              onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
              items: [
                const DockItem(LucideIcons.house, 'Home'),
                const DockItem(LucideIcons.clock, 'Attendance'),
                DockItem(LucideIcons.calendarDays, 'Leave', badge: 0 * pending),
                const DockItem(LucideIcons.wallet, 'Payroll'),
                const DockItem(LucideIcons.circleUser, 'Me'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
