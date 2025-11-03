import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/text_fields/wa_custom_text_field.dart';
import 'package:w_components/w_components.dart';
import 'package:w_components/wa_custom_snackbar/wa_custom_snackbar.dart';
import 'package:w_image_module/providers/image_provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';

class OnboardingGeneralInfoStep extends StatelessWidget {
  const OnboardingGeneralInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _BuildImagePicker(),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: WACustomTextField(
                controller: context.read<WAOnboardingProvider>().nameController,
                label: 'Name',
                hint: "Enter your service's name",
                isRequired: true,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: WACustomTextField(
                controller: context.read<WAOnboardingProvider>().phoneController,
                label: 'Phone',
                hint: "XXX XX XXX-XXX",
                isRequired: true,
                type: WATextFieldType.phone,
                phoneFormat: '+XXX XX XXX-XXX',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        WACustomTextField(
          controller: context.read<WAOnboardingProvider>().descriptionController,
          label: 'Description',
          hint: "Enter your service's description",
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
                label: 'Contact Email',
                hint: "Enter your service's contact email",
                isRequired: true,
                type: WATextFieldType.email,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WACustomTextField(
                controller: context.read<WAOnboardingProvider>().websiteController,
                label: 'Website',
                hint: "Enter your service's website",
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
                      child: imageProvider.imageBytes != null
                          ? Image.memory(imageProvider.imageBytes!, fit: BoxFit.cover)
                          : const Icon(Icons.person, size: 40, color: Colors.grey),
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
        ],
      ),
    );
  }
}

class _BuildTextImagePicker extends StatelessWidget {
  const _BuildTextImagePicker();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final imageProvider = context.read<ImageHandleProvider>();
        final onboardingProvider = context.read<WAOnboardingProvider>();
        final imageResult = await imageProvider.pickImageForWeb();
        if (!context.mounted) return;

        if (!imageResult.isSuccess) {
          onboardingProvider.setServiceImage(imageResult.data.toString());
          WACustomSnackbar.instance.showSnack(context, imageResult.error!, type: WACustomSnackbarType.error);
        } else {
          WACustomSnackbar.instance.showSnack(context, 'Image uploaded successfully: ${imageResult.data!.length}', type: WACustomSnackbarType.success);
        }

        // final uploadResult = await imageProvider.uploadImage(imageResult.data!.path);
        // if (!context.mounted) return;

        // todo add backend api and add storage path it need to call only once to server
        // if (uploadResult.isSuccess) {
        //   imageProvider.imageUrl = uploadResult.data!.url!;
        //   _showSnack(context, 'Image uploaded successfully: ${uploadResult.data!.url}');
        // } else {
        //   _showSnack(context, uploadResult.error!);
        // }
      },
      child: Text(
        context.select<ImageHandleProvider, bool>((provider) => provider.imageBytes != null) ? 'Change Photo' : 'Upload Photo',
        style: TextStyle(color: ColorHelper.blue500.color, fontSize: 14),
      ),
    );
  }
}
