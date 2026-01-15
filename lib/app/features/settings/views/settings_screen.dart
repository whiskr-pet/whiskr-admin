import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:whiskr_admin_panel/app/features/settings/widgets/settings_section_card.dart';
import 'package:whiskr_admin_panel/app/features/settings/widgets/settings_tile.dart';
import 'package:whiskr_admin_panel/app/helpers/session_manager.dart';
import 'package:whiskr_admin_panel/app/providers/locale_provider.dart';
import 'package:whiskr_admin_panel/app/providers/theme_mode_provider.dart';
import 'package:whiskr_admin_panel/l10n/app_localizations.dart';
import 'package:whiskr_admin_panel/routing/routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;

    final ThemeMode selectedThemeMode = context.select<ThemeModeProvider, ThemeMode>((ThemeModeProvider p) => p.themeMode);
    final Locale? selectedLocale = context.select<LocaleProvider, Locale?>((LocaleProvider p) => p.locale);

    final String themeValueText = _SettingsThemeModeLabel(themeMode: selectedThemeMode).resolve(l10n);
    final String localeValueText = _SettingsLocaleLabel(locale: selectedLocale).resolve(l10n);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 24,
              horizontal: Responsive.value(context: context, mobile: 16.0, tablet: 60.0, desktop: 120.0, widescreen: 200.0),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    l10n.settingsTitle,
                    style: themeData.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                  SettingsSectionCard(
                    title: l10n.settingsSectionAccount,
                    children: <Widget>[
                      SettingsTile(
                        iconData: Icons.person_outline,
                        title: l10n.settingsProfile,
                        onTap: () => context.go(settingsProfileRoute),
                      ),
                      SettingsTile(
                        iconData: Icons.edit_outlined,
                        title: l10n.settingsEditProfile,
                        subtitle: l10n.settingsEditProfileComingSoon,
                        onTap: () => context.go(settingsEditProfileRoute),
                        showDivider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SettingsSectionCard(
                    title: l10n.settingsSectionAppearance,
                    children: <Widget>[
                      SettingsTile(
                        iconData: Icons.dark_mode_outlined,
                        title: l10n.settingsTheme,
                        valueText: themeValueText,
                        onTap: () => _openThemePicker(context),
                      ),
                      SettingsTile(
                        iconData: Icons.language_outlined,
                        title: l10n.settingsLanguage,
                        valueText: localeValueText,
                        onTap: () => _openLocalePicker(context),
                        showDivider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SettingsSectionCard(
                    title: l10n.settingsSectionSecurity,
                    children: <Widget>[
                      SettingsTile(
                        iconData: Icons.logout,
                        title: l10n.settingsLogout,
                        isDestructive: true,
                        onTap: () => _confirmAndLogout(context),
                        showDivider: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openThemePicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return const _ThemeModePickerBottomSheet();
      },
    );
  }

  Future<void> _openLocalePicker(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return const _LocalePickerBottomSheet();
      },
    );
  }

  Future<void> _confirmAndLogout(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.settingsLogoutConfirmTitle),
          content: Text(l10n.settingsLogoutConfirmBody),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.settingsCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.settingsConfirm),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await SessionManager.instance.logout();
  }
}

class _ThemeModePickerBottomSheet extends StatelessWidget {
  const _ThemeModePickerBottomSheet();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeMode selectedThemeMode = context.select<ThemeModeProvider, ThemeMode>((ThemeModeProvider p) => p.themeMode);
    final ThemeData themeData = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: RadioGroup<ThemeMode>(
          groupValue: selectedThemeMode,
          onChanged: (ThemeMode? value) async {
            if (value == null) {
              return;
            }
            await context.read<ThemeModeProvider>().setThemeMode(value);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(l10n.settingsTheme, style: themeData.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.system,
                title: Text(l10n.settingsThemeSystem),
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.light,
                title: Text(l10n.settingsThemeLight),
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.dark,
                title: Text(l10n.settingsThemeDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocalePickerBottomSheet extends StatelessWidget {
  const _LocalePickerBottomSheet();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final Locale? selectedLocale = context.select<LocaleProvider, Locale?>((LocaleProvider p) => p.locale);
    final String selectedLanguageCode = selectedLocale?.languageCode ?? '';
    final ThemeData themeData = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: RadioGroup<String>(
          groupValue: selectedLanguageCode,
          onChanged: (String? value) async {
            if (value == null) {
              return;
            }
            if (value == 'bs') {
              await context.read<LocaleProvider>().setLocale(const Locale('bs'));
            } else {
              await context.read<LocaleProvider>().setLocale(const Locale('en'));
            }
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(l10n.settingsLanguage, style: themeData.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              ),
              RadioListTile<String>(
                value: 'en',
                title: Text(l10n.settingsLocaleEnglish),
              ),
              RadioListTile<String>(
                value: 'bs',
                title: Text(l10n.settingsLocaleBosnian),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsThemeModeLabel {
  final ThemeMode themeMode;

  const _SettingsThemeModeLabel({required this.themeMode});

  String resolve(AppLocalizations l10n) {
    switch (themeMode) {
      case ThemeMode.system:
        return l10n.settingsThemeSystem;
      case ThemeMode.light:
        return l10n.settingsThemeLight;
      case ThemeMode.dark:
        return l10n.settingsThemeDark;
    }
  }
}

class _SettingsLocaleLabel {
  final Locale? locale;

  const _SettingsLocaleLabel({required this.locale});

  String resolve(AppLocalizations l10n) {
    final String? languageCode = locale?.languageCode;
    if (languageCode == 'bs') {
      return l10n.settingsLocaleBosnian;
    }
    return l10n.settingsLocaleEnglish;
  }
}

