import 'package:flutter/material.dart';
import 'package:w_components/w_components.dart';

class OnboardingLocationStep extends StatelessWidget {
  const OnboardingLocationStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WACustomTextField(label: 'Address', hint: 'Enter your address', isRequired: true),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: WACustomTextField(label: 'City', hint: 'Enter city', isRequired: true),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WACustomTextField(label: 'State', hint: 'Enter state', isRequired: true),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: WACustomTextField(label: 'ZIP Code', hint: 'Enter ZIP code', isRequired: true),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WACustomTextField(label: 'Note', hint: 'Enter notes', isRequired: true),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
