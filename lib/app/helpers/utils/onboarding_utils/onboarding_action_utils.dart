import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_components/wa_custom_snackbar/wa_custom_snackbar.dart';
import 'package:w_image_module/helpers/image_constants.dart';
import 'package:w_image_module/providers/image_provider.dart';
import 'package:w_user_module/providers/user_management_provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/models/image_model.dart';
import 'package:w_utils/models/response_model.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';

import '../../../../routing/routes.dart';

typedef OnboardingStep = ({String title, String description});

class OnboardingActionUtils {
  OnboardingActionUtils._();

  static Future<void> uploadUserProviderImage(BuildContext context) async {
    final imageProvider = context.read<ImageHandleProvider>();
    final userProvider = context.read<UserManagementProvider>();
    final imageResult = await imageProvider.pickImageForWeb();
    if (!context.mounted) return;

    if (imageResult.isSuccess) {
      final ResponseModel<ImageModel> uploadResult = await imageProvider.uploadImage(ProviderImageConstants.userProviderImages);
      if (uploadResult.isSuccess) {
        // todo(danispreldzic):: update user image and edit user data api (wait for cahta with roles check)
        userProvider.setUserServerImage(uploadResult.data ?? ImageModel());
        final ResponseModel<String> userImageUpdateResponse = await userProvider.updateUserImage();
        if (userImageUpdateResponse.isSuccess) {
          if (context.mounted) WACustomSnackbar.instance.showSnack(context, 'Image uploaded successfully: ${uploadResult.data!.url}', type: WACustomSnackbarType.success);
        } else {
          if (context.mounted) WACustomSnackbar.instance.showSnack(context, userImageUpdateResponse.error!, type: WACustomSnackbarType.error);
        }
      } else {
        if (context.mounted) WACustomSnackbar.instance.showSnack(context, uploadResult.error!, type: WACustomSnackbarType.error);
      }
    } else {
      WACustomSnackbar.instance.showSnack(context, 'Image uploaded ERROR: ${imageResult.error}', type: WACustomSnackbarType.error);
    }
  }

  static String getButtonTitle(int currentStep) {
    if (currentStep < 2) return 'Next Step';
    return 'Complete';
  }

  static void handleStepPress(BuildContext context, int targetStep, int currentStep) {
    final provider = context.read<WAOnboardingProvider>();

    // Allow going back without validation
    if (targetStep < currentStep) {
      provider.setCurrentStep(targetStep);
      return;
    }

    // Validate before moving forward
    if (targetStep > currentStep) {
      final canProceed = validateStepsUpTo(context, targetStep - 1);
      if (canProceed) {
        provider.setCurrentStep(targetStep);
      }
    }
  }

  static bool validateStepsUpTo(BuildContext context, int targetStep) {
    final provider = context.read<WAOnboardingProvider>();

    for (int step = 0; step <= targetStep; step++) {
      String? error;
      switch (step) {
        case 0:
          error = provider.validateStep1();
          break;
        case 1:
          error = provider.validateStep2();
          break;
        case 2:
          error = provider.validateStep3();
          break;
      }

      if (error != null) {
        showError(context, error);
        return false;
      }
    }

    return true;
  }

  static void handleButtonPress(BuildContext context, int currentStep) {
    if (currentStep < 2) {
      handleNext(context, currentStep);
    } else {
      handleComplete(context);
    }
  }

  static void handleNext(BuildContext context, int currentStep) {
    final provider = context.read<WAOnboardingProvider>();
    final error = _getCurrentStepError(provider, currentStep);

    if (error != null) {
      OnboardingActionUtils.showError(context, error);
      return;
    }

    provider.nextStep();
  }

