import 'package:flutter/material.dart';
import 'config/flavor_config.dart';
import 'main_common.dart';

void main() async {
  await initializeApp(flavor: Flavor.TEST, appName: 'Whiskr Admin (TEST)', env: 'test');

  runApp(const WhiskrAdminApp());
}
