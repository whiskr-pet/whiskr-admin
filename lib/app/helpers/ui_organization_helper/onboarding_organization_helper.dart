import 'package:flutter/material.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';

import '../../screens/onboarding_screen/onboarding_summary_screen/onboarding_summary_screen.dart';

class OnboardingHelper {
  List<TitleSummaryValue> generalInfoRow(WAOnboardingProvider provider) => [
    TitleSummaryValue('Phone', provider.phoneController.text),
    TitleSummaryValue('Email', provider.emailController.text),
    TitleSummaryValue('Website', provider.websiteController.text),
    TitleSummaryValue('Description', provider.descriptionController.text),
  ];

  List<TitleSummaryValue> locationInfoRow(WAOnboardingProvider provider) => [
    TitleSummaryValue('Address', provider.addressController.text),
    TitleSummaryValue('City', provider.cityController.text),
    TitleSummaryValue('State', provider.stateController.text),
    TitleSummaryValue('Zip Code', provider.zipCodeController.text),
    TitleSummaryValue('Note', provider.noteController.text),
  ];

  List<TitleSummaryValue> hoursInfoRow(WAOnboardingProvider provider, BuildContext context) =>
      provider.workingDays.map((day) => TitleSummaryValue(day.name, day.isOpen ? '${day.openingTime.format(context)} - ${day.closingTime.format(context)}' : 'Closed')).toList();
}
