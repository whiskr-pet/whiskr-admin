import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:w_components/buttons/common_button.dart';
import 'package:w_components/wa_map_picker/wa_map_picker.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:wa_map_module/wa_map_module.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';
import 'package:whiskr_admin_panel/app/helpers/loading_animation_helper.dart';
import 'package:whiskr_admin_panel/app/helpers/ui_organization_helper/onboarding_organization_helper.dart';
import 'package:whiskr_admin_panel/app/helpers/utils/onboarding_utils/onboarding_action_utils.dart';
import 'package:whiskr_admin_panel/gen/assets.gen.dart';
import 'package:whiskr_admin_panel/l10n/models/localized_texts.dart';
import 'package:whiskr_admin_panel/routing/routes.dart';

import '../../../../config/flavor_config.dart';
import '../../../providers/texts_provider.dart';

class OnboardingSummaryScreen extends StatelessWidget {
  const OnboardingSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: ColorHelper.grey100.color, body: const _BuildSummaryBody());
  }
}

class _BuildSummaryBody extends StatelessWidget {
  const _BuildSummaryBody();

  @override
  Widget build(BuildContext context) {
    final WAOnboardingProvider onboardingProvider = context.read<WAOnboardingProvider>();
    final OnboardingHelper onboardingHelper = OnboardingHelper();
    final OnboardingTexts onboardingTexts = TextsProvider.of(context)!.onboardingTexts;

    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: EdgeInsets.all(Responsive.value(context: context, mobile: 16, tablet: 24, desktop: 32)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _BuildPageHeader(texts: onboardingTexts),
                      const SizedBox(height: 24),
                      _BuildHighlightsStrip(provider: onboardingProvider),
                      const SizedBox(height: 24),
                      _BuildBusinessProfileCard(provider: onboardingProvider, texts: onboardingTexts),
                      const SizedBox(height: 24),
                      ResponsiveBuilder(
                        mobile: Column(
                          children: <Widget>[
                            _BuildInfoCard(
                              title: onboardingTexts.summaryTitleGeneralInfo,
                              icon: Icons.business_center_outlined,
                              infoRows: onboardingHelper.generalInfoRow(onboardingProvider),
                              currentStep: 0,
                            ),
                            const SizedBox(height: 16),
                            _BuildInfoCard(
                              title: onboardingTexts.summaryTitleLocation,
                              icon: Icons.location_on_outlined,
                              infoRows: onboardingHelper.locationInfoRow(onboardingProvider),
                              currentStep: 1,
                            ),
                            const SizedBox(height: 16),
                            _BuildInfoCard(
                              title: onboardingTexts.summaryTitleWorkingHours,
                              icon: Icons.access_time,
                              infoRows: onboardingHelper.hoursInfoRow(onboardingProvider, context),
                              currentStep: 2,
                            ),
                          ],
                        ),
                        desktop: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 260),
                                child: _BuildInfoCard(
                                  title: onboardingTexts.summaryTitleGeneralInfo,
                                  icon: Icons.business_center_outlined,
                                  infoRows: onboardingHelper.generalInfoRow(onboardingProvider),
                                  currentStep: 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 260),
                                child: _BuildInfoCard(
                                  title: onboardingTexts.summaryTitleLocation,
                                  icon: Icons.location_on_outlined,
                                  infoRows: onboardingHelper.locationInfoRow(onboardingProvider),
                                  currentStep: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (onboardingProvider.imageBytesListForServiceUpload.isNotEmpty) ...<Widget>[_BuildServiceImagesCard(provider: onboardingProvider), const SizedBox(height: 24)],
                      _BuildInfoCard(title: onboardingTexts.summaryTitleWorkingHours, icon: Icons.access_time, infoRows: onboardingHelper.hoursInfoRow(onboardingProvider, context), currentStep: 2),
                      const SizedBox(height: 24),
                      _BuildMapCard(),
                      const SizedBox(height: 32),
                      _BuildActionButtons(context: context, texts: onboardingTexts),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Selector<WAOnboardingProvider, bool>(
            selector: (BuildContext _, provider) => provider.isLoading,
            builder: (BuildContext context, bool isLoading, Widget? child) {
              if (!isLoading) {
                return const SizedBox.shrink();
              }
              return LoadingAnimationHelper.instance.loadingAnimation();
            },
          ),
        ],
      ),
    );
  }
}

class _BuildPageHeader extends StatelessWidget {
  const _BuildPageHeader({required this.texts});

