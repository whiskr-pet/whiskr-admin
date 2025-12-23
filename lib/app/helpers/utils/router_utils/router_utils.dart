import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:w_utils/w_utils.dart';

import '../../../../routing/routes.dart';

class RouterUtils {
  RouterUtils._();

  static Future<bool> _isAuthenticated() async {
    try {
      final String userData = await storagePrefs.getValue(StorageKeys.USER_DATA_KEY);
      final String accessToken = await storagePrefs.getAccessTokenValue();
      final String refreshToken = await storagePrefs.getRefreshTokenValue();

      final bool accessExpired = await storagePrefs.isAccessTokenExpired();
      final bool refreshExpired = await storagePrefs.isRefreshTokenExpired();

      debugPrint('[WEB] Auth Check:');
      debugPrint('User data: ${userData.isNotEmpty}');
      debugPrint('Access token: ${accessToken.isNotEmpty} (expired: $accessExpired)');
      debugPrint('Refresh token: ${refreshToken.isNotEmpty} (expired: $refreshExpired)');

      // User is authenticated if they have user data and at least one valid token
      final bool isAuth = userData.isNotEmpty && ((accessToken.isNotEmpty && !accessExpired) || (refreshToken.isNotEmpty && !refreshExpired));

      debugPrint('Result: ${isAuth ? "Authenticated" : "Not authenticated"}');
      return isAuth;
    } catch (e) {
      debugPrint('Auth check error: $e');
      return false;
    }
  }

  static FutureOr<String?> redirect(BuildContext context, GoRouterState state) async {
    if (!kIsWeb) {
      return null;
    }

    final String currentPath = state.matchedLocation;
    debugPrint('Navigation to: $currentPath');

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
  }
}
