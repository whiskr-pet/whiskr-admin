import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/buttons/common_button.dart';
import 'package:w_components/divider/fading_divider.dart';
import 'package:w_components/wa_map_picker/wa_map_picker.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:wa_map_module/wa_map_module.dart';
import 'package:wa_onboarding_module/providers/wa_onboarding_provider.dart';

import '../../../../config/flavor_config.dart';

List<_TitleValue> generalInfoRow(WAOnboardingProvider provider) => [
  _TitleValue('Phone', provider.phoneController.text),
  _TitleValue('Email', provider.emailController.text),
  _TitleValue('Website', provider.websiteController.text),
  _TitleValue('Description', provider.descriptionController.text),
];

List<_TitleValue> locationInfoRow(WAOnboardingProvider provider) => [
  _TitleValue('Address', provider.addressController.text),
  _TitleValue('City', provider.cityController.text),
  _TitleValue('State', provider.stateController.text),
  _TitleValue('Zip Code', provider.zipCodeController.text),
  _TitleValue('Note', provider.noteController.text),
];

List<_TitleValue> hoursInfoRow(WAOnboardingProvider provider, BuildContext context) =>
    provider.workingDays.map((day) => _TitleValue(day.name, day.isOpen ? '${day.openingTime.format(context)} - ${day.closingTime.format(context)}' : 'Closed')).toList();

class OnboardingSummaryScreen extends StatelessWidget {
  const OnboardingSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _BuildSummaryBody());
  }
}

class _BuildSummaryBody extends StatelessWidget {
  const _BuildSummaryBody({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WAOnboardingProvider>();

    return Container(
      color: ColorHelper.white.color,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.value(context: context, mobile: 16, tablet: 20, desktop: 10),
        vertical: Responsive.value(context: context, mobile: 16, tablet: 12, desktop: 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BuildSummaryHeader(),
          FadingDivider(color: ColorHelper.greenWeb.color),
          SizedBox(height: Responsive.value(context: context, mobile: 16, desktop: 20)),
          _BuildSegment(title: 'General Information', infoRows: generalInfoRow(provider), widthOfSegment: double.infinity),
          SizedBox(height: Responsive.value(context: context, mobile: 16, desktop: 20)),
          ResponsiveBuilder(
            mobile: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BuildSegment(title: 'Location', infoRows: locationInfoRow(provider), widthOfSegment: double.infinity),
                const SizedBox(height: 20),
                _BuildSegment(title: 'Working Hours', infoRows: hoursInfoRow(provider, context), widthOfSegment: double.infinity),
              ],
            ),
            desktop: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BuildSegment(title: 'Location', infoRows: locationInfoRow(provider), widthOfSegment: 300),
                _BuildSegment(title: 'Working Hours', infoRows: hoursInfoRow(provider, context), widthOfSegment: 300),
              ],
            ),
          ),
          SizedBox(height: Responsive.value(context: context, mobile: 16, desktop: 20)),
          SizedBox(
            height: Responsive.value(context: context, mobile: 250, tablet: 300, desktop: 400),
            child: WAMapPicker(mapboxAccessToken: FlavorConfig.instance.values.mapboxAccessToken, readOnly: true, mapType: MapBoxType.outdoors),
          ),
          SizedBox(height: Responsive.value(context: context, mobile: 16, desktop: 20)),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: CommonButton(onPressed: () {}, buttonTitle: 'Save', buttonType: PPButtonType.web, showBorder: false),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _BuildSummaryHeader extends StatelessWidget {
  const _BuildSummaryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);

    return ResponsiveBuilder(
      mobile: Column(
        children: [
          _BuildImageSummary(),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Happy Shop',
                style: theme.textTheme.bodyLarge!.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text('Pet Shop | Sarajevo, Bosnia and Herzegovina', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
      ),
      desktop: Row(
        children: [
          _BuildImageSummary(),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Happy Shop', style: theme.textTheme.bodyLarge!.copyWith(fontSize: 22, fontWeight: FontWeight.w700)),
              Text('Pet Shop | Sarajevo, Bosnia and Herzegovina'),
            ],
          ),
        ],
      ),
    );
  }
}

// here image will be url image type so use network when come back from BE
class _BuildImageSummary extends StatelessWidget {
  const _BuildImageSummary();

  @override
  Widget build(BuildContext context) {
    final imageSize = Responsive.value(context: context, mobile: 60.0, tablet: 70.0, desktop: 75.0);

    return Center(
      child: Column(
        children: [
          Consumer<WAOnboardingProvider>(
            builder: (context, onboardingProvider, child) => onboardingProvider.serviceImage.isNotEmpty
                ? ClipOval(
                    child: Container(
                      width: imageSize,
                      height: imageSize,
                      color: ColorHelper.grey150.color,
                      child: Image.network('https://images.paramount.tech/path/mgid:file:gsp:entertainment-assets:/sps/shared/characters/kids/eric-cartman.png'),
                    ),
                  )
                : Container(
                    width: imageSize,
                    height: imageSize,
                    decoration: BoxDecoration(color: ColorHelper.grey150.color, shape: BoxShape.circle),
                    child: Icon(Icons.camera_alt, size: imageSize * 0.4),
                  ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _BuildSegment extends StatelessWidget {
  const _BuildSegment({super.key, this.title = 'TITLE', required this.infoRows, this.widthOfSegment = 200});

  final String title;
  final List<_TitleValue> infoRows;
  final double widthOfSegment;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      width: widthOfSegment,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          for (final i in infoRows) Padding(padding: const EdgeInsets.only(top: 8.0), child: _BuildInfoRow(i.title, i.value)),
        ],
      ),
    );
  }
}

class _BuildInfoRow extends StatelessWidget {
  const _BuildInfoRow(this.title, this.value);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final labelWidth = Responsive.value(context: context, mobile: 100.0, tablet: 110.0, desktop: 120.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(title, style: theme.textTheme.bodyMedium),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleValue {
  _TitleValue(this.title, this.value);

  final String title;
  final String value;
}
