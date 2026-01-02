import 'package:flutter/material.dart';
import 'package:whiskr_admin_panel/l10n/app_localizations.dart';

class ServiceOfferedText {
  final AppLocalizations l10n;

  ServiceOfferedText(BuildContext context) : l10n = AppLocalizations.of(context)!;

  String get serviceOfferedAddService => l10n.serviceOfferedAddService;
  String get serviceOfferedEditService => l10n.serviceOfferedEditService;
  String get serviceOfferedCancel => l10n.serviceOfferedCancel;
  String get serviceOfferedAddServiceButton => l10n.serviceOfferedAddServiceButton;
  String get serviceOfferedUpdateServiceButton => l10n.serviceOfferedUpdateServiceButton;

  String get serviceOfferedServiceName => l10n.serviceOfferedServiceName;
  String get serviceOfferedDescription => l10n.serviceOfferedDescription;
  String get serviceOfferedCategory => l10n.serviceOfferedCategory;
  String get serviceOfferedPrice => l10n.serviceOfferedPrice;
  String get serviceOfferedCurrency => l10n.serviceOfferedCurrency;
  String get serviceOfferedActiveStatus => l10n.serviceOfferedActiveStatus;

  String get serviceOfferedRequiredField => l10n.serviceOfferedRequiredField;
  String get serviceOfferedCustomCategory => l10n.serviceOfferedCustomCategory;

  String get serviceOfferedTags => l10n.serviceOfferedTags;
  String get serviceOfferedQuickSelect => l10n.serviceOfferedQuickSelect;
  String get serviceOfferedSelectedTags => l10n.serviceOfferedSelectedTags;
  String get serviceOfferedAddCustomTagHint => l10n.serviceOfferedAddCustomTagHint;
  String get serviceOfferedAddCustomTagTooltip => l10n.serviceOfferedAddCustomTagTooltip;

  String get serviceOfferedServicesTitle => l10n.serviceOfferedServicesTitle;

  String get serviceOfferedErrorPrefix => l10n.serviceOfferedErrorPrefix;
  String get serviceOfferedRetry => l10n.serviceOfferedRetry;

  String get serviceOfferedNoProductsFound => l10n.serviceOfferedNoProductsFound;
  String get serviceOfferedNoProductsAvailable => l10n.serviceOfferedNoProductsAvailable;
  String get serviceOfferedTryAdjustingSearch => l10n.serviceOfferedTryAdjustingSearch;

  String get serviceOfferedNoOffersFound => l10n.serviceOfferedNoOffersFound;
  String get serviceOfferedNoOffersAvailable => l10n.serviceOfferedNoOffersAvailable;
}
