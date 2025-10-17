import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_authentication/helpers/api_header_helper.dart';
import 'package:w_authentication/providers/authentication_provider.dart';
import 'package:w_network_module/network_manager/network_manager.dart';
import 'package:w_permissions_module/services/locator.dart';
import 'package:w_utils/helper/util_constants.dart';
import 'package:w_utils/providers/theme_provider/whiskr_web_theme/custom_web_themes.dart';
import 'package:w_utils/w_utils.dart';
import 'package:whiskr_admin_panel/app/utils/session_manager.dart';
import 'package:whiskr_admin_panel/routing/route_generator.dart';

import 'config/flavor_config.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/service_provider.dart';

Future<void> initializeApp({required Flavor flavor, required String appName, required String env}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get environment variables from dart-define
  const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'DEVTEST');
  const String flavorString = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  debugPrint('🔗 Environment Variables Loaded:');
  debugPrint('  BASE_URL: $baseUrl');
  debugPrint('  FLAVOR: $flavorString');
  debugPrint('  APP_NAME: $appName');
  debugPrint('  ENV: $env');

  // Initialize FlavorConfig
  FlavorConfig(
    flavor: flavor,
    values: FlavorValues(baseUrl: baseUrl, appName: appName, env: env),
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
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider(), lazy: true),
        ChangeNotifierProvider<ProductProvider>(create: (_) => ProductProvider(), lazy: true),
        ChangeNotifierProvider<OrderProvider>(create: (_) => OrderProvider(), lazy: true),
        ChangeNotifierProvider<ServiceProvider>(create: (_) => ServiceProvider(), lazy: true),
        ChangeNotifierProvider<CustomThemeProvider>(create: (_) => CustomThemeProvider(), lazy: true),
        ChangeNotifierProvider<AuthenticationProvider>(create: (_) => AuthenticationProvider(), lazy: true),
      ],
      child: Consumer<CustomThemeProvider>(
        builder: (context, customThemeProvider, child) {
          return MaterialApp.router(
            title: config.values.appName,
            debugShowCheckedModeBanner: false,
            routerConfig: routeGenerator.router,
            theme: CustomWebThemes.lightTheme,
          );
        },
      ),
    );
  }
}
