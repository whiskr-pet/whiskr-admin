import 'package:flutter/material.dart';
import 'config/flavor_config.dart';
import 'main_common.dart';

void main() async {
  await initializeApp(flavor: Flavor.DEV, appName: 'Whiskr Admin (DEV)', env: 'dev');

  runApp(const WhiskrAdminApp());
}