  static Future<void> handleComplete(BuildContext context) async {
    final provider = context.read<WAOnboardingProvider>();
    final error = provider.validateStep3();

    if (error != null) {
      OnboardingActionUtils.showError(context, error);
      return;
    }

    if (!provider.canSaveData()) {
      OnboardingActionUtils.showError(context, 'Please complete all required fields');
      return;
    }

    // first upload images to image kit
    await _uploadServiceImagesToImageKit(context, provider);

    final ResponseModel<String> response = await provider.onboardUserAdmin();
    if (response.isSuccess) {
      if (context.mounted) {
        OnboardingActionUtils.showSuccess(context, 'Service saved successfully!');
        context.pushReplacementNamed(dashboardRoute);
      }
    } else {
      if (context.mounted) OnboardingActionUtils.showError(context, response.error.toString());
    }
  }

  static Future<void> _uploadServiceImagesToImageKit(BuildContext context, WAOnboardingProvider onboardingProvider) async {
    final ImageHandleProvider imageHandleProvider = context.read<ImageHandleProvider>();

    try {
      final ResponseModel<List<ImageModel>> response = await imageHandleProvider.uploadMultipleImages(onboardingProvider.imageBytesListForServiceUpload, ProviderImageConstants.userProviderImages);
      if (response.isSuccess) {
        response.data!.map((ImageModel image) => onboardingProvider.addOrRemoveImage(image));
        debugPrint("WAOnboardingProvider service images length: ${onboardingProvider.images.length}");
      } else {
        debugPrint("Error image service upload: ${response.error}");
      }
    } catch (e) {
      debugPrint("Image upload failed: $e");
    }
  }

  static String? _getCurrentStepError(WAOnboardingProvider provider, int currentStep) {
    switch (currentStep) {
      case 0:
        return provider.validateStep1();
      case 1:
        return provider.validateStep2();
      case 2:
        return provider.validateStep3();
      default:
        return null;
    }
  }

  // time picker utils
  static String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour : $minute';
  }

  static Future<void> selectTime(BuildContext context, TimeOfDay time, ValueChanged<TimeOfDay> onTimeSelected, {bool enabled = false}) async {
    if (!enabled) return;
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: time, builder: (context, child) => timePickerTheme(child!));
    if (picked != null) onTimeSelected(picked);
  }

  static Theme timePickerTheme(Widget child) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.light(primary: ColorHelper.greenWeb.color, onSurface: ColorHelper.grey700.color, surface: ColorHelper.white.color, secondary: ColorHelper.greenWeb.color),
        timePickerTheme: TimePickerThemeData(
          dayPeriodColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return ColorHelper.greenWeb.color;
            }
            return ColorHelper.white.color;
          }),
          dayPeriodTextColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return ColorHelper.white.color;
            }
            return ColorHelper.grey700.color;
          }),
          dialBackgroundColor: ColorHelper.white.color,
          dialHandColor: ColorHelper.greenWeb.color,
          backgroundColor: ColorHelper.grey150.color,
          hourMinuteColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return ColorHelper.white.color;
            }
            if (states.contains(WidgetState.focused)) {
              return ColorHelper.greenWeb.color;
            }
            return ColorHelper.white.color;
          }),
          hourMinuteShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: ColorHelper.greenWeb.color, width: 1),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderSide: BorderSide(color: ColorHelper.greenWeb.color, width: 1)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorHelper.grey300.color, width: 1)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: ColorHelper.greenWeb.color, width: 2)),
          ),
          hourMinuteTextColor: ColorHelper.grey700.color,
          cancelButtonStyle: ButtonStyle(backgroundColor: WidgetStateProperty.all(ColorHelper.grey150.color), foregroundColor: WidgetStateProperty.all(ColorHelper.grey700.color)),
          confirmButtonStyle: ButtonStyle(backgroundColor: WidgetStateProperty.all(ColorHelper.greenWeb.color), foregroundColor: WidgetStateProperty.all(ColorHelper.white.color)),
        ),
      ),
      child: child,
    );
  }

  //////////

  static void showError(BuildContext context, String message) {
    WACustomSnackbar.instance.showSnack(context, message, type: WACustomSnackbarType.error);
  }

  static void showSuccess(BuildContext context, String message) {
    WACustomSnackbar.instance.showSnack(context, message, type: WACustomSnackbarType.success);
  }
}
