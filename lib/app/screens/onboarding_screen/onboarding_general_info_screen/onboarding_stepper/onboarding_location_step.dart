import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/w_components.dart';
import 'package:w_components/wa_map_picker/wa_map_picker.dart';
import 'package:wa_map_module/wa_map_module.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';
import 'package:whiskr_admin_panel/config/flavor_config.dart';

import '../../../../../l10n/models/screen_texts/onboarding_texts.dart';
import '../../../../providers/texts_provider.dart';

class OnboardingLocationStep extends StatelessWidget {
  const OnboardingLocationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingTexts texts = TextsProvider.of(context)!.onboardingTexts;

    return Column(
      children: [
        Expanded(
          child: WAMapPicker(
            mapboxAccessToken: FlavorConfig.instance.values.mapboxAccessToken,
            showAddress: true,
            mapType: MapBoxType.outdoors,
            onConfirm: (pos) async {
              context.read<WAOnboardingProvider>().zipCodeController.text = pos.address.zip ?? "";
              context.read<WAOnboardingProvider>().stateController.text = pos.address.country ?? "";
              context.read<WAOnboardingProvider>().cityController.text = pos.address.city ?? "";
              context.read<WAOnboardingProvider>().addressController.text = pos.address.streetAddress ?? "";
            },
          ),
        ),
        const SizedBox(height: 24),
        WACustomTextField(controller: context.read<WAOnboardingProvider>().addressController, label: texts.locationAddressLabel, hint: texts.locationAddressHint, isRequired: true),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: WACustomTextField(controller: context.read<WAOnboardingProvider>().cityController, label: texts.locationCityLabel, hint: texts.locationCityHint, isRequired: true),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WACustomTextField(controller: context.read<WAOnboardingProvider>().stateController, label: texts.locationStateLabel, hint: texts.locationStateHint, isRequired: true),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: WACustomTextField(controller: context.read<WAOnboardingProvider>().zipCodeController, label: texts.locationZipLabel, hint: texts.locationZipHint, isRequired: true),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WACustomTextField(controller: context.read<WAOnboardingProvider>().noteController, label: texts.locationNoteLabel, hint: texts.locationNoteHint, isRequired: false),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
