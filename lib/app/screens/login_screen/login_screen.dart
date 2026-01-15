import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_authentication/providers/authentication_provider.dart';
import 'package:whiskr_admin_panel/app/helpers/utils/login_utils/login_action_utils.dart';

import '../../providers/texts_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthenticationProvider>().resetControllers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const _LoginHeader(), const SizedBox(height: 48), _LoginForm(), const SizedBox(height: 32), _LoginFooter()]),
          ),
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final texts = TextsProvider.of(context)!.loginTexts;
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: <BoxShadow>[
              BoxShadow(color: themeData.shadowColor.withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Image.asset('assets/images/appicon.png'),
        ),
        const SizedBox(height: 24),
        Text(texts.welcomeTitle, style: themeData.textTheme.displayLarge),
        const SizedBox(height: 8),
        Text(texts.subtitle, style: themeData.textTheme.bodyMedium),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: context.read<AuthenticationProvider>().formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_LoginEmailField(), const SizedBox(height: 24), _LoginPasswordField(), const SizedBox(height: 32), _LoginButton(), const SizedBox(height: 24), _LoginForgotPasswordButton()],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginEmailField extends StatelessWidget {
  const _LoginEmailField();

  @override
  Widget build(BuildContext context) {
    final texts = TextsProvider.of(context)!.loginTexts;
    return TextFormField(
      controller: context.read<AuthenticationProvider>().loginEmailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(labelText: texts.emailLabel, prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
    );
  }
}

class _LoginPasswordField extends StatelessWidget {
  const _LoginPasswordField();

  @override
  Widget build(BuildContext context) {
    final texts = TextsProvider.of(context)!.loginTexts;
    return TextFormField(
      controller: context.read<AuthenticationProvider>().loginPasswordController,
      obscureText: context.select<AuthenticationProvider, bool>((authProvider) => authProvider.obscurePassword),
      decoration: InputDecoration(
        labelText: texts.passwordLabel,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(context.select<AuthenticationProvider, IconData>((authProvider) => authProvider.obscurePassword ? Icons.visibility : Icons.visibility_off)),
          onPressed: context.read<AuthenticationProvider>().togglePasswordVisibility,
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final texts = TextsProvider.of(context)!.loginTexts;

    return ElevatedButton(
      onPressed: () => LoginActionUtils.onSignIn(context),
      child: context.select<AuthenticationProvider, bool>((authProvider) => authProvider.isLoading)
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
              ),
            )
          : Text(texts.signInButton, style: themeData.textTheme.bodyMedium!.copyWith(color: colorScheme.onPrimary)),
    );
  }
}

class _LoginForgotPasswordButton extends StatelessWidget {
  const _LoginForgotPasswordButton();

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final ColorScheme colorScheme = themeData.colorScheme;
    final texts = TextsProvider.of(context)!.loginTexts;
    return TextButton(
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texts.forgotPasswordComingSoon))),
      child: Text(texts.forgotPasswordButton, style: themeData.textTheme.bodyMedium!.copyWith(color: colorScheme.primary)),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    final texts = TextsProvider.of(context)!.loginTexts;
    return Text(texts.copyrightFooter);
  }
}
