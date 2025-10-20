import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:wa_onboarding_module/models/working_day_helper_model.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';

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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select the days when your service is open and then the opening and closing hours',
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
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w500,
                color: day.isOpen ? ColorHelper.grey700.color : ColorHelper.grey300.color,
              ),
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

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour : $minute';
  }

  Future<void> _selectTime(BuildContext context) async {
    if (!enabled) return;
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: time, builder: (context, child) => timePickerTheme(child!));
    if (picked != null) onTimeSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final double buttonWidth = Responsive.value(context: context, mobile: 90.0, tablet: 110.0, desktop: 120.0, widescreen: 130.0);

    final double buttonHeight = Responsive.value(context: context, mobile: 36.0, tablet: 40.0, desktop: 50.0, widescreen: 58.0);

    final double timeFontSize = Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 17.0);

    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: enabled ? ColorHelper.greenWeb.color.withAlpha(180) : ColorHelper.grey150.color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            enabled ? _formatTime(time) : '00 : 00',
            style: theme.textTheme.bodyMedium!.copyWith(
              fontSize: timeFontSize,
              fontWeight: FontWeight.w600,
              color: enabled ? ColorHelper.white.color : ColorHelper.grey300.color,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

Theme timePickerTheme(Widget child) {
  return Theme(
    data: ThemeData(
      colorScheme: ColorScheme.light(
        primary: ColorHelper.greenWeb.color,
        onSurface: ColorHelper.grey700.color,
        surface: ColorHelper.white.color,
        secondary: ColorHelper.greenWeb.color,
      ),
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
        cancelButtonStyle: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(ColorHelper.grey150.color),
          foregroundColor: WidgetStateProperty.all(ColorHelper.grey700.color),
        ),
        confirmButtonStyle: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(ColorHelper.greenWeb.color),
          foregroundColor: WidgetStateProperty.all(ColorHelper.white.color),
        ),
      ),
    ),
    child: child,
  );
}
