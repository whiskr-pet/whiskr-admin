import 'package:flutter/material.dart';
import 'package:w_dashboard/models/dashboard_overview_helper_model/dashboard_overview_helper_model.dart';

class DashboardViewHelper {
  List<DashboardOverviewHelperModel> dashboardOverviewHelperModels(bool isPetShop) => [
    DashboardOverviewHelperModel(icon: Icons.add, title: !isPetShop ? 'Add Service' : 'Add Product', onPressed: () => {debugPrint('add product')}),
    DashboardOverviewHelperModel(icon: Icons.shopping_cart, title: isPetShop ? 'View Orders' : 'View Appointments', onPressed: () => {debugPrint('view orders')}),
    DashboardOverviewHelperModel(icon: Icons.analytics, title: 'Analytics', onPressed: () => {debugPrint('analytics')}),
  ];
}
