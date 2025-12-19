import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class OnboardingTexts {
  final AppLocalizations l10n;

  OnboardingTexts(BuildContext context) : l10n = AppLocalizations.of(context)!;

  // Intro screen
  String get introWelcome => l10n.onboardingIntroWelcome;
  String get introSetup => l10n.onboardingIntroSetup;
  String get getStarted => l10n.onboardingGetStarted;

  // Step titles and descriptions
  String getStepTitle(int step) {
    switch (step) {
      case 0:
        return l10n.onboardingStepTitleGeneral;
      case 1:
        return l10n.onboardingStepTitleLocation;
      case 2:
        return l10n.onboardingStepTitleWorkingHours;
      default:
        return '';
    }
  }

  String getStepDescription(int step) {
    switch (step) {
      case 0:
        return l10n.onboardingStepDescriptionGeneral;
      case 1:
        return l10n.onboardingStepDescriptionLocation;
      case 2:
        return l10n.onboardingStepDescriptionWorkingHours;
      default:
        return '';
    }
  }

  // General Info Step
  String get generalInfoNameLabel => l10n.onboardingGeneralInfoNameLabel;
  String get generalInfoNameHint => l10n.onboardingGeneralInfoNameHint;
  String get generalInfoPhoneLabel => l10n.onboardingGeneralInfoPhoneLabel;
  String get generalInfoPhoneHint => l10n.onboardingGeneralInfoPhoneHint;
  String get generalInfoPhoneFormat => l10n.onboardingGeneralInfoPhoneFormat;
  String get generalInfoDescriptionLabel => l10n.onboardingGeneralInfoDescriptionLabel;
  String get generalInfoDescriptionHint => l10n.onboardingGeneralInfoDescriptionHint;
  String get generalInfoEmailLabel => l10n.onboardingGeneralInfoEmailLabel;
  String get generalInfoEmailHint => l10n.onboardingGeneralInfoEmailHint;
  String get generalInfoWebsiteLabel => l10n.onboardingGeneralInfoWebsiteLabel;
  String get generalInfoWebsiteHint => l10n.onboardingGeneralInfoWebsiteHint;
  String get generalInfoServiceProfilePhoto => l10n.onboardingGeneralInfoServiceProfilePhoto;

  // Image Picker
  String get onboardingWAMultipleImagePickerAddImage => l10n.onboardingWAMultipleImagePickerAddImage;
  String get onboardingWAMultipleImagePickerImageAdded => l10n.onboardingWAMultipleImagePickerImageAdded;
  String get onboardingWAMultipleImagePickerImageRemoved => l10n.onboardingWAMultipleImagePickerImageRemoved;
  String get onboardingWAMultipleImagePickerMaxReached => l10n.onboardingWAMultipleImagePickerMaxReached;
  String get onboardingWAMultipleImagePickerTitle => l10n.onboardingWAMultipleImagePickerTitle;

  // Location Step
  String get locationAddressLabel => l10n.onboardingLocationAddressLabel;
  String get locationAddressHint => l10n.onboardingLocationAddressHint;
  String get locationCityLabel => l10n.onboardingLocationCityLabel;
  String get locationCityHint => l10n.onboardingLocationCityHint;
  String get locationStateLabel => l10n.onboardingLocationStateLabel;
  String get locationStateHint => l10n.onboardingLocationStateHint;
  String get locationZipLabel => l10n.onboardingLocationZipLabel;
  String get locationZipHint => l10n.onboardingLocationZipHint;
  String get locationNoteLabel => l10n.onboardingLocationNoteLabel;
  String get locationNoteHint => l10n.onboardingLocationNoteHint;

  // Working Hours Step
  String get whHeader => l10n.onboardingWorkingHoursHeader;

  // Summary Screen
  String get onboardingSummaryHeaderTitle => l10n.onboardingSummaryHeaderTitle;
  String get onboardingSummaryHeaderSubtitle => l10n.onboardingSummaryHeaderSubtitle;
  String get onboardingSummaryStepIndicator => l10n.onboardingSummaryStepIndicator;
  String get summaryTitleGeneralInfo => l10n.onboardingSummaryTitleGeneralInfo;
  String get summaryTitleLocation => l10n.onboardingSummaryTitleLocation;
  String get summaryTitleWorkingHours => l10n.onboardingSummaryTitleWorkingHours;
  String get onboardingSummaryBusinessPending => l10n.onboardingSummaryBusinessPending;
  String get onboardingSummaryLocationNotSet => l10n.onboardingSummaryLocationNotSet;
  String get onboardingSummaryImageUploadedSingle => l10n.onboardingSummaryImageUploadedSingle;
  String get onboardingSummaryImageUploadedPlural => l10n.onboardingSummaryImageUploadedPlural;
  String get onboardingSummaryHighlightBusiness => l10n.onboardingSummaryHighlightBusiness;
  String get onboardingSummaryHighlightLocation => l10n.onboardingSummaryHighlightLocation;
  String get onboardingSummaryHighlightMedia => l10n.onboardingSummaryHighlightMedia;
  String get onboardingSummaryEdit => l10n.onboardingSummaryEdit;
  String get onboardingSummaryImageSingular => l10n.onboardingSummaryImageSingular;
  String get onboardingSummaryImagePlural => l10n.onboardingSummaryImagePlural;
  String get onboardingSummaryImagesTitle => l10n.onboardingSummaryImagesTitle;
  String get onboardingSummaryMapTitle => l10n.onboardingSummaryMapTitle;
  String get onboardingSummaryMapDescription => l10n.onboardingSummaryMapDescription;
  String get onboardingSummarySubmitComplete => l10n.onboardingSummarySubmitComplete;

  // Helper labels (for onboarding_organization_helper.dart)
  String get helperPhone => l10n.onboardingHelperPhone;
  String get helperEmail => l10n.onboardingHelperEmail;
  String get helperWebsite => l10n.onboardingHelperWebsite;
  String get helperAddress => l10n.onboardingHelperAddress;
  String get helperCity => l10n.onboardingHelperCity;
  String get helperState => l10n.onboardingHelperState;
  String get helperZipCode => l10n.onboardingHelperZipCode;
  String get helperNote => l10n.onboardingHelperNote;
  String get helperClosed => l10n.onboardingHelperClosed;
}
