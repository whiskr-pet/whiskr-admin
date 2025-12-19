import 'package:flutter/material.dart';
import 'package:whiskr_admin_panel/l10n/app_localizations.dart';

class LoginTexts {
  final AppLocalizations l10n;

  LoginTexts(BuildContext context) : l10n = AppLocalizations.of(context)!;

  String get welcomeTitle => l10n.loginWelcomeTitle;
  String get subtitle => l10n.loginSubtitle;
  String get emailLabel => l10n.loginEmailLabel;
  String get passwordLabel => l10n.loginPasswordLabel;
  String get signInButton => l10n.loginSignInButton;
  String get forgotPasswordButton => l10n.loginForgotPasswordButton;
  String get copyrightFooter => l10n.loginCopyrightFooter;
  String get forgotPasswordComingSoon => l10n.loginForgotPasswordComingSoon;
}
