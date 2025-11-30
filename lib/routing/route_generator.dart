import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:w_permissions_module/services/locator.dart';
import 'package:w_permissions_module/services/navigation_service.dart';
import 'package:w_utils/storage_manager/storage_prefs_manager.dart';
import 'package:whiskr_admin_panel/app/screens/dashboard_screen/dashboard_screen.dart';
import 'package:whiskr_admin_panel/app/screens/dashboard_screen/main_layout.dart';
import 'package:whiskr_admin_panel/app/screens/inventory_and_services_screen/inventory_services_screen.dart';
import 'package:whiskr_admin_panel/app/screens/login_screen/login_screen.dart';
import 'package:whiskr_admin_panel/app/screens/onboarding_screen/onboarding_general_info_screen/onboarding_general_info_screen.dart';
import 'package:whiskr_admin_panel/app/screens/onboarding_screen/onboarding_intro_screen/onboarding_intro_screen.dart';
import 'package:whiskr_admin_panel/app/screens/orders_and_appointments_screen/orders_and_appointments_screen.dart';
import 'package:whiskr_admin_panel/app/screens/splash_screen/splash_screen.dart';
import 'package:whiskr_admin_panel/routing/routes.dart';

import '../app/screens/analytics_screen/analytics_screen.dart';

class RouteGenerator {
  GoRouter get router => _router;

  // Helper method to check if user is authenticated (WEB ONLY)
  Future<bool> _isAuthenticated() async {
    try {
      final String userData = await storagePrefs.getValue(StoragePrefsManager.USER_DATA_KEY);
      final String accessToken = await storagePrefs.getAccessTokenValue();
      final String refreshToken = await storagePrefs.getRefreshTokenValue();

      final bool accessExpired = await storagePrefs.isAccessTokenExpired();
      final bool refreshExpired = await storagePrefs.isRefreshTokenExpired();

      debugPrint('🔒 [WEB] Auth Check:');
      debugPrint('   User data: ${userData.isNotEmpty}');
      debugPrint('   Access token: ${accessToken.isNotEmpty} (expired: $accessExpired)');
      debugPrint('   Refresh token: ${refreshToken.isNotEmpty} (expired: $refreshExpired)');

      // User is authenticated if they have user data and at least one valid token
      final bool isAuth = userData.isNotEmpty && ((accessToken.isNotEmpty && !accessExpired) || (refreshToken.isNotEmpty && !refreshExpired));

      debugPrint('   Result: ${isAuth ? "✅ Authenticated" : "❌ Not authenticated"}');
      return isAuth;
    } catch (e) {
      debugPrint('❌ Auth check error: $e');
      return false;
    }
  }

  late final GoRouter _router = GoRouter(
    initialLocation: splashRoute,
    // initialLocation: onboardingIntroRoute,
    navigatorKey: locator<NavigationService>().navigationKey,
    // Global redirect - ONLY RUNS ON WEB for page refresh handling
    redirect: (BuildContext context, GoRouterState state) async {
      if (!kIsWeb) {
        return null;
      }

      final String currentPath = state.matchedLocation;
      debugPrint('[WEB] Navigation to: $currentPath');

      // Public routes that don't need authentication
      final List<String> publicRoutes = [splashRoute, loginRoute];

      // If going to a public route, allow it
      if (publicRoutes.contains(currentPath)) {
        debugPrint('   → Public route, allowing access');
        return null;
      }

      // For all other routes, check authentication
      final bool isAuth = await _isAuthenticated();

      if (!isAuth) {
        debugPrint('   → Not authenticated, redirecting to login');
        return loginRoute;
      }

      // User is authenticated, allow access
      debugPrint('   → Authenticated, allowing access');
      return null;
    },
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
