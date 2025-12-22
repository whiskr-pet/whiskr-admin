import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_components/wa_custom_snackbar/wa_custom_snackbar.dart';
import 'package:w_image_module/helpers/image_constants.dart';
import 'package:w_image_module/providers/image_provider.dart';
import 'package:w_utils/models/form_data_file_bytes.dart';
import 'package:w_utils/models/image_model.dart';
import 'package:w_utils/models/response_model.dart';
import 'package:wa_inventory_services_module/models/wa_inventory_product_model.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_search_provider.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_services_provider.dart';

import '../../../../localization_models/inventory_text/inventory_text.dart';
import '../../../providers/texts_provider.dart';
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
    // this will enable add modal
    provider.clearEditMode();
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

  static void handleSearch(String value, BuildContext context) {
    final inventoryProvider = context.read<WAInventoryServicesProvider>();
    final searchProvider = context.read<WAInventorySearchProvider>();

    if (value.isEmpty) {
      inventoryProvider.setSearchMode(false);
    } else {
      inventoryProvider.setSearchMode(true);
      searchProvider.updateQuery(value);
    }
  }

  // Add / Edit Inventory modal
  static VoidCallback pickInventoryImage(BuildContext context) {
    return () async {
      final InventoryTexts texts = TextsProvider.of(context)!.inventoryTexts;
      final imageProvider = context.read<ImageHandleProvider>();
      final ResponseModel<FormDataFileBytes?> response = await imageProvider.pickImageForWeb();
      if (!response.isSuccess && context.mounted) {
        WACustomSnackbar.instance.showSnack(context, response.error ?? texts.inventoryErrorPickingImage, type: WACustomSnackbarType.error);
      } else if (response.isSuccess && response.data != null) {
        final ResponseModel<ImageModel> responseModel = await imageProvider.uploadWebSingleImage(ProviderImageConstants.productInventoryImages);
        if (!responseModel.isSuccess && context.mounted) {
          WACustomSnackbar.instance.showSnack(context, responseModel.error ?? texts.inventoryErrorUploadingImage, type: WACustomSnackbarType.error);
        } else {
          if (context.mounted) {
            context.read<WAInventoryServicesProvider>().setImage(responseModel.data!);
          }
        }
      }
    };
  }

  static VoidCallback handleSave(Function? onSave, BuildContext context) {
    return () async {
      if (context.read<WAInventoryServicesProvider>().formKey.currentState!.validate()) {
        context.read<WAInventoryServicesProvider>().setIsUploading(true);
        try {
          if (onSave != null) {
            onSave();
          }
        } catch (e) {
          WACustomSnackbar.instance.showSnack(context, 'Error: $e', type: WACustomSnackbarType.error);
        } finally {
          context.read<WAInventoryServicesProvider>().setIsUploading(false);
        }
      }
    };
  }

  static VoidCallback handleCancel(AnimationController animationController, BuildContext context) {
    return () async {
      animationController.reverse().then((_) => Navigator.of(context).pop());
    };
  }
}
