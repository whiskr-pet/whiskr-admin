import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_authentication/helpers/api_header_helper.dart';
import 'package:w_authentication/providers/authentication_provider.dart';
import 'package:w_dashboard/providers/dashboard_provider.dart';
import 'package:w_image_module/providers/image_provider.dart';
import 'package:w_network_module/network_manager/network_manager.dart';
import 'package:w_permissions_module/services/locator.dart';
import 'package:w_utils/helper/util_constants.dart';
import 'package:w_utils/providers/theme_provider/whiskr_web_theme/custom_web_themes.dart';
import 'package:w_utils/w_utils.dart';
import 'package:wa_analytics_module/providers/wa_analytics_provider.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_services_provider.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';
import 'package:whiskr_admin_panel/app/utils/session_manager.dart';
import 'package:whiskr_admin_panel/routing/route_generator.dart';

import 'config/flavor_config.dart';

Future<void> initializeApp({required Flavor flavor, required String appName, required String env}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get environment variables from dart-define
  const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'DEVTEST');
  const String flavorString = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  const String mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN', defaultValue: 'NOTOKEN');

  debugPrint('🔗 Environment Variables Loaded:');
  debugPrint('  BASE_URL: $baseUrl');
  debugPrint('  FLAVOR: $flavorString');
  debugPrint('  APP_NAME: $appName');
  debugPrint('  ENV: $env');
  debugPrint('  MAPBOX_ACCESS_TOKEN: $mapboxAccessToken');

  // Initialize FlavorConfig
  FlavorConfig(
    flavor: flavor,
    values: FlavorValues(baseUrl: baseUrl, appName: appName, env: env, mapboxAccessToken: mapboxAccessToken),
  );

  await storagePrefs.init();
  storagePrefs.deleteAll();
  setupLocator(methodChannel: AppConstants.methodChannel);

  try {
    NetworkManager.instance.initialize(
      baseUrl: baseUrl,
      aiServiceBaseUrl: '',
      openWeatherBaseUrl: '',
      refreshPath: ApiPathHelperAuthentication.getValue(ApiPathAuthentication.refreshToken),
      autoAttachAuthHeader: true,
      defaultAccessTtl: const Duration(minutes: 30),
      defaultRefreshTtl: const Duration(days: 7),
      onRefreshFailed: SessionManager.instance.createRefreshFailedCallback(),
    );
  } catch (e) {
    debugPrint('NetworkManager initialization error: $e');
  }
}

class WhiskrAdminApp extends StatelessWidget {
  const WhiskrAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final FlavorConfig config = FlavorConfig.instance;
    final RouteGenerator routeGenerator = RouteGenerator();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CustomThemeProvider>(create: (_) => CustomThemeProvider(), lazy: true),
        ChangeNotifierProvider<AuthenticationProvider>(create: (_) => AuthenticationProvider(), lazy: true),
        ChangeNotifierProvider<DashboardProvider>(create: (_) => DashboardProvider(), lazy: true),
        ChangeNotifierProvider<WAOnboardingProvider>(create: (_) => WAOnboardingProvider(), lazy: true),
        ChangeNotifierProvider<ImageHandleProvider>(create: (_) => ImageHandleProvider(), lazy: true),
        ChangeNotifierProvider<WAInventoryServicesProvider>(create: (_) => WAInventoryServicesProvider(), lazy: true),
        ChangeNotifierProvider<WAAnalyticsProvider>(create: (_) => WAAnalyticsProvider(), lazy: true),
      ],
      child: Consumer<CustomThemeProvider>(
        builder: (context, customThemeProvider, child) {
          return MaterialApp.router(title: config.values.appName, debugShowCheckedModeBanner: false, routerConfig: routeGenerator.router, theme: CustomWebThemes.lightTheme);
        },
      ),
    );
  }
}
