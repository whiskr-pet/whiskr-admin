import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_components/buttons/common_button.dart';
import 'package:w_components/w_components.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';
import 'package:whiskr_admin_panel/gen/assets.gen.dart';
import 'package:whiskr_admin_panel/routing/routes.dart';

import '../../../../localization_models/localization_models.dart';
import '../../../providers/texts_provider.dart';

class OnboardingIntroScreen extends StatelessWidget {
  const OnboardingIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _BuildOnboardingIntroBody(), bottomNavigationBar: _BuildGetStartedButton());
  }
}

class _BuildOnboardingIntroBody extends StatelessWidget {
  const _BuildOnboardingIntroBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconWidth = Responsive.value<double>(context: context, mobile: 100, tablet: 100, desktop: 150, widescreen: 150);

    final iconHeight = Responsive.value<double>(context: context, mobile: 70, tablet: 80, desktop: 100, widescreen: 100);

    final headlineFontSize = Responsive.value<double>(context: context, mobile: 30, tablet: 30, desktop: 40, widescreen: 40);

    final logoWidth = Responsive.value<double>(context: context, mobile: 100, tablet: 100, desktop: 150, widescreen: 150);

    final bodyFontSize = Responsive.value<double>(context: context, mobile: 16, tablet: 16, desktop: 22, widescreen: 24);

    final onboardingImageWidth = Responsive.value<double>(context: context, mobile: 200, tablet: 350, desktop: 400, widescreen: 500);

    final onboardingImageHeight = Responsive.value<double>(context: context, mobile: 200, tablet: 350, desktop: 400, widescreen: 500);
    final OnboardingTexts texts = TextsProvider.of(context)!.onboardingTexts;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(Assets.images.appiconNoText.path, width: iconWidth, height: iconHeight),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                texts.introWelcome,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: headlineFontSize,
                  color: ColorHelper.greenWeb.color,
                  fontFamily: 'NunitoSans',
                ),
              ),
              Image.asset(Assets.images.whiskrLogo.path, width: logoWidth, height: 155),
            ],
          ),
          Text(
            texts.introSetup,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: bodyFontSize, fontWeight: FontWeight.w500, color: ColorHelper.greenWeb.color),
          ),
          const SizedBox(height: 30),
          Image.asset(Assets.images.onboarding1.path, width: onboardingImageWidth, height: onboardingImageHeight),
        ],
      ),
    );
  }
}

class _BuildGetStartedButton extends StatelessWidget {
  const _BuildGetStartedButton();

  @override
  Widget build(BuildContext context) {
    final OnboardingTexts texts = TextsProvider.of(context)!.onboardingTexts;
    return SizedBox(
      height: 80,
      child: Column(
        children: [
          CommonButton(
            onPressed: () {
              context.read<WAOnboardingProvider>().setCurrentStep(0);
              context.go(onboardingGeneralInfoRoute);
            },
            buttonTitle: texts.getStarted,
            buttonType: PPButtonType.web,
            showBorder: false,
          ),
        ],
      ),
    );
  }
}
