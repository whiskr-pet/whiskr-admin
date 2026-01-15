import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:w_utils/providers/splash_provider/splash_provider.dart';
import 'package:whiskr_admin_panel/app/helpers/loading_animation_helper.dart';
import 'package:whiskr_admin_panel/gen/assets.gen.dart';
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
    SplashProvider(
      defaultRoute: loginRoute,
      homeRoute: dashboardRoute,
      onboardingRoute: onboardingGeneralInfoRoute,
      onNavigate: (String route) {
        if (mounted) {
          debugPrint('[WEB] Splash navigating to: $route');
          context.go(route);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: themeData.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: themeData.shadowColor.withValues(alpha: 0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset(Assets.images.appicon.path),
            ),
            const SizedBox(height: 32),
            LoadingAnimationHelper.loading,
          ],
        ),
      ),
    );
  }
}
