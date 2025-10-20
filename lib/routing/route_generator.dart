import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:w_permissions_module/services/locator.dart';
import 'package:w_permissions_module/services/navigation_service.dart';
import 'package:whiskr_admin_panel/app/screens/analytics_screen.dart';
import 'package:whiskr_admin_panel/app/screens/dashboard_screen/dashboard_screen.dart';
import 'package:whiskr_admin_panel/app/screens/inventory_screen.dart';
import 'package:whiskr_admin_panel/app/screens/login_screen/login_screen.dart';
import 'package:whiskr_admin_panel/app/screens/dashboard_screen/main_layout.dart';
import 'package:whiskr_admin_panel/app/screens/onboarding_screen/onboarding_general_info_screen/onboarding_general_info_screen.dart';
import 'package:whiskr_admin_panel/app/screens/onboarding_screen/onboarding_intro_screen/onboarding_intro_screen.dart';
import 'package:whiskr_admin_panel/app/screens/orders_screen.dart';
import 'package:whiskr_admin_panel/app/screens/services_screen.dart';
import 'package:whiskr_admin_panel/app/screens/splash_screen/splash_screen.dart';
import 'package:whiskr_admin_panel/routing/routes.dart';

class RouteGenerator {
  GoRouter get router => _router;

  final GoRouter _router = GoRouter(
    // initialLocation: splashRoute,
    initialLocation: onboardingIntroRoute,
    navigatorKey: locator<NavigationService>().navigationKey,
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
              return const InventoryScreen();
            },
          ),
          GoRoute(
            path: ordersRoute,
            name: 'orders',
            builder: (BuildContext context, GoRouterState state) {
              return const OrdersScreen();
            },
          ),
          GoRoute(
            path: servicesRoute,
            name: 'services',
            builder: (BuildContext context, GoRouterState state) {
              return const ServicesScreen();
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
              return const Scaffold(body: Center(child: Text('Users Management - Coming Soon')));
            },
          ),
          GoRoute(
            path: settingsRoute,
            name: 'settings',
            builder: (BuildContext context, GoRouterState state) {
              return const Scaffold(body: Center(child: Text('Settings - Coming Soon')));
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
    ],
  );
}
