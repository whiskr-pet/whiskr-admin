import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_authentication/providers/authentication_provider.dart';
import 'package:whiskr_admin_panel/routing/routes.dart';

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait a bit for splash effect
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      // Check if user is authenticated
      final AuthenticationProvider auth = Provider.of<AuthenticationProvider>(context, listen: false);

      // Check if user is authenticated (has valid email)
      if (auth.userModel.email != null && auth.userModel.email!.isNotEmpty) {
        // User is authenticated, go to dashboard
        if (mounted) {
          context.go(dashboardRoute);
        }
      } else {
        // User is NOT authenticated, go to login
        if (mounted) {
          context.go(loginRoute);
        }
      }
    } catch (e) {
      debugPrint('Auth check error: $e');
      // On any error, go to login
      if (mounted) {
        context.go(loginRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Image.asset('assets/images/appicon.png'),
            ),
            const SizedBox(height: 32),

            // App Name
            const Text(
              'Whiskr Admin',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)), strokeWidth: 3),
          ],
        ),
      ),
    );
  }
}
