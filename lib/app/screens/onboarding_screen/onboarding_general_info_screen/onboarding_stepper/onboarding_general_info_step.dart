import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/text_fields/wa_custom_text_field.dart';
import 'package:w_image_module/providers/image_provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';
import 'package:whiskr_admin_panel/widgets/wa_multiple_images.dart';

import '../../../../helpers/utils/onboarding_utils/onboarding_action_utils.dart';
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
                label: texts.generalInfoEmailLabel,
                hint: texts.generalInfoEmailHint,
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
    final texts = TextsProvider.of(context)!.onboardingTexts;
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 10),
          const ProfileImagePicker(),
          const SizedBox(height: 30),
          WAMultipleImagePicker(
            maxImages: 5,
            onImagesChanged: (images) {
              context.read<WAOnboardingProvider>().setImageBytesListForServiceUpload(images);
              debugPrint(images.length.toString());
            },
            initialImages: context.read<WAOnboardingProvider>().imageBytesListForServiceUpload,
            addImageLabel: texts.onboardingWAMultipleImagePickerAddImage,
            imageAddedMessage: texts.onboardingWAMultipleImagePickerImageAdded,
            imageRemovedMessage: texts.onboardingWAMultipleImagePickerImageRemoved,
            maxReachedMessage: texts.onboardingWAMultipleImagePickerMaxReached,
            title: texts.onboardingWAMultipleImagePickerTitle,
          ),
        ],
      ),
    );
  }
}

class ProfileImagePicker extends StatefulWidget {
  const ProfileImagePicker({super.key});

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final texts = TextsProvider.of(context)!.onboardingTexts;

    return Consumer<ImageHandleProvider>(
      builder: (context, imageProvider, child) {
        final imageBytes = imageProvider.imageBytes?.fileBytes;

        return Column(
          spacing: 20,
          children: [
            MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async => await OnboardingActionUtils.uploadUserProviderImage(context),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _isHovered ? ColorHelper.greenWeb.color.withValues(alpha: 40) : ColorHelper.grey100.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _isHovered ? ColorHelper.white.color : ColorHelper.grey300.color, width: 2),
                  ),
                  child: imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(base64Decode(imageBytes), fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 32, color: _isHovered ? ColorHelper.white.color : ColorHelper.grey500.color),
                            const SizedBox(height: 8),
                            Text(
                              texts.onboardingWAMultipleImagePickerAddImage,
                              style: TextStyle(fontSize: 12, color: _isHovered ? ColorHelper.white.color : ColorHelper.grey600.color, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            SizedBox(
              width: 250,
              child: Text(
                'Upload your business profile image. Choose a logo or photo that best represents your service.',
                style: TextStyle(fontSize: 14, color: ColorHelper.grey600.color, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }
}