  final OnboardingTexts texts;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final text = TextsProvider.of(context)!.onboardingTexts;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: <Color>[ColorHelper.greenWeb.color.withValues(alpha: 0.08), ColorHelper.white.color], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: <Widget>[
          Image.asset(Assets.images.whiskrLogo.path, width: 100, height: 100),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  text.onboardingSummaryHeaderTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: ColorHelper.grey900.color),
                ),
                const SizedBox(height: 4),
                Text(text.onboardingSummaryHeaderSubtitle, style: theme.textTheme.bodyMedium?.copyWith(color: ColorHelper.grey600.color)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: ColorHelper.greenWeb.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.check_circle_outline, size: 16, color: ColorHelper.greenWeb.color),
                const SizedBox(width: 6),
                Text(
                  text.onboardingSummaryStepIndicator,
                  style: theme.textTheme.bodySmall?.copyWith(color: ColorHelper.greenWeb.color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildHighlightsStrip extends StatelessWidget {
  const _BuildHighlightsStrip({required this.provider});

  final WAOnboardingProvider provider;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final texts = TextsProvider.of(context)!.onboardingTexts;
    final int imagesCount = provider.imageBytesListForServiceUpload.length;

    final String businessName = provider.nameController.text.isNotEmpty ? provider.nameController.text : texts.onboardingSummaryBusinessPending;

    final String city = provider.cityController.text.isNotEmpty ? provider.cityController.text : texts.onboardingSummaryLocationNotSet;

    final String imagesLabel = imagesCount == 1 ? texts.onboardingSummaryImageUploadedSingle : texts.onboardingSummaryImageUploadedPlural;

    return Row(
      children: <Widget>[
        Expanded(
          child: _HighlightChip(icon: Icons.storefront_outlined, label: texts.onboardingSummaryHighlightBusiness, value: businessName, theme: theme),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _HighlightChip(icon: Icons.location_on_outlined, label: texts.onboardingSummaryHighlightLocation, value: city, theme: theme),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _HighlightChip(icon: Icons.photo_library_outlined, label: texts.onboardingSummaryHighlightMedia, value: '$imagesCount $imagesLabel', theme: theme),
        ),
      ],
    );
  }
}

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({required this.icon, required this.label, required this.value, required this.theme});

  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ColorHelper.white.color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 18, offset: const Offset(0, 10))],
        border: Border.all(color: ColorHelper.grey150.color),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: ColorHelper.greenWeb.color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(999)),
            child: Icon(icon, size: 18, color: ColorHelper.greenWeb.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(color: ColorHelper.grey500.color, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(color: ColorHelper.grey900.color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildBusinessProfileCard extends StatelessWidget {
  const _BuildBusinessProfileCard({required this.provider, required this.texts});

  final WAOnboardingProvider provider;
  final OnboardingTexts texts;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double imageSize = Responsive.value(context: context, mobile: 80.0, tablet: 100.0, desktop: 120.0);

    final String businessName = provider.nameController.text.isNotEmpty ? provider.nameController.text : texts.onboardingSummaryBusinessPending;

    final String city = provider.cityController.text.isNotEmpty ? provider.cityController.text : texts.onboardingSummaryLocationNotSet;

    return Container(
      decoration: BoxDecoration(
        color: ColorHelper.white.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: ColorHelper.grey150.color),
      ),
      padding: EdgeInsets.all(Responsive.value(context: context, mobile: 20, tablet: 24, desktop: 32)),
      child: ResponsiveBuilder(
        mobile: Column(
          children: <Widget>[
            _BuildBusinessImage(imageSize: imageSize),
            const SizedBox(height: 20),
            Column(
              children: <Widget>[
                Text(
                  businessName,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: ColorHelper.grey900.color),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.location_on, size: 16, color: ColorHelper.grey600.color),
                    const SizedBox(width: 6),
                    Text(city, style: theme.textTheme.bodyMedium?.copyWith(color: ColorHelper.grey600.color)),
                  ],
                ),
              ],
            ),
          ],
        ),
        desktop: Row(
          children: <Widget>[
            _BuildBusinessImage(imageSize: imageSize),
            const SizedBox(width: 28),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    businessName,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: ColorHelper.grey900.color),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      Icon(Icons.location_on, size: 18, color: ColorHelper.grey600.color),
                      const SizedBox(width: 8),
                      Text(city, style: theme.textTheme.bodyMedium?.copyWith(color: ColorHelper.grey600.color)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(width: 700, child: Text(provider.descriptionController.text)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildBusinessImage extends StatelessWidget {
  const _BuildBusinessImage({required this.imageSize});

  final double imageSize;

  @override
  Widget build(BuildContext context) {
    final String userImageUrl = context.select<WAOnboardingProvider, String>((WAOnboardingProvider provider) => provider.serviceProfileImage.url ?? '');

    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorHelper.grey150.color,
        border: Border.all(color: ColorHelper.greenWeb.color, width: 3),
      ),
      child: ClipOval(
        child: userImageUrl.isNotEmpty
            ? Image.network(
                userImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                  return Icon(Icons.business, size: imageSize * 0.5, color: ColorHelper.grey400.color);
                },
              )
            : Icon(Icons.business, size: imageSize * 0.5, color: ColorHelper.grey400.color),
      ),
    );
  }
}

class _BuildInfoCard extends StatelessWidget {
  const _BuildInfoCard({required this.title, required this.icon, required this.infoRows, this.currentStep = 0});

  final String title;
  final IconData icon;
  final int currentStep;
  final List<TitleSummaryValue> infoRows;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final texts = TextsProvider.of(context)!.onboardingTexts;

    return Container(
      decoration: BoxDecoration(
        color: ColorHelper.white.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 8))],
        border: Border.all(color: ColorHelper.grey150.color),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: ColorHelper.greenWeb.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: ColorHelper.greenWeb.color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: ColorHelper.grey900.color),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  context.read<WAOnboardingProvider>().setCurrentStep(currentStep);
                  context.go(onboardingGeneralInfoRoute);
                },
                icon: Icon(Icons.edit_outlined, size: 16, color: ColorHelper.grey600.color),
                label: Text(
                  texts.onboardingSummaryEdit,
                  style: theme.textTheme.bodySmall?.copyWith(color: ColorHelper.grey600.color, fontWeight: FontWeight.w500),
                ),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
              ),
            ],
          ),

          const SizedBox(height: 20),
          ...infoRows.map(
            (TitleSummaryValue row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BuildInfoRow(title: row.title, value: row.value),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildInfoRow extends StatelessWidget {
  const _BuildInfoRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: ColorHelper.grey600.color)),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Text(
            value.isNotEmpty ? value : '-',
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: ColorHelper.grey900.color),
          ),
        ),
      ],
    );
  }
}

