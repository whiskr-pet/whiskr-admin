import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/text_fields/wa_custom_text_field.dart';
import 'package:w_components/w_components.dart';
import 'package:w_image_module/providers/image_provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';
import 'package:whiskr_admin_panel/app/helpers/utils/onboarding_utils/onboarding_action_utils.dart';
import 'package:whiskr_admin_panel/app/screens/onboarding_screen/onboarding_general_info_screen/onboarding_stepper/wa_multiple_images.dart';

import '../../../../providers/texts_provider.dart';

class OnboardingGeneralInfoStep extends StatelessWidget {
  const OnboardingGeneralInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    final texts = TextsProvider.of(context)!.onboardingTexts;
    return Column(
      children: [
        const _BuildImagePicker(),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: WACustomTextField(controller: context.read<WAOnboardingProvider>().nameController, label: texts.generalInfoNameLabel, hint: texts.generalInfoNameHint, isRequired: true),
            ),
            SizedBox(width: 16),
            Expanded(
              child: WACustomTextField(
                controller: context.read<WAOnboardingProvider>().phoneController,
                label: texts.generalInfoPhoneLabel,
                hint: texts.generalInfoPhoneHint,
                isRequired: true,
                type: WATextFieldType.phone,
                phoneFormat: texts.generalInfoPhoneFormat,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        WACustomTextField(
          controller: context.read<WAOnboardingProvider>().descriptionController,
          label: texts.generalInfoDescriptionLabel,
          hint: texts.generalInfoDescriptionHint,
          isRequired: true,
          maxLines: 4,
          maxLength: 600,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: WACustomTextField(
                controller: context.read<WAOnboardingProvider>().emailController,
                label: texts.generalInfoDescriptionLabel,
                hint: texts.generalInfoDescriptionHint,
                isRequired: true,
                type: WATextFieldType.email,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WACustomTextField(
                controller: context.read<WAOnboardingProvider>().websiteController,
                label: texts.generalInfoWebsiteLabel,
                hint: texts.generalInfoWebsiteHint,
                isRequired: false,
                type: WATextFieldType.url,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BuildImagePicker extends StatelessWidget {
  const _BuildImagePicker();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Consumer<ImageHandleProvider>(
            builder: (context, imageProvider, child) => imageProvider.imageBytes != null
                ? ClipOval(
                    child: Container(
                      width: 75,
                      height: 75,
                      color: ColorHelper.grey150.color,
                      child: imageProvider.imageBytes != null ? Image.memory(imageProvider.imageBytes!, fit: BoxFit.cover) : const Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(color: ColorHelper.grey150.color, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, size: 32),
                  ),
          ),
          const SizedBox(height: 12),
          const _BuildTextImagePicker(),
          const SizedBox(height: 30),
          WAMultipleImagePicker(
            maxImages: 5,
            onImagesChanged: (images) {
              context.read<WAOnboardingProvider>().setImageBytesListForServiceUpload(images);
              debugPrint(images.length.toString());
            },
            initialImages: context.read<WAOnboardingProvider>().imageBytesListForServiceUpload,
          ),
        ],
      ),
    );
  }
}

class _BuildTextImagePicker extends StatelessWidget {
  const _BuildTextImagePicker();

  @override
  Widget build(BuildContext context) {
    final texts = TextsProvider.of(context)!.onboardingTexts;
    return TextButton(
      onPressed: () async => await OnboardingActionUtils.uploadUserProviderImage(context),
      child: Text(
        context.select<ImageHandleProvider, bool>((provider) => provider.imageBytes != null) ? texts.generalInfoChangePhoto : texts.generalInfoUploadPhoto,
        style: TextStyle(color: ColorHelper.blue500.color, fontSize: 14),
      ),
    );
  }
}
