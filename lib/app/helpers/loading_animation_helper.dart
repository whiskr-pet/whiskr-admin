import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:whiskr_admin_panel/app/helpers/lottie_asset_links.dart';

class LoadingAnimationHelper {
  LoadingAnimationHelper._internal();

  static final LoadingAnimationHelper instance = LoadingAnimationHelper._internal();

  Widget loadingAnimation() {
    return Center(child: Lottie.asset(LottieAssetLinks.whiskrLoader, height: 150, width: 150, repeat: true));
  }

  static Widget get loading => instance.loadingAnimation();
}
