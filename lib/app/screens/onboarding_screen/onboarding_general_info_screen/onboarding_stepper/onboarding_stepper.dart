import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/buttons/common_button.dart';
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
        child: StepperContainer(currentStep: currentStep, onNextStep: context.read<WAOnboardingProvider>().nextStep, showSummary: currentStep == 3),
      ),
    );
  }
}

class StepperContainer extends StatelessWidget {
  final int currentStep;
  final VoidCallback onNextStep;
  final bool showSummary;

  const StepperContainer({super.key, required this.currentStep, required this.onNextStep, this.showSummary = false});

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
          WACustomStepper(
            activeColor: ColorHelper.greenWeb.color,
            currentStep: currentStep,
            steps: context.read<WAOnboardingProvider>().steps,
            onStepPress: (int i) => context.read<WAOnboardingProvider>().setCurrentStep(i),
          ),
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
            child: SizedBox(key: ValueKey(showSummary ? 'summary' : currentStep), height: showSummary ? 1000 : 550, child: showSummary ? const OnboardingSummaryScreen() : _buildStepContent()),
          ),
          const SizedBox(height: 22),
          if (!showSummary)
            SizedBox(
              width: double.infinity,
              height: 45,
              child: CommonButton(
                onPressed: currentStep < 2
                    ? onNextStep
                    : () {
                        context.read<WAOnboardingProvider>().saveData();
                        context.read<WAOnboardingProvider>().setCurrentStep(3);
                      },
                buttonTitle: currentStep < 2 ? 'Next Step' : 'Complete',
                buttonType: PPButtonType.web,
                showBorder: false,
              ),
            ),
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
}
