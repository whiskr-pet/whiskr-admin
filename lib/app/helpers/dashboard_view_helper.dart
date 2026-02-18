import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_dashboard/models/dashboard_overview_helper_model/dashboard_overview_helper_model.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_providers/wa_inventory_services_provider.dart';
import 'package:wa_inventory_services_module/providers/wa_services_providers/wa_services_provider.dart';
import 'package:whiskr_admin_panel/app/helpers/utils/inventory_utils/inventory_action_utils.dart';
import 'package:whiskr_admin_panel/app/helpers/utils/service_offered_utils/service_offered_action_utils.dart';
import 'package:whiskr_admin_panel/routing/routes.dart';

// Suggestion 3: Use an enum for better type safety and scalability.
enum DashboardType { petShop, serviceProvider }

class DashboardViewHelper {
  // Private constructor to prevent instantiation, as this is a utility class.
  DashboardViewHelper._();

  // Suggestion 1: Make the method static.
  // Suggestion 3: Use the DashboardType enum instead of a boolean.
  static List<DashboardOverviewHelperModel> getDashboardOverviewModels(
      DashboardType type, BuildContext context) {
    return [
      DashboardOverviewHelperModel(
        icon: Icons.add,
        title: type == DashboardType.petShop ? 'Add Product' : 'Add Service',
        onPressed: () => _onAddItem(type, context),
      ),
      DashboardOverviewHelperModel(
        icon: Icons.shopping_cart,
        title: type == DashboardType.petShop ? 'View Orders' : 'View Appointments',
        onPressed: () => context.go(ordersRoute),
      ),
      DashboardOverviewHelperModel(
        icon: Icons.analytics,
        title: 'Analytics',
        onPressed: () => context.go(analyticsRoute),
      ),
    ];
  }

  // Suggestion 2: Extract complex logic into a private helper method.
  static Future<void> _onAddItem(DashboardType type, BuildContext context) async {
    switch (type) {
      case DashboardType.petShop:
        // context.read is appropriate here as it's a one-time action.
        await InventoryActionUtils.onAddInventoryItem(
            context.read<WAInventoryServicesProvider>(), context);
        break;
      case DashboardType.serviceProvider:
        await ServiceOfferedActionUtils.onAddServiceOffered(
            context.read<WAServicesProvider>(), context);
        break;
    }
  }
}