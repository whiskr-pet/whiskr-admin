import 'package:flutter/material.dart';
import 'package:whiskr_admin_panel/l10n/models/localized_texts.dart';

class TextsProvider extends InheritedWidget {
  final LoginTexts loginTexts;
  final OnboardingTexts onboardingTexts;

  const TextsProvider({super.key, required this.loginTexts, required this.onboardingTexts, required super.child});

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
