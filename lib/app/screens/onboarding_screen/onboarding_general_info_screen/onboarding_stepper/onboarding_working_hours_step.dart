import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:wa_onboarding_module/models/working_day_helper_model.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';
import 'package:whiskr_admin_panel/app/helpers/utils/onboarding_utils/onboarding_action_utils.dart';

import '../../../../../l10n/models/screen_texts/onboarding_texts.dart';
import '../../../../providers/texts_provider.dart';

class OnboardingWorkingHoursStep extends StatefulWidget {
  const OnboardingWorkingHoursStep({super.key});

  @override
  State<OnboardingWorkingHoursStep> createState() => _OnboardingWorkingHoursStepState();
}

class _OnboardingWorkingHoursStepState extends State<OnboardingWorkingHoursStep> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<WAOnboardingProvider>();
    final workingDays = provider.workingDays;
    final double headerFontSize = Responsive.value(context: context, mobile: 14.0, tablet: 16.0, desktop: 18.0, widescreen: 20.0);

    final double verticalSpacing = Responsive.value(context: context, mobile: 16.0, tablet: 20.0, desktop: 18.0, widescreen: 20.0);

    final double horizontalPadding = Responsive.value(context: context, mobile: 16.0, tablet: 24.0, desktop: 32.0, widescreen: 40.0);
    final OnboardingTexts texts = TextsProvider.of(context)!.onboardingTexts;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts.whHeader,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: headerFontSize, fontWeight: FontWeight.w500, color: ColorHelper.greenWeb.color),
          ),
          SizedBox(height: verticalSpacing),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: workingDays.length,
            separatorBuilder: (context, index) => SizedBox(height: 8),
            itemBuilder: (context, index) {
              return SizedBox(
                height: 60,
                child: WorkingDayItem(
                  day: workingDays[index],
                  onToggle: () => provider.toggleWorkingDay(index),
                  onOpeningTimeChanged: (time) => provider.setWorkingDayOpeningTime(index, time),
                  onClosingTimeChanged: (time) => provider.setWorkingDayClosingTime(index, time),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class WorkingDayItem extends StatelessWidget {
  final WorkingDay day;
  final VoidCallback onToggle;
  final ValueChanged<TimeOfDay> onOpeningTimeChanged;
  final ValueChanged<TimeOfDay> onClosingTimeChanged;

  const WorkingDayItem({super.key, required this.day, required this.onToggle, required this.onOpeningTimeChanged, required this.onClosingTimeChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double labelFontSize = Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 17.0);

    final double horizontalPadding = Responsive.value(context: context, mobile: 12.0, tablet: 16.0, desktop: 18.0, widescreen: 20.0);

    final double verticalPadding = Responsive.value(context: context, mobile: 12.0, tablet: 14.0, desktop: 14.0, widescreen: 14.0);

    final double checkboxSize = Responsive.value(context: context, mobile: 20.0, tablet: 22.0, desktop: 24.0, widescreen: 24.0);

    final double spacingBetweenElements = Responsive.value(context: context, mobile: 8.0, tablet: 12.0, desktop: 14.0, widescreen: 16.0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: ColorHelper.white.color,
        border: Border.all(color: ColorHelper.grey200.color, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: checkboxSize,
              height: checkboxSize,
              decoration: BoxDecoration(
                color: day.isOpen ? ColorHelper.greenWeb.color : ColorHelper.white.color,
                border: Border.all(color: day.isOpen ? ColorHelper.greenWeb.color : ColorHelper.grey200.color, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: day.isOpen ? Icon(Icons.check_rounded, color: ColorHelper.white.color, size: checkboxSize * 0.8) : null,
            ),
          ),
          SizedBox(width: spacingBetweenElements),
          Expanded(
            child: Text(
              day.name,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: labelFontSize, fontWeight: FontWeight.w500, color: day.isOpen ? ColorHelper.grey700.color : ColorHelper.grey300.color),
            ),
          ),
          TimePickerButton(time: day.openingTime, enabled: day.isOpen, onTimeSelected: onOpeningTimeChanged),
          SizedBox(width: spacingBetweenElements),
          TimePickerButton(time: day.closingTime, enabled: day.isOpen, onTimeSelected: onClosingTimeChanged),
        ],
      ),
    );
  }
}

class TimePickerButton extends StatelessWidget {
  final TimeOfDay time;
  final bool enabled;
  final ValueChanged<TimeOfDay> onTimeSelected;

  const TimePickerButton({super.key, required this.time, required this.enabled, required this.onTimeSelected});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final double buttonWidth = Responsive.value(context: context, mobile: 90.0, tablet: 110.0, desktop: 120.0, widescreen: 130.0);

    final double buttonHeight = Responsive.value(context: context, mobile: 36.0, tablet: 40.0, desktop: 50.0, widescreen: 58.0);

    final double timeFontSize = Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 17.0);

    return GestureDetector(
      onTap: () => OnboardingActionUtils.selectTime(context, time, onTimeSelected, enabled: enabled),
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(color: enabled ? ColorHelper.greenWeb.color.withAlpha(180) : ColorHelper.grey150.color, borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            enabled ? OnboardingActionUtils.formatTime(time) : '00 : 00',
            style: theme.textTheme.bodyMedium!.copyWith(fontSize: timeFontSize, fontWeight: FontWeight.w600, color: enabled ? ColorHelper.white.color : ColorHelper.grey300.color, letterSpacing: 1.0),
          ),
        ),
      ),
    );
  }
}
