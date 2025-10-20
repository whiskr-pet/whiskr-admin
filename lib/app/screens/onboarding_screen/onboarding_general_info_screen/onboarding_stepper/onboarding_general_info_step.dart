import 'package:flutter/material.dart';
import 'package:w_components/text_fields/wa_custom_text_field.dart';

class OnboardingGeneralInfoStep extends StatelessWidget {
  const OnboardingGeneralInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: const Color(0xFFF5F5F5), shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Color(0xFF9CA3AF), size: 32),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {},
                child: const Text('Upload Photo', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 14)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: WACustomTextField(label: 'Name', hint: "Enter your service's name", isRequired: true),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WACustomTextField(label: 'Phone', hint: "Enter your service's phone number", isRequired: true),
            ),
          ],
        ),
        const SizedBox(height: 24),
        WACustomTextField(label: 'Description', hint: "Enter your service's description", isRequired: true, maxLines: 4),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: WACustomTextField(label: 'Contact Email', hint: "Enter your service's contact email", isRequired: true),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WACustomTextField(label: 'Website', hint: "Enter your service's website", isRequired: false),
            ),
          ],
        ),
      ],
    );
  }
}
