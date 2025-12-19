import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class InventoryTexts {
  final AppLocalizations l10n;

  InventoryTexts(BuildContext context) : l10n = AppLocalizations.of(context)!;

  // Screen title
  String get inventoryTitle => l10n.inventoryTitle;

  // Buttons
  String get addInventoryButton => l10n.inventoryAddInventoryButton;
  String get inventoryPreviousButton => l10n.inventoryPreviousButton;
  String get inventoryNextButton => l10n.inventoryNextButton;
  String get inventoryCancelButton => l10n.inventoryCancelButton;
  String get inventoryAddProductButton => l10n.inventoryAddProductButton;
  String get inventoryEditProductButton => l10n.inventoryEditProductButton;

  // Pagination
  String get inventoryPage => l10n.inventoryPage;
  String get inventoryPageOf => l10n.inventoryPageOf;

  // Form labels
  String get inventoryProductNameLabel => l10n.inventoryProductNameLabel;
  String get inventoryDescriptionLabel => l10n.inventoryDescriptionLabel;
  String get inventoryBrandLabel => l10n.inventoryBrandLabel;
  String get inventoryCategoryLabel => l10n.inventoryCategoryLabel;
  String get inventoryPriceLabel => l10n.inventoryPriceLabel;
  String get inventoryCurrencyLabel => l10n.inventoryCurrencyLabel;
  String get inventoryStockQuantityLabel => l10n.inventoryStockQuantityLabel;
  String get inventoryProductImageLabel => l10n.inventoryProductImageLabel;
  String get inventoryTagsLabel => l10n.inventoryTagsLabel;
  String get inventoryActiveStatusLabel => l10n.inventoryActiveStatusLabel;

  // Hints and placeholders
  String get inventoryAddTagHint => l10n.inventoryAddTagHint;
  String get inventoryUploadImageHint => l10n.inventoryUploadImageHint;
  String get inventoryUploadImageFormats => l10n.inventoryUploadImageFormats;

  // Actions
  String get inventoryChangeImage => l10n.inventoryChangeImage;

  // Validation & errors
  String get inventoryRequiredField => l10n.inventoryRequiredField;
  String get inventoryErrorPickingImage => l10n.inventoryErrorPickingImage;
  String get inventoryErrorUploadingImage => l10n.inventoryErrorUploadingImage;
}
