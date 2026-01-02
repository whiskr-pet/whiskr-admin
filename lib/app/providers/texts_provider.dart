import 'package:flutter/material.dart';

import '../../localization_models/localization_models.dart';

class TextsProvider extends InheritedWidget {
  final LoginTexts loginTexts;
  final OnboardingTexts onboardingTexts;
  final InventoryTexts inventoryTexts;
  final ServiceOfferedText serviceOfferedText;

  const TextsProvider({super.key, required this.loginTexts, required this.onboardingTexts, required this.inventoryTexts, required this.serviceOfferedText, required super.child});

  /// Access the TextsProvider from any descendant widget
  static TextsProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TextsProvider>();
  }

  @override
  bool updateShouldNotify(TextsProvider oldWidget) {
    // Only notify descendants if the locale actually changed
    return loginTexts.l10n.localeName != oldWidget.loginTexts.l10n.localeName;
  }
}
