import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/buttons/common_button.dart';
import 'package:w_components/wa_custom_snackbar/wa_custom_snackbar.dart';
import 'package:w_components/wa_custom_stepper/wa_custom_stepper.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';
import 'package:whiskr_admin_panel/app/screens/onboarding_screen/onboarding_general_info_screen/onboarding_stepper/onboarding_general_info_step.dart';
import 'package:whiskr_admin_panel/app/screens/onboarding_screen/onboarding_general_info_screen/onboarding_stepper/onboarding_location_step.dart';
import 'package:whiskr_admin_panel/app/screens/onboarding_screen/onboarding_general_info_screen/onboarding_stepper/onboarding_working_hours_step.dart';
import 'package:whiskr_admin_panel/app/screens/onboarding_screen/onboarding_summary_screen/onboarding_summary_screen.dart';

class OnboardingStepper extends StatefulWidget {
  const OnboardingStepper({super.key});

  @override
  State<OnboardingStepper> createState() => _OnboardingStepperState();
}

class _OnboardingStepperState extends State<OnboardingStepper> {
  @override
  Widget build(BuildContext context) {
    final currentStep = context.select<WAOnboardingProvider, int>((p) => p.currentStep);

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: StepperContainer(currentStep: currentStep, showSummary: currentStep == 3),
      ),
    );
  }
}

class StepperContainer extends StatelessWidget {
  final int currentStep;
  final bool showSummary;

  const StepperContainer({super.key, required this.currentStep, this.showSummary = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: ColorHelper.black.color.withAlpha(8), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          WACustomStepper(activeColor: ColorHelper.greenWeb.color, currentStep: currentStep, steps: context.read<WAOnboardingProvider>().steps, onStepPress: (int i) => _handleStepPress(context, i)),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final fadeIn = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
              final slideIn = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(fadeIn);
              final scale = Tween<double>(begin: 0.98, end: 1.0).animate(fadeIn);

              return FadeTransition(
                opacity: fadeIn,
                child: SlideTransition(
                  position: slideIn,
                  child: ScaleTransition(scale: scale, child: child),
                ),
              );
            },
            child: SizedBox(
              key: ValueKey(showSummary ? 'summary' : currentStep),
              height: showSummary
                  ? 1150
                  : currentStep == 0
                  ? 700
                  : 550,
              child: showSummary ? const OnboardingSummaryScreen() : _buildStepContent(),
            ),
          ),
          const SizedBox(height: 22),
          if (!showSummary) _buildNavigationButtons(context),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return const OnboardingGeneralInfoStep();
      case 1:
        return const OnboardingLocationStep();
      case 2:
        return const OnboardingWorkingHoursStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: CommonButton(onPressed: () => _handleButtonPress(context), buttonTitle: _getButtonTitle(), buttonType: PPButtonType.web, showBorder: false),
    );
  }

  String _getButtonTitle() {
    if (currentStep < 2) return 'Next Step';
    return 'Complete';
  }

  void _handleStepPress(BuildContext context, int targetStep) {
    final provider = context.read<WAOnboardingProvider>();

    // Allow going back without validation
    if (targetStep < currentStep) {
      provider.setCurrentStep(targetStep);
      return;
    }

    // Validate before moving forward
    if (targetStep > currentStep) {
      final canProceed = _validateStepsUpTo(context, targetStep - 1);
      if (canProceed) {
        provider.setCurrentStep(targetStep);
      }
    }
  }

  void _handleButtonPress(BuildContext context) {
    if (currentStep < 2) {
      _handleNext(context);
    } else {
      _handleComplete(context);
    }
  }

  void _handleNext(BuildContext context) {
    final provider = context.read<WAOnboardingProvider>();
    final error = _getCurrentStepError(provider);

    if (error != null) {
      _showError(context, error);
      return;
    }

    provider.nextStep();
  }

  void _handleComplete(BuildContext context) {
    final provider = context.read<WAOnboardingProvider>();
    final error = provider.validateStep3();

    if (error != null) {
      _showError(context, error);
      return;
    }

    if (!provider.canSaveData()) {
      _showError(context, 'Please complete all required fields');
      return;
    }

    provider.saveData();
    provider.setCurrentStep(3);

    _showSuccess(context, 'Service saved successfully!');
  }

  String? _getCurrentStepError(WAOnboardingProvider provider) {
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

  bool _validateStepsUpTo(BuildContext context, int targetStep) {
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
        _showError(context, error);
        return false;
      }
    }

    return true;
  }

  void _showError(BuildContext context, String message) {
    WACustomSnackbar.instance.showSnack(context, message, type: WACustomSnackbarType.error);
  }

  void _showSuccess(BuildContext context, String message) {
    WACustomSnackbar.instance.showSnack(context, message, type: WACustomSnackbarType.success);
  }
}
