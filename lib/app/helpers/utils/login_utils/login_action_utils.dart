import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_authentication/providers/authentication_provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/models/response_model.dart';

import '../../../../routing/routes.dart';

class LoginActionUtils {
  LoginActionUtils._();

  static void onSignIn(BuildContext context) async {
    final AuthenticationProvider provider = context.read<AuthenticationProvider>();
    provider.setLoading(true);
    final ResponseModel response = await provider.loginUser();
    final bool isFinishedOnboarding = provider.userModel.finishedOnboarding ?? false;

    if (!context.mounted) return;
    provider.setLoading(false);
    if (response.isSuccess) {
      if (isFinishedOnboarding) {
        context.go(dashboardRoute);
      } else {
        context.go(onboardingGeneralInfoRoute);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error ?? ''), backgroundColor: ColorHelper.red500.color));
    }
  }
}
