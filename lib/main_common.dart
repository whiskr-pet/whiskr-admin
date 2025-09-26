import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_network_module/network_manager/network_manager.dart';
import 'config/flavor_config.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/service_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

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

  try {
    NetworkManager.instance.initialize(
      baseUrl: baseUrl,
      aiServiceBaseUrl: '',
      openWeatherBaseUrl: '',
      refreshPath: '/auth/refresh', // Adjust as needed
      autoAttachAuthHeader: true,
      defaultAccessTtl: const Duration(minutes: 30),
      defaultRefreshTtl: const Duration(days: 7),
      onRefreshFailed: () {
        debugPrint('Refresh token failed');
      },
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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
      ],
      child: MaterialApp(
        title: config.values.appName,
        debugShowCheckedModeBanner: !FlavorConfig.isProduction(),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const SplashScreen(),
        // Show flavor banner in non-production builds
        builder: (context, child) {
          if (FlavorConfig.isProduction()) {
            return child!;
          }
          return Banner(
            message: config.values.env.toUpperCase(),
            location: BannerLocation.topEnd,
            color: FlavorConfig.isDevelopment() ? Colors.green : Colors.orange,
            child: child!,
          );
        },
      ),
    );
  }
}
