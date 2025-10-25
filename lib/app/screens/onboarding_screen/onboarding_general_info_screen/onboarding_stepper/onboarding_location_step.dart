import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/w_components.dart';
import 'package:w_components/wa_map_picker/wa_map_picker.dart';
import 'package:wa_map_module/wa_map_module.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';
import 'package:whiskr_admin_panel/config/flavor_config.dart';

class OnboardingLocationStep extends StatelessWidget {
  const OnboardingLocationStep({super.key});

  @override
  Widget build(BuildContext context) {
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
        WACustomTextField(controller: context.read<WAOnboardingProvider>().addressController, label: 'Address', hint: 'Enter your address', isRequired: true),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: WACustomTextField(controller: context.read<WAOnboardingProvider>().cityController, label: 'City', hint: 'Enter city', isRequired: true),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WACustomTextField(controller: context.read<WAOnboardingProvider>().stateController, label: 'State', hint: 'Enter state', isRequired: true),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: WACustomTextField(controller: context.read<WAOnboardingProvider>().zipCodeController, label: 'ZIP Code', hint: 'Enter ZIP code', isRequired: true),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WACustomTextField(controller: context.read<WAOnboardingProvider>().noteController, label: 'Note', hint: 'Enter notes', isRequired: true),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
