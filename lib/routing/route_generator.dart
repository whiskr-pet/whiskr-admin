import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:w_permissions_module/services/locator.dart';
import 'package:w_permissions_module/services/navigation_service.dart';
import 'package:whiskr_admin_panel/app/helpers/utils/router_utils/router_utils.dart';
import 'package:whiskr_admin_panel/app/screens/dashboard_screen/dashboard_screen.dart';
import 'package:whiskr_admin_panel/app/screens/dashboard_screen/main_layout.dart';
import 'package:whiskr_admin_panel/app/screens/inventory_and_services_screen/inventory_services_screen.dart';
import 'package:whiskr_admin_panel/app/screens/login_screen/login_screen.dart';
import 'package:whiskr_admin_panel/app/screens/onboarding_screen/onboarding_general_info_screen/onboarding_general_info_screen.dart';
import 'package:whiskr_admin_panel/app/screens/onboarding_screen/onboarding_intro_screen/onboarding_intro_screen.dart';
import 'package:whiskr_admin_panel/app/screens/onboarding_screen/onboarding_summary_screen/onboarding_summary_screen.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/orders_and_appointments_screen.dart';
import 'package:whiskr_admin_panel/app/screens/splash_screen/splash_screen.dart';
import 'package:whiskr_admin_panel/features/calendar/calendar_screen.dart';
import 'package:whiskr_admin_panel/routing/routes.dart';

import '../app/screens/analytics_screen/analytics_screen.dart';
import '../app/screens/settings/views/profile/settings_edit_profile_screen.dart';
import '../app/screens/settings/views/settings_screen.dart';

class RouteGenerator {
  GoRouter get router => _router;

  late final GoRouter _router = GoRouter(
    initialLocation: splashRoute,
    navigatorKey: locator<NavigationService>().navigationKey,
    redirect: (BuildContext context, GoRouterState state) async =>
        RouterUtils.redirect(context, state),
    routes: <RouteBase>[
      // Shell route wraps all authenticated admin routes with MainLayout
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: dashboardRoute,
            name: 'dashboard',
            builder: (BuildContext context, GoRouterState state) {
              return const DashboardScreen();
            },
          ),
          GoRoute(
            path: inventoryRoute,
            name: 'inventory',
            builder: (BuildContext context, GoRouterState state) {
              return const InventoryServicesScreen();
            },
          ),
          GoRoute(
            path: ordersRoute,
            name: 'orders',
            builder: (BuildContext context, GoRouterState state) {
              return const OrdersAndAppointmentsScreen();
            },
          ),
          GoRoute(
            path: calendarRoute,
            name: 'calendar',
            builder: (BuildContext context, GoRouterState state) {
              return const CalendarScreen();
            },
          ),
          GoRoute(
            path: analyticsRoute,
            name: 'analytics',
            builder: (BuildContext context, GoRouterState state) {
              return const AnalyticsScreen();
            },
          ),
          GoRoute(
            path: usersRoute,
            name: 'users',
            builder: (BuildContext context, GoRouterState state) {
              return const Scaffold(
                body: Center(child: Text('Users Management - Coming Soon')),
              );
            },
          ),
          GoRoute(
            path: settingsRoute,
            name: 'settings',
            builder: (BuildContext context, GoRouterState state) {
              return const SettingsScreen();
            },
          ),
          GoRoute(
            path: settingsEditProfileRoute,
            name: 'settings-edit-profile',
            builder: (BuildContext context, GoRouterState state) {
              return const SettingsEditProfileScreen();
            },
          ),
        ],
      ),
      // Routes outside the shell (no side menu)
      GoRoute(
        path: splashRoute,
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) {
          return const CustomSplashScreen();
        },
      ),
      GoRoute(
        path: loginRoute,
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: onboardingIntroRoute,
        name: 'onboarding-intro',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingIntroScreen();
        },
      ),
      GoRoute(
        path: onboardingGeneralInfoRoute,
        name: 'onboarding-general-info',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingGeneralInfoScreen();
        },
      ),
      GoRoute(
        path: onboardingSummaryRoute,
        name: 'onboarding-summary',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingSummaryScreen();
        },
      ),
    ],
  );
}
