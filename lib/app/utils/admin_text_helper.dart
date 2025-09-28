class AdminTextHelper {
  AdminTextHelper._();

  // Login
  static const String loginWelcomeTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to your Whiskr account';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String signInButton = 'Sign In';
  static const String forgotPasswordButton = 'Forgot Password?';
  static const String copyrightFooter = '© 2025 Whiskr. All rights reserved.';

  static const String forgotPasswordComingSoon = 'Forgot password functionality coming soon!';

  static String loginSuccessMessage(String? userName) => 'Welcome back, ${userName ?? 'Admin'}!';

  static const String emailHint = 'Enter your email address';
  static const String passwordHint = 'Enter your password';

  static const String emailFieldAccessibility = 'Email input field';
  static const String passwordFieldAccessibility = 'Password input field';
  static const String showPasswordAccessibility = 'Show password';
  static const String hidePasswordAccessibility = 'Hide password';
  static const String loginButtonAccessibility = 'Sign in to admin panel';
  static const String logoAccessibility = 'Whiskr application logo';

  static const String signingIn = 'Signing in...';
  static const String loading = 'Loading...';
  static const String pleaseWait = 'Please wait...';

  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String retry = 'Retry';
  static const String close = 'Close';
}
