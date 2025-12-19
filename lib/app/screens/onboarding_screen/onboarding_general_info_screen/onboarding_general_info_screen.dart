import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';
import 'package:whiskr_admin_panel/app/screens/onboarding_screen/onboarding_general_info_screen/onboarding_stepper/onboarding_stepper.dart';
import 'package:whiskr_admin_panel/gen/assets.gen.dart';

import '../../../../localization_models/onboarding_text/onboarding_text.dart';
import '../../../providers/texts_provider.dart';

class OnboardingGeneralInfoScreen extends StatelessWidget {
  const OnboardingGeneralInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorHelper.grey150.color,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: Responsive.value(context: context, mobile: 16.0, tablet: 60.0, desktop: 120.0, widescreen: 200.0)),
            child: const _BuildOnboardingGeneralInfoBody(),
          ),
        ),
      ),
    );
  }
}

class _BuildOnboardingGeneralInfoBody extends StatelessWidget {
  const _BuildOnboardingGeneralInfoBody();

  @override
  Widget build(BuildContext context) {
    return Column(children: [const _BuildGeneralInfoHeader(), const SizedBox(height: 40), const _BuildGeneralInfoForm()]);
  }
}

class _BuildGeneralInfoHeader extends StatelessWidget {
  const _BuildGeneralInfoHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int currentStep = context.select<WAOnboardingProvider, int>((provider) => provider.currentStep);

    final double titleFontSize = Responsive.value(context: context, mobile: 26.0, tablet: 30.0, desktop: 34.0, widescreen: 40.0);

    final double descriptionFontSize = Responsive.value(context: context, mobile: 16.0, tablet: 14.0, desktop: 14.0, widescreen: 16.0);

    final double logoSizeWidth = Responsive.value(context: context, mobile: 100.0, tablet: 120.0, desktop: 140.0, widescreen: 160.0);
    final double logoSizeHeight = Responsive.value(context: context, mobile: 100.0, tablet: 100.0, desktop: 100.0, widescreen: 100.0);
    final OnboardingTexts texts = TextsProvider.of(context)!.onboardingTexts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(Assets.images.whiskrLogo.path, width: logoSizeWidth, height: logoSizeHeight),
        Text(
          texts.getStepTitle(currentStep),
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: titleFontSize, color: ColorHelper.greenWeb.color),
        ),
        const SizedBox(height: 12),
        Text(
          texts.getStepDescription(currentStep),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: descriptionFontSize, fontWeight: FontWeight.w500, color: ColorHelper.greenWeb.color),
        ),
      ],
    );
  }
}

class _BuildGeneralInfoForm extends StatelessWidget {
  const _BuildGeneralInfoForm();

  @override
  Widget build(BuildContext context) {
    return Center(child: OnboardingStepper());
  }
}
