import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_authentication/w_authentication.dart';
import 'package:w_utils/w_utils.dart';
import 'package:whiskr_admin_panel/routing/routes.dart';

class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  // Add a flag to prevent multiple simultaneous logout attempts
  bool _isHandlingExpiry = false;

  VoidCallback createRefreshFailedCallback() =>
      () => Future<void>.microtask(() => handleSessionExpired(fromRefreshFailure: true));

  Future<void> handleSessionExpired({bool fromRefreshFailure = false}) async {
    // Prevent multiple simultaneous logout attempts
    if (_isHandlingExpiry) {
      debugPrint('Session expiry already being handled, skipping...');
      return;
    }

    _isHandlingExpiry = true;

    try {
      debugPrint('Handling session expiry - fromRefreshFailure: $fromRefreshFailure');

      // Get current context from the router delegate
      final BuildContext? context = _getCurrentContext();

      if (context != null && context.mounted) {
        try {
          final AuthenticationProvider auth = Provider.of<AuthenticationProvider>(context, listen: false);
          final ResponseModel<String> result = await auth.userLogout();
          if (result.isSuccess) {
            await _navigateToLogin(context);
            return;
          }
        } catch (e) {
          debugPrint('Logout failed: $e');
        }
      }

      await _localClearAndNavigate();
    } finally {
      _isHandlingExpiry = false;
    }
  }

  Future<void> logout() async {
    await handleSessionExpired(fromRefreshFailure: false);
  }

  Future<void> _localClearAndNavigate() async {
    try {
      // Clear web storage (localStorage/sessionStorage)
      await _clearWebStorage();
    } catch (e) {
      debugPrint('Error clearing web storage: $e');
    }

    try {
      // Clear authentication tokens
      await storagePrefs.deleteAll();
    } catch (e) {
      debugPrint('Error clearing tokens: $e');
    }

    // Navigate to login
    final BuildContext? context = _getCurrentContext();
    if (context != null && context.mounted) {
      await _navigateToLogin(context);
    }
  }

  Future<void> _navigateToLogin(BuildContext context) async {
    try {
      if (context.mounted) {
        context.go(loginRoute, extra: {'clearHistory': true});
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }

  BuildContext? _getCurrentContext() {
    // For GoRouter, we need to access the current context differently
    try {
      // Try to get the current router delegate context
      final router = GoRouter.maybeOf(WidgetsBinding.instance.rootElement!);
      if (router != null) {
        return router.routerDelegate.navigatorKey.currentContext;
      }
      return null;
    } catch (e) {
      debugPrint('Could not get current context: $e');
      return null;
    }
  }

  Future<void> _clearWebStorage() async {
    try {
      // Clear localStorage and sessionStorage for web
      // This is web-specific storage clearing
      await storagePrefs.deleteAll();
    } catch (e) {
      debugPrint('Error clearing web storage: $e');
    }
  }
}

// Centralizes logout/session-expiry handling for Flutter Web.
// Uses GoRouter for navigation, clears web storage, and handles
// session expiry without requiring additional navigator keys. (danispreldzic)
