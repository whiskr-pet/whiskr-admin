import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:w_components/wa_custom_snackbar/wa_custom_snackbar.dart';
import 'package:w_utils/models/response_model.dart';
import 'package:wa_inventory_services_module/models/wa_inventory_product_model.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_services_provider.dart';

import '../../../screens/inventory_and_services_screen/add_new_inventory_modal.dart';

class InventoryActionUtils {
  InventoryActionUtils._();

  static Future<void> onEditInventory(WAProduct product, WAInventoryServicesProvider provider, BuildContext context) async {
    provider.initializeEditMode(product);
    AddInventoryModal.show(
      context,
      isEditMode: true,
      onSave: () async {
        provider.setLoading(true);
        final ResponseModel<String> response = await provider.updateInventoryProduct();
        if (response.isSuccess) {
          if (context.mounted) {
            WACustomSnackbar.instance.showSnack(context, 'Successfully updated inventory item');
            provider.clearEditMode();
          }
        } else {
          debugPrint('Error updating inventory item: ${response.error}');
          if (context.mounted) {
            WACustomSnackbar.instance.showSnack(context, 'Error updating inventory item: ${response.error}', type: WACustomSnackbarType.error);
          }
        }
        provider.setLoading(false);
        if (context.mounted) context.pop();
      },
    );
  }

  static Future<void> onAddInventoryItem(WAInventoryServicesProvider provider, BuildContext context) async {
    AddInventoryModal.show(
      context,
      onSave: () async {
        final ResponseModel<String> response = await provider.createInventoryProduct();
        if (response.isSuccess) {
          if (context.mounted) {
            WACustomSnackbar.instance.showSnack(context, 'Successfully added new item to your inventory');
            provider.resetControllers();
          }
        } else {
          debugPrint('Error adding new inventory item: ${response.error}');
          if (context.mounted) {
            WACustomSnackbar.instance.showSnack(context, 'Error adding new inventory item: ${response.error}', type: WACustomSnackbarType.error);
          }
        }
        if (context.mounted) context.pop();
      },
    );
  }

  static Future<void> onDeleteInventoryItem(BuildContext context, WAInventoryServicesProvider provider, String productID, String productName) async {
    context.pop();
    provider.setLoading(true);
    final ResponseModel<String> result = await provider.deleteInventoryProduct(productID: productID);
    if (result.isSuccess) {
      if (context.mounted) {
        WACustomSnackbar.instance.showSnack(context, 'Product "$productName" deleted successfully.', type: WACustomSnackbarType.success);
      }
    } else {
      if (context.mounted) {
        WACustomSnackbar.instance.showSnack(context, result.error ?? '');
      }
    }
    provider.setLoading(false);
  }
}
