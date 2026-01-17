import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_components/buttons/common_button.dart';
import 'package:w_components/text_fields/wa_custom_text_field.dart';
import 'package:w_components/wa_custom_snackbar/wa_custom_snackbar.dart';
import 'package:w_components/wa_map_picker/wa_map_picker.dart';
import 'package:w_image_module/helpers/image_constants.dart';
import 'package:w_image_module/providers/image_provider.dart';
import 'package:w_utils/models/image_model.dart';
import 'package:w_utils/models/response_model.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:w_utils/w_utils.dart' show FormDataFileBytes;
import 'package:wa_map_module/wa_map_module.dart';
import 'package:wa_onboarding_module/models/wa_onboarding_request_model.dart';
import 'package:wa_onboarding_module/providers/wa_service_profile_provider.dart';
import 'package:whiskr_admin_panel/app/helpers/loading_animation_helper.dart';
import 'package:whiskr_admin_panel/app/helpers/utils/onboarding_utils/onboarding_action_utils.dart';
import 'package:whiskr_admin_panel/app/providers/texts_provider.dart';
import 'package:whiskr_admin_panel/config/flavor_config.dart';
import 'package:whiskr_admin_panel/l10n/app_localizations.dart';
import 'package:whiskr_admin_panel/localization_models/localization_models.dart';
import 'package:whiskr_admin_panel/widgets/wa_multiple_images.dart';

class SettingsEditProfileScreen extends StatefulWidget {
  const SettingsEditProfileScreen({super.key});

  @override
  State<SettingsEditProfileScreen> createState() => _SettingsEditProfileScreenState();
}

