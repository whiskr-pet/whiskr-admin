import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:w_authentication/helpers/api_header_helper.dart';
import 'package:w_authentication/providers/authentication_provider.dart';
import 'package:w_dashboard/providers/dashboard_provider.dart';
import 'package:w_image_module/providers/image_provider.dart';
import 'package:w_network_module/network_manager/network_manager.dart';
import 'package:w_permissions_module/services/locator.dart';
import 'package:w_utils/helper/util_constants.dart';
import 'package:w_utils/w_utils.dart';
import 'package:wa_analytics_module/providers/wa_analytics_provider.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_providers/wa_inventory_services_provider.dart';
import 'package:wa_inventory_services_module/providers/wa_services_providers/wa_services_provider.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';
import 'package:wa_onboarding_module/providers/wa_service_profile_provider.dart';
import 'package:wa_orders_appointments_module/providers/orders_providers/wa_orders_provider.dart';
import 'package:whiskr_admin_panel/app/helpers/session_manager.dart';
import 'package:whiskr_admin_panel/app/providers/locale_provider.dart';
import 'package:whiskr_admin_panel/app/providers/theme_mode_provider.dart';
import 'package:whiskr_admin_panel/app/providers/texts_provider.dart';
import 'package:whiskr_admin_panel/app/theme/whiskr_themes.dart';
import 'package:whiskr_admin_panel/routing/route_generator.dart';

import 'config/flavor_config.dart';
import 'l10n/app_localizations.dart';
import 'localization_models/localization_models.dart';

Future<void> initializeApp({required Flavor flavor, required String appName, required String env, required String dotEnvFile}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: dotEnvFile);

  // Get environment variables from .env file
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'DEVTEST';
  final String flavorString = dotenv.env['FLAVOR'] ?? 'dev';
  final String mapboxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? 'NOTOKEN';

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
        ChangeNotifierProvider<WAServiceProfileProvider>(create: (_) => WAServiceProfileProvider(), lazy: true),
        ChangeNotifierProvider<ImageHandleProvider>(create: (_) => ImageHandleProvider(), lazy: true),
        ChangeNotifierProvider<WAInventoryServicesProvider>(create: (_) => WAInventoryServicesProvider(), lazy: true),
        ChangeNotifierProvider<WAServicesProvider>(create: (_) => WAServicesProvider(), lazy: true),
        ChangeNotifierProvider<WaOrdersProvider>(create: (_) => WaOrdersProvider(), lazy: true),
        ChangeNotifierProvider<WAAnalyticsProvider>(create: (_) => WAAnalyticsProvider(), lazy: true),
        ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider(), lazy: true),
        ChangeNotifierProvider<ThemeModeProvider>(create: (_) => ThemeModeProvider(), lazy: true),
      ],
      child: Consumer3<CustomThemeProvider, LocaleProvider, ThemeModeProvider>(
        builder: (BuildContext context, CustomThemeProvider customThemeProvider, LocaleProvider localeProvider, ThemeModeProvider themeModeProvider, Widget? child) {
          return MaterialApp.router(
            title: config.values.appName,
            debugShowCheckedModeBanner: false,
            routerConfig: routeGenerator.router,
            theme: WhiskrThemes.lightTheme(),
            darkTheme: WhiskrThemes.darkTheme(),
            themeMode: themeModeProvider.themeMode,
            locale: localeProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            builder: (BuildContext context, Widget? child) {
              return TextsProvider(
                loginTexts: LoginTexts(context),
                onboardingTexts: OnboardingTexts(context),
                inventoryTexts: InventoryTexts(context),
                serviceOfferedText: ServiceOfferedText(context),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
