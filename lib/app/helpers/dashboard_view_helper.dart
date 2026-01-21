import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_dashboard/models/dashboard_overview_helper_model/dashboard_overview_helper_model.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_providers/wa_inventory_services_provider.dart';
import 'package:wa_inventory_services_module/providers/wa_services_providers/wa_services_provider.dart';
import 'package:whiskr_admin_panel/app/helpers/utils/inventory_utils/inventory_action_utils.dart';
import 'package:whiskr_admin_panel/app/helpers/utils/service_offered_utils/service_offered_action_utils.dart';
import 'package:whiskr_admin_panel/routing/routes.dart';

class DashboardViewHelper {
  List<DashboardOverviewHelperModel> dashboardOverviewHelperModels(bool isPetShop, BuildContext context) => [
    DashboardOverviewHelperModel(
      icon: Icons.add,
      title: !isPetShop ? 'Add Service' : 'Add Product',
      onPressed: () async {
        isPetShop
            ? await InventoryActionUtils.onAddInventoryItem(context.read<WAInventoryServicesProvider>(), context)
            : await ServiceOfferedActionUtils.onAddServiceOffered(context.read<WAServicesProvider>(), context);
      },
    ),
    DashboardOverviewHelperModel(
      icon: Icons.shopping_cart,
      title: isPetShop ? 'View Orders' : 'View Appointments',
      onPressed: () {
        context.go(ordersRoute);
      },
    ),
    DashboardOverviewHelperModel(icon: Icons.analytics, title: 'Analytics', onPressed: () => context.go(analyticsRoute)),
  ];
}
