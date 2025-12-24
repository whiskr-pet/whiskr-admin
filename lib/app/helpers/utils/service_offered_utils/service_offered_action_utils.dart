import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_components/wa_custom_snackbar/wa_custom_snackbar.dart';
import 'package:w_utils/models/response_model.dart';
import 'package:wa_inventory_services_module/providers/wa_services_providers/wa_services_provider.dart';
import 'package:whiskr_admin_panel/app/screens/inventory_and_services_screen/services_offered/add_new_service_offered_modal.dart';

class ServiceOfferedActionUtils {
  ServiceOfferedActionUtils._();

  static Future<void> onAddServiceOffered(WAServicesProvider provider, BuildContext context) async {
    // this will enable add modal
    // provider.clearEditMode();
    AddServiceOfferedModal.show(
      context,
      onSave: () async {
        final ResponseModel<String> response = await provider.createServiceOffer();
        if (response.isSuccess) {
          if (context.mounted) {
            WACustomSnackbar.instance.showSnack(context, 'Successfully added new service offer to your inventory');
            provider.resetControllers();
          }
        } else {
          debugPrint('Error adding new service offer: ${response.error}');
          if (context.mounted) {
            WACustomSnackbar.instance.showSnack(context, 'Error adding new service offer: ${response.error}', type: WACustomSnackbarType.error);
          }
        }
        if (context.mounted) context.pop();
      },
    );
  }

  static VoidCallback handleSave(Function? onSave, BuildContext context) {
    return () async {
      if (context.read<WAServicesProvider>().formKey.currentState!.validate()) {
        context.read<WAServicesProvider>().setIsUploading(true);
        try {
          if (onSave != null) {
            onSave();
          }
        } catch (e) {
          WACustomSnackbar.instance.showSnack(context, 'Error: $e', type: WACustomSnackbarType.error);
        } finally {
          context.read<WAServicesProvider>().setIsUploading(false);
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
