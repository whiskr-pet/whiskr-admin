import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_components/buttons/common_button.dart';
import 'package:w_components/wa_custom_stepper/wa_custom_stepper.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';
import 'package:whiskr_admin_panel/app/screens/onboarding_screen/onboarding_general_info_screen/onboarding_stepper/onboarding_general_info_step.dart';
import 'package:whiskr_admin_panel/app/screens/onboarding_screen/onboarding_general_info_screen/onboarding_stepper/onboarding_location_step.dart';
import 'package:whiskr_admin_panel/app/screens/onboarding_screen/onboarding_general_info_screen/onboarding_stepper/onboarding_working_hours_step.dart';
import 'package:whiskr_admin_panel/routing/routes.dart';

class OnboardingStepper extends StatefulWidget {
  const OnboardingStepper({super.key});

  @override
  State<OnboardingStepper> createState() => _OnboardingStepperState();
}

class _OnboardingStepperState extends State<OnboardingStepper> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: StepperContainer(currentStep: context.select<WAOnboardingProvider, int>((provider) => provider.currentStep), onNextStep: context.read<WAOnboardingProvider>().nextStep),
        ),
      ),
    );
  }
}

class StepperContainer extends StatelessWidget {
  final int currentStep;
  final VoidCallback onNextStep;

  const StepperContainer({super.key, required this.currentStep, required this.onNextStep});

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
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            duration: const Duration(milliseconds: 300),
            child: SizedBox(key: ValueKey(currentStep), height: 550, child: _buildStepContent()),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: CommonButton(
              onPressed: currentStep < 2
                  ? onNextStep
                  : () {
                      context.read<WAOnboardingProvider>().saveData();
                      context.go(onboardingSummaryRoute);
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
