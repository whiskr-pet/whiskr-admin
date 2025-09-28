import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:whiskr_admin_panel/routing/routes.dart';
import 'package:whiskr_admin_panel/app/screens/dashboard_screen/dashboard_screen.dart';
import 'package:whiskr_admin_panel/app/screens/login_screen.dart';
import 'package:whiskr_admin_panel/app/screens/splash_screen.dart';

class RouteGenerator {
  GoRouter get router => _router;

  final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: splashRoute,
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),

      // Login route
      GoRoute(
        path: loginRoute,
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),

      // Dashboard route
      GoRoute(
        path: dashboardRoute,
        name: 'dashboard',
        builder: (BuildContext context, GoRouterState state) {
          return const DashboardScreen();
        },
        redirect: (BuildContext context, GoRouterState state) {
          // Check if user is authenticated
          // final authProvider = Provider.of<AuthProviderForAdmin>(context, listen: false);
          // if (!authProvider.isAuthenticated) {
          // return '/login';
          // }
          return null; // Allow access to dashboard
        },
      ),
    ],
  );
}
