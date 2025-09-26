import 'package:flutter/material.dart';
import 'config/flavor_config.dart';
import 'main_common.dart';

void main() async {
  await initializeApp(flavor: Flavor.PRODUCTION, appName: 'Whiskr Admin (PRODUCTION)', env: 'prod');

  runApp(const WhiskrAdminApp());
}