class _SettingsEditProfileScreenState extends State<SettingsEditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final List<_WorkingDayDraft> _workingDays = <_WorkingDayDraft>[
    _WorkingDayDraft(dayKey: 'monday', label: 'Monday'),
    _WorkingDayDraft(dayKey: 'tuesday', label: 'Tuesday'),
    _WorkingDayDraft(dayKey: 'wednesday', label: 'Wednesday'),
    _WorkingDayDraft(dayKey: 'thursday', label: 'Thursday'),
    _WorkingDayDraft(dayKey: 'friday', label: 'Friday'),
    _WorkingDayDraft(dayKey: 'saturday', label: 'Saturday'),
    _WorkingDayDraft(dayKey: 'sunday', label: 'Sunday'),
  ];

  bool _controllersBound = false;
  bool _isHydratingControllers = false;
  bool _didInitialFetch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _bootstrap();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();

    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (_didInitialFetch) {
      return;
    }
    _didInitialFetch = true;

    // Clear any leftover picked images in the shared image provider so this screen starts clean.
    final ImageHandleProvider imageProvider = context.read<ImageHandleProvider>();
    imageProvider.setImageBytesList(<Uint8List>[]);

    final WAServiceProfileProvider profileProvider = context.read<WAServiceProfileProvider>();
    final ResponseModel<WaOnboardingModel> response = await profileProvider.fetchProfile();
    if (!mounted) {
      return;
    }

    if (!response.isSuccess || response.data == null) {
      OnboardingActionUtils.showError(context, response.error ?? 'Failed to fetch profile');
      return;
    }

    _hydrateFromProvider(profileProvider);
    _bindControllerListenersIfNeeded(profileProvider);
  }

  void _hydrateFromProvider(WAServiceProfileProvider profileProvider) {
    _isHydratingControllers = true;
    try {
      _nameController.text = profileProvider.draftName;
      _descriptionController.text = profileProvider.draftDescription;
      _phoneController.text = profileProvider.draftPhone;
      _emailController.text = profileProvider.draftEmail;
      _websiteController.text = profileProvider.draftWebsite;

      _addressController.text = profileProvider.draftAddress;
      _cityController.text = profileProvider.draftCity;
      _stateController.text = profileProvider.draftState;
      _zipCodeController.text = profileProvider.draftZipCode;
      _noteController.text = (profileProvider.profile?.location?.note ?? '');

      final WaOnboardingModel? profile = profileProvider.profile;
      final Map<String, DayHoursModel> weekly = profile?.hours?.weeklyHours ?? <String, DayHoursModel>{};
      _hydrateWorkingDaysFromWeeklyHours(weekly);
    } finally {
      _isHydratingControllers = false;
    }
  }

  void _bindControllerListenersIfNeeded(WAServiceProfileProvider profileProvider) {
    if (_controllersBound) {
      return;
    }
    _controllersBound = true;

    void bind({required TextEditingController controller, required ValueChanged<String> onChange}) {
      controller.addListener(() {
        if (_isHydratingControllers) {
          return;
        }
        onChange(controller.text);
      });
    }

    bind(controller: _nameController, onChange: profileProvider.setDraftName);
    bind(controller: _descriptionController, onChange: profileProvider.setDraftDescription);
    bind(controller: _phoneController, onChange: profileProvider.setDraftPhone);
    bind(controller: _emailController, onChange: profileProvider.setDraftEmail);
    bind(controller: _websiteController, onChange: profileProvider.setDraftWebsite);

    bind(controller: _addressController, onChange: profileProvider.setDraftAddress);
    bind(controller: _cityController, onChange: profileProvider.setDraftCity);
    bind(controller: _stateController, onChange: profileProvider.setDraftState);
    bind(controller: _zipCodeController, onChange: profileProvider.setDraftZipCode);
  }

  void _hydrateWorkingDaysFromWeeklyHours(Map<String, DayHoursModel> weeklyHours) {
    final Map<String, DayHoursModel> normalized = <String, DayHoursModel>{};
    weeklyHours.forEach((String k, DayHoursModel v) {
      normalized[k.toLowerCase()] = v;
    });

    for (final _WorkingDayDraft day in _workingDays) {
      final DayHoursModel? model = normalized[day.dayKey];
      if (model == null) {
        day.isOpen = false;
        continue;
      }

      final TimeOfDay? open = _parseApiTime(model.open);
      final TimeOfDay? close = _parseApiTime(model.close);

      final bool isClosedSentinel = _isClosedSentinelTime(open: open, close: close, rawOpen: model.open, rawClose: model.close);
      if (isClosedSentinel) {
        day.isOpen = false;
        continue;
      }

      day.isOpen = true;
      day.openingTime = open ?? day.openingTime;
      day.closingTime = close ?? day.closingTime;
    }

    setState(() {});
  }

  TimeOfDay? _parseApiTime(String? value) {
    final String raw = (value ?? '').trim();
    if (raw.isEmpty) {
      return null;
    }

    // Support: "HH:mm", "HH : mm", "HH:mm:ss", "HH:mm:ss.SSS"
    final String sanitized = raw.replaceAll(' ', '');
    final RegExp re = RegExp(r'^(\d{1,2}):(\d{1,2})(?::(\d{1,2}))?(?:\.\d+)?$');
    final RegExpMatch? match = re.firstMatch(sanitized);
    if (match == null) {
      return null;
    }

    final int? hour = int.tryParse(match.group(1) ?? '');
    final int? minute = int.tryParse(match.group(2) ?? '');
    if (hour == null || minute == null) {
      return null;
    }
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  bool _isClosedSentinelTime({required TimeOfDay? open, required TimeOfDay? close, required String? rawOpen, required String? rawClose}) {
    final bool bothMissing = ((rawOpen ?? '').trim().isEmpty) && ((rawClose ?? '').trim().isEmpty);
    if (bothMissing) {
      return true;
    }

    final bool openZero = open != null && open.hour == 0 && open.minute == 0;
    final bool closeZero = close != null && close.hour == 0 && close.minute == 0;
    return openZero && closeZero;
  }

  Future<void> _pickAndUploadProfileImage() async {
    final ImageHandleProvider imageProvider = context.read<ImageHandleProvider>();
    final WAServiceProfileProvider profileProvider = context.read<WAServiceProfileProvider>();

    final ResponseModel<FormDataFileBytes?> pickResult = await imageProvider.pickImageForWeb();
    if (!mounted) {
      return;
    }
    if (!pickResult.isSuccess) {
      WACustomSnackbar.instance.showSnack(context, pickResult.error ?? 'No image selected', type: WACustomSnackbarType.error);
      return;
    }

    final ResponseModel<ImageModel> uploadResult = await imageProvider.uploadWebSingleImage(ProviderImageConstants.userProviderImages);
    if (!mounted) {
      return;
    }
    if (!uploadResult.isSuccess || uploadResult.data == null) {
      WACustomSnackbar.instance.showSnack(context, uploadResult.error ?? 'Failed to upload image', type: WACustomSnackbarType.error);
      return;
    }

    profileProvider.setDraftProfileImage(uploadResult.data);
    WACustomSnackbar.instance.showSnack(context, 'Profile image updated', type: WACustomSnackbarType.success);
  }

  void _onMapConfirm(MapPickerResult pos) {
    final WAServiceProfileProvider profileProvider = context.read<WAServiceProfileProvider>();

    final double latitude = pos.location.latitude;
    final double longitude = pos.location.longitude;

    profileProvider.setDraftLatitude(latitude);
    profileProvider.setDraftLongitude(longitude);

    _isHydratingControllers = true;
    try {
      _zipCodeController.text = pos.address.zip ?? '';
      _stateController.text = pos.address.country ?? '';
      _cityController.text = pos.address.city ?? '';
      _addressController.text = pos.address.streetAddress ?? '';
    } finally {
      _isHydratingControllers = false;
    }

    // push changes into draft (since we muted controller listeners above)
    profileProvider.setDraftZipCode(_zipCodeController.text);
    profileProvider.setDraftState(_stateController.text);
    profileProvider.setDraftCity(_cityController.text);
    profileProvider.setDraftAddress(_addressController.text);
  }

  String _formatTimeForApi(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _setWorkingDayOpen(int index, bool isOpen) {
    final WAServiceProfileProvider profileProvider = context.read<WAServiceProfileProvider>();
    final _WorkingDayDraft day = _workingDays[index];
    day.isOpen = isOpen;

    if (!isOpen) {
      // Persist closure as sentinel value (backend often returns closed days as 00:00/00:00).
      profileProvider.setDraftHoursForDay(dayKey: day.dayKey, open: '00:00', close: '00:00');
    } else {
      profileProvider.setDraftHoursForDay(dayKey: day.dayKey, open: _formatTimeForApi(day.openingTime), close: _formatTimeForApi(day.closingTime));
    }

    setState(() {});
  }

  void _setWorkingDayOpeningTime(int index, TimeOfDay time) {
    final WAServiceProfileProvider profileProvider = context.read<WAServiceProfileProvider>();
    final _WorkingDayDraft day = _workingDays[index];
    day.openingTime = time;
    day.isOpen = true;
    profileProvider.setDraftHoursForDay(dayKey: day.dayKey, open: _formatTimeForApi(day.openingTime), close: _formatTimeForApi(day.closingTime));
    setState(() {});
  }

  void _setWorkingDayClosingTime(int index, TimeOfDay time) {
    final WAServiceProfileProvider profileProvider = context.read<WAServiceProfileProvider>();
    final _WorkingDayDraft day = _workingDays[index];
    day.closingTime = time;
    day.isOpen = true;
    profileProvider.setDraftHoursForDay(dayKey: day.dayKey, open: _formatTimeForApi(day.openingTime), close: _formatTimeForApi(day.closingTime));
    setState(() {});
  }

  String? _validateBeforeSave() {
    final String name = _nameController.text.trim();
    final String phone = _phoneController.text.trim();
    final String email = _emailController.text.trim();
    final String description = _descriptionController.text.trim();

    final String address = _addressController.text.trim();
    final String city = _cityController.text.trim();
    final String state = _stateController.text.trim();
    final String zip = _zipCodeController.text.trim();

    if (name.isEmpty) return 'Service name is required';
    if (phone.isEmpty) return 'Phone number is required';
    if (email.isEmpty) return 'Email is required';
    if (description.isEmpty) return 'Description is required';
    if (address.isEmpty) return 'Address is required';
    if (city.isEmpty) return 'City is required';
    if (state.isEmpty) return 'State is required';
    if (zip.isEmpty) return 'Zip code is required';

    final bool hasAnyOpenDay = _workingDays.any((_WorkingDayDraft d) => d.isOpen);
    if (!hasAnyOpenDay) return 'At least one working day is required';

    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final String? error = _validateBeforeSave();
    if (error != null) {
      OnboardingActionUtils.showError(context, error);
      return;
    }

    final WAServiceProfileProvider profileProvider = context.read<WAServiceProfileProvider>();
    final ImageHandleProvider imageProvider = context.read<ImageHandleProvider>();

    // Upload newly picked gallery images (if any) into ImageModels, then mark draft as dirty.
    if (imageProvider.imageBytesList.isNotEmpty) {
      final ResponseModel<List<ImageModel>> upload = await imageProvider.uploadMultipleImages(ProviderImageConstants.userProviderImages);
      if (!mounted) {
        return;
      }
      if (!upload.isSuccess || upload.data == null) {
        OnboardingActionUtils.showError(context, upload.error ?? 'Failed to upload images');
        return;
      }

      final List<ImageModel> merged = <ImageModel>[...profileProvider.draftImages, ...upload.data!];

      profileProvider.setDraftImages(merged);
      imageProvider.setImageBytesList(<Uint8List>[]);
    }

    final ResponseModel<WaOnboardingModel> response = await profileProvider.save();
    if (!mounted) {
      return;
    }

    if (response.isSuccess) {
      await profileProvider.fetchProfile();
      if (!mounted) {
        return;
      }
      if (response.isSuccess) {
        OnboardingActionUtils.showSuccess(context, 'Profile saved successfully!');
      } else {
        OnboardingActionUtils.showError(context, response.error ?? 'Failed to refresh profile after save');
      }
    } else {
      OnboardingActionUtils.showError(context, response.error ?? 'Failed to save profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final OnboardingTexts texts = TextsProvider.of(context)!.onboardingTexts;

    final bool isLoading = context.select<WAServiceProfileProvider, bool>((WAServiceProfileProvider p) => p.isLoading);
    final bool hasUnsavedChanges = context.select<WAServiceProfileProvider, bool>((WAServiceProfileProvider p) => p.hasUnsavedChanges);
    final bool hasPendingPickedImages = context.select<ImageHandleProvider, bool>((ImageHandleProvider p) => p.imageBytesList.isNotEmpty);
    final bool canSave = hasUnsavedChanges || hasPendingPickedImages;

    final ImageModel? profileImage = context.select<WAServiceProfileProvider, ImageModel?>((WAServiceProfileProvider p) => p.draftProfileImage);
    final List<ImageModel> galleryImages = context.select<WAServiceProfileProvider, List<ImageModel>>((WAServiceProfileProvider p) => List<ImageModel>.from(p.draftImages));
    final int pendingPickedCount = context.select<ImageHandleProvider, int>((ImageHandleProvider p) => p.imageBytesList.length);
    const int maxGalleryImages = 5;
    final int existingCount = galleryImages.length;
    final int totalCount = existingCount + pendingPickedCount;
    final int remainingSlots = (maxGalleryImages - existingCount).clamp(0, maxGalleryImages);

    final String headerName = context.select<WAServiceProfileProvider, String>((WAServiceProfileProvider p) => p.draftName);
    final String headerEmail = context.select<WAServiceProfileProvider, String>((WAServiceProfileProvider p) => p.draftEmail);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: Responsive.value(context: context, mobile: 16.0, tablet: 60.0, desktop: 120.0, widescreen: 200.0)),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _HeaderBar(title: l10n.settingsEditProfile, onBack: () => context.pop(), onSave: canSave ? _save : null),
                        const SizedBox(height: 16),
                        _HeroCard(
                          businessName: headerName.isEmpty ? 'Your business' : headerName,
                          email: headerEmail.isEmpty ? '—' : headerEmail,
                          profileImageUrl: (profileImage?.url ?? ''),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Media',
                          subtitle: 'Update your profile photo and service gallery.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text('Profile photo', style: themeData.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                                  ),
                                  SizedBox(
                                    height: 50,
                                    child: CommonButton(onPressed: _pickAndUploadProfileImage, buttonTitle: 'Change', buttonType: PPButtonType.web, showBorder: false),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _ExistingImagesGallery(
                                images: galleryImages,
                                onRemove: (ImageModel image) {
                                  final WAServiceProfileProvider p = context.read<WAServiceProfileProvider>();
                                  final List<ImageModel> next = List<ImageModel>.from(p.draftImages)..remove(image);
                                  p.setDraftImages(next);
                                },
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Total: $totalCount/$maxGalleryImages',
                                  style: themeData.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(height: 18),
                              if (remainingSlots > 0)
                                WAMultipleImagePicker(
                                  maxImages: remainingSlots,
                                  onImagesChanged: (List<Uint8List> images) => context.read<ImageHandleProvider>().setImageBytesList(images),
                                  initialImages: context.select<ImageHandleProvider, List<Uint8List>>((ImageHandleProvider p) => p.imageBytesList),
                                  addImageLabel: texts.onboardingWAMultipleImagePickerAddImage,
                                  imageAddedMessage: texts.onboardingWAMultipleImagePickerImageAdded,
                                  imageRemovedMessage: texts.onboardingWAMultipleImagePickerImageRemoved,
                                  maxReachedMessage: texts.onboardingWAMultipleImagePickerMaxReached,
                                  title: texts.onboardingWAMultipleImagePickerTitle,
                                )
                              else
                                Text(
                                  'You have reached the maximum of $maxGalleryImages images.',
                                  style: themeData.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                ),
                              const SizedBox(height: 10),
                              Text('Newly selected images will upload on Save.', style: themeData.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'General info',
                          subtitle: 'These details are shown to customers.',
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: WACustomTextField(controller: _nameController, label: texts.generalInfoNameLabel, hint: texts.generalInfoNameHint),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: WACustomTextField(
                                      controller: _phoneController,
                                      label: texts.generalInfoPhoneLabel,
                                      hint: texts.generalInfoPhoneHint,
                                      type: WATextFieldType.phone,
                                      phoneFormat: texts.generalInfoPhoneFormat,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              WACustomTextField(
                                controller: _descriptionController,
                                label: texts.generalInfoDescriptionLabel,
                                hint: texts.generalInfoDescriptionHint,
                                maxLines: 4,
                                maxLength: 600,
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: WACustomTextField(
                                      controller: _emailController,
                                      label: texts.generalInfoEmailLabel,
                                      hint: texts.generalInfoEmailHint,
                                      type: WATextFieldType.email,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: WACustomTextField(
                                      controller: _websiteController,
                                      label: texts.generalInfoWebsiteLabel,
                                      hint: texts.generalInfoWebsiteHint,
                                      type: WATextFieldType.url,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Location',
                          subtitle: 'Set where your business operates.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              SizedBox(
                                height: 260,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: WAMapPicker(
                                    mapboxAccessToken: FlavorConfig.instance.values.mapboxAccessToken,
                                    showAddress: true,
                                    mapType: MapBoxType.outdoors,
                                    onConfirm: _onMapConfirm,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              WACustomTextField(controller: _addressController, label: texts.locationAddressLabel, hint: texts.locationAddressHint),
                              const SizedBox(height: 18),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: WACustomTextField(controller: _cityController, label: texts.locationCityLabel, hint: texts.locationCityHint),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: WACustomTextField(controller: _stateController, label: texts.locationStateLabel, hint: texts.locationStateHint),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: WACustomTextField(controller: _zipCodeController, label: texts.locationZipLabel, hint: texts.locationZipHint),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: WACustomTextField(controller: _noteController, label: texts.locationNoteLabel, hint: texts.locationNoteHint),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Working hours',
                          subtitle: 'Control availability per day.',
                          child: _WorkingHoursEditor(
                            days: _workingDays,
                            onToggle: (int index) => _setWorkingDayOpen(index, !_workingDays[index].isOpen),
                            onOpeningTimeChanged: (int index, TimeOfDay time) => _setWorkingDayOpeningTime(index, time),
                            onClosingTimeChanged: (int index, TimeOfDay time) => _setWorkingDayClosingTime(index, time),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 220,
                            height: 50,
                            child: CommonButton(onPressed: canSave ? _save : null, buttonTitle: 'Save changes', buttonType: PPButtonType.web, showBorder: false),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (isLoading) LoadingAnimationHelper.loading,
          ],
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.title, required this.onBack, required this.onSave});

  final String title;
  final VoidCallback onBack;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;

    return Row(
      children: <Widget>[
        IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back), tooltip: MaterialLocalizations.of(context).backButtonTooltip),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: themeData.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: colorScheme.primary),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 170,
          height: 50,
          child: CommonButton(onPressed: onSave, buttonTitle: 'Save', buttonType: PPButtonType.web, showBorder: false),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.businessName, required this.email, required this.profileImageUrl});

  final String businessName;
  final String email;
  final String profileImageUrl;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: <Color>[colorScheme.primary.withValues(alpha: 0.12), colorScheme.surface], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
        boxShadow: <BoxShadow>[BoxShadow(color: themeData.shadowColor.withValues(alpha: 0.10), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 28,
            backgroundColor: colorScheme.surfaceContainerHighest,
            backgroundImage: profileImageUrl.isEmpty ? null : NetworkImage(profileImageUrl),
            child: profileImageUrl.isEmpty ? Icon(Icons.storefront_outlined, color: colorScheme.onSurfaceVariant) : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(businessName, style: themeData.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: themeData.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.tune_rounded, size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Edit profile',
                  style: themeData.textTheme.bodySmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
        boxShadow: <BoxShadow>[BoxShadow(color: themeData.shadowColor.withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: themeData.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(subtitle, style: themeData.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ExistingImagesGallery extends StatelessWidget {
  const _ExistingImagesGallery({required this.images, required this.onRemove});

  final List<ImageModel> images;
  final ValueChanged<ImageModel> onRemove;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;

    if (images.isEmpty) {
      return Text('No gallery images yet.', style: themeData.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Existing gallery', style: themeData.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: images.map((ImageModel img) {
            final String url = (img.thumbnail?.isNotEmpty ?? false) ? (img.thumbnail ?? '') : (img.url ?? '');
            return _ExistingImageTile(imageUrl: url, onRemove: () => onRemove(img), borderColor: colorScheme.outline.withValues(alpha: 0.35));
          }).toList(),
        ),
      ],
    );
  }
}

class _ExistingImageTile extends StatelessWidget {
  const _ExistingImageTile({required this.imageUrl, required this.onRemove, required this.borderColor});

  final String imageUrl;
  final VoidCallback onRemove;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: imageUrl.isEmpty ? ColoredBox(color: colorScheme.surfaceContainerHighest) : Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: IconButton(
              onPressed: onRemove,
              style: IconButton.styleFrom(backgroundColor: colorScheme.surface.withValues(alpha: 0.90)),
              icon: Icon(Icons.close_rounded, size: 18, color: colorScheme.error),
              tooltip: 'Remove',
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkingDayDraft {
  _WorkingDayDraft({required this.dayKey, required this.label}) {
    isOpen = false;
    openingTime = const TimeOfDay(hour: 8, minute: 0);
    closingTime = const TimeOfDay(hour: 18, minute: 0);
  }

  final String dayKey;
  final String label;
  late bool isOpen;
  late TimeOfDay openingTime;
  late TimeOfDay closingTime;
}

class _WorkingHoursEditor extends StatelessWidget {
  const _WorkingHoursEditor({required this.days, required this.onToggle, required this.onOpeningTimeChanged, required this.onClosingTimeChanged});

  final List<_WorkingDayDraft> days;
  final ValueChanged<int> onToggle;
  final void Function(int index, TimeOfDay time) onOpeningTimeChanged;
  final void Function(int index, TimeOfDay time) onClosingTimeChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;

    final double headerFontSize = Responsive.value(context: context, mobile: 14.0, tablet: 16.0, desktop: 18.0, widescreen: 20.0);
    final double verticalSpacing = Responsive.value(context: context, mobile: 16.0, tablet: 20.0, desktop: 18.0, widescreen: 20.0);
    final double labelFontSize = Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 17.0);
    final double buttonWidth = Responsive.value(context: context, mobile: 90.0, tablet: 110.0, desktop: 120.0, widescreen: 130.0);
    final double buttonHeight = Responsive.value(context: context, mobile: 36.0, tablet: 40.0, desktop: 50.0, widescreen: 58.0);
    final double timeFontSize = Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 17.0);
    final double checkboxSize = Responsive.value(context: context, mobile: 20.0, tablet: 22.0, desktop: 24.0, widescreen: 24.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Working hours',
          style: themeData.textTheme.bodyMedium?.copyWith(fontSize: headerFontSize, fontWeight: FontWeight.w500, color: colorScheme.primary),
        ),
        SizedBox(height: verticalSpacing),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days.length,
          separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
          itemBuilder: (BuildContext context, int index) {
            final _WorkingDayDraft day = days[index];
            return Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.outline.withValues(alpha: 0.6), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => onToggle(index),
                    child: Container(
                      width: checkboxSize,
                      height: checkboxSize,
                      decoration: BoxDecoration(
                        color: day.isOpen ? colorScheme.primary : colorScheme.surface,
                        border: Border.all(color: day.isOpen ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.6), width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: day.isOpen ? Icon(Icons.check_rounded, color: colorScheme.onPrimary, size: checkboxSize * 0.8) : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      day.label,
                      style: themeData.textTheme.bodyMedium?.copyWith(
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w500,
                        color: day.isOpen ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  _TimeButton(
                    time: day.openingTime,
                    enabled: day.isOpen,
                    width: buttonWidth,
                    height: buttonHeight,
                    fontSize: timeFontSize,
                    onPick: (TimeOfDay t) => onOpeningTimeChanged(index, t),
                  ),
                  const SizedBox(width: 12),
                  _TimeButton(
                    time: day.closingTime,
                    enabled: day.isOpen,
                    width: buttonWidth,
                    height: buttonHeight,
                    fontSize: timeFontSize,
                    onPick: (TimeOfDay t) => onClosingTimeChanged(index, t),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({required this.time, required this.enabled, required this.width, required this.height, required this.fontSize, required this.onPick});

  final TimeOfDay time;
  final bool enabled;
  final double width;
  final double height;
  final double fontSize;
  final ValueChanged<TimeOfDay> onPick;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final String title = enabled ? OnboardingActionUtils.formatTime(time) : '00 : 00';

    return GestureDetector(
      onTap: () => OnboardingActionUtils.selectTime(context, time, onPick, enabled: enabled),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(color: enabled ? colorScheme.primary.withValues(alpha: 0.85) : colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            title,
            style: themeData.textTheme.bodyMedium!.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: enabled ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