class _BuildServiceImagesCard extends StatelessWidget {
  const _BuildServiceImagesCard({required this.provider});

  final WAOnboardingProvider provider;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final texts = TextsProvider.of(context)!.onboardingTexts;

    final int imagesCount = provider.imageBytesListForServiceUpload.length;
    final String counterLabel = imagesCount == 1 ? texts.onboardingSummaryImageSingular : texts.onboardingSummaryImagePlural;

    return Container(
      decoration: BoxDecoration(
        color: ColorHelper.white.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 8))],
        border: Border.all(color: ColorHelper.grey150.color),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: ColorHelper.greenWeb.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.photo_library_outlined, color: ColorHelper.greenWeb.color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                texts.onboardingSummaryImagesTitle,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: ColorHelper.grey900.color),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: ColorHelper.greenWeb.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
                child: Text(
                  '$imagesCount $counterLabel',
                  style: theme.textTheme.bodySmall?.copyWith(color: ColorHelper.greenWeb.color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.imageBytesListForServiceUpload.length,
              separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 12),
              itemBuilder: (BuildContext context, int index) {
                final Uint8List imageBytes = provider.imageBytesListForServiceUpload[index];
                return InkWell(
                  onTap: () {
                    // Use post-frame callback to defer dialog opening
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return Dialog(
                            insetPadding: const EdgeInsets.all(24),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                imageBytes,
                                fit: BoxFit.contain,
                                errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
                                  return SizedBox(
                                    width: 300,
                                    height: 300,
                                    child: Center(child: Icon(Icons.broken_image_outlined, size: 40, color: ColorHelper.grey400.color)),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ColorHelper.grey200.color),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 120,
                        height: 120,
                        color: ColorHelper.grey150.color,
                        child: Image.memory(
                          imageBytes,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            return Center(child: Icon(Icons.image_outlined, size: 40, color: ColorHelper.grey400.color));
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildMapCard extends StatelessWidget {
  const _BuildMapCard();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final texts = TextsProvider.of(context)!.onboardingTexts;
    final WAOnboardingProvider onboardingProvider = context.watch<WAOnboardingProvider>();

    return Container(
      decoration: BoxDecoration(
        color: ColorHelper.white.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 8))],
        border: Border.all(color: ColorHelper.grey150.color),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: ColorHelper.greenWeb.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.map_outlined, color: ColorHelper.greenWeb.color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                texts.onboardingSummaryMapTitle,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: ColorHelper.grey900.color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(texts.onboardingSummaryMapDescription, style: theme.textTheme.bodySmall?.copyWith(color: ColorHelper.grey600.color)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: Responsive.value(context: context, mobile: 240, tablet: 280, desktop: 320),
              child: WAMapPicker(
                mapboxAccessToken: FlavorConfig.instance.values.mapboxAccessToken,
                readOnly: true,
                isInitialLocationSet: true,
                mapType: MapBoxType.outdoors,
                initialLocation: LatLng(onboardingProvider.latitude ?? 0, onboardingProvider.longitude ?? 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildActionButtons extends StatelessWidget {
  const _BuildActionButtons({required this.context, required this.texts});

  final BuildContext context;
  final OnboardingTexts texts;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: Column(children: <Widget>[]),
      desktop: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 260,
            height: 48,
            child: CommonButton(
              onPressed: () => OnboardingActionUtils.handleSummaryConfirm(context),
              buttonTitle: texts.onboardingSummarySubmitComplete,
              buttonType: PPButtonType.web,
              showBorder: false,
            ),
          ),
        ],
      ),
    );
  }
}

class TitleSummaryValue {
  TitleSummaryValue(this.title, this.value);

  final String title;
  final String value;
}
