import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/text_fields/wa_custom_text_field.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';
import 'package:whiskr_admin_panel/app/features/settings/providers/edit_profile_provider.dart';
import 'package:whiskr_admin_panel/l10n/app_localizations.dart';

class SettingsEditProfileScreen extends StatelessWidget {
  const SettingsEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider<EditProfileProvider>(
      create: (BuildContext providerContext) {
        final EditProfileProvider provider = EditProfileProvider();

        final String? email = providerContext.read<WAOnboardingProvider>().serviceAdminData.contact?.email;

        provider.setInitialValues(
          businessName: null,
          phoneNumber: null,
          description: null,
          email: email,
          website: null,
        );

        return provider;
      },
      child: Scaffold(
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
                    Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back),
                          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.settingsEditProfile,
                          style: themeData.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: <BoxShadow>[BoxShadow(color: themeData.shadowColor.withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 4))],
                      ),
                      child: Text(
                        l10n.settingsEditProfileComingSoon,
                        style: themeData.textTheme.bodyMedium?.copyWith(color: themeData.colorScheme.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _EditProfileFormCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditProfileFormCard extends StatelessWidget {
  const _EditProfileFormCard();

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final EditProfileProvider provider = context.watch<EditProfileProvider>();

    return AbsorbPointer(
      absorbing: true,
      child: Opacity(
        opacity: 0.6,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: <BoxShadow>[BoxShadow(color: themeData.shadowColor.withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Prepared form (API pending)',
                style: themeData.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: WACustomTextField(
                      controller: provider.businessNameController,
                      label: 'Business name',
                      hint: 'Enter your business name',
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: WACustomTextField(
                      controller: provider.phoneController,
                      label: 'Phone number',
                      hint: 'Enter phone number',
                      isRequired: true,
                      type: WATextFieldType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              WACustomTextField(
                controller: provider.descriptionController,
                label: 'Description',
                hint: 'Describe your business',
                isRequired: true,
                maxLines: 4,
                maxLength: 600,
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: WACustomTextField(
                      controller: provider.emailController,
                      label: 'Email',
                      hint: 'Enter email address',
                      isRequired: true,
                      type: WATextFieldType.email,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: WACustomTextField(
                      controller: provider.websiteController,
                      label: 'Website',
                      hint: 'Enter website URL',
                      isRequired: false,
                      type: WATextFieldType.url,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

