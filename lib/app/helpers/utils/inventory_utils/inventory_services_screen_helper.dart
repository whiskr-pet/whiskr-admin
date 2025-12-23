import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/buttons/common_button.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_providers/wa_inventory_services_provider.dart';
import 'package:whiskr_admin_panel/app/helpers/utils/inventory_utils/inventory_action_utils.dart';

class InventoryServicesHelper {
  Future<void> showDeleteDialog(BuildContext context, String productID, String productName) async {
    final theme = Theme.of(context);
    final WAInventoryServicesProvider provider = context.read<WAInventoryServicesProvider>();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: ListenableProvider<WAInventoryServicesProvider>.value(
            value: provider,
            child: Container(
              width: 400,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: ColorHelper.blue300.color.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: Icon(Icons.logout_rounded, color: ColorHelper.blue300.color, size: 34),
                  ),
                  const SizedBox(height: 20),

                  Text('Delete?', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),

                  Text(
                    'Are you sure you want to delete $productName?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 28),

                  Row(
                    children: [
                      Expanded(
                        child: CommonButton(
                          onPressed: () => Navigator.pop(context),
                          buttonTitle: 'Cancel',
                          showBorder: false,
                          buttonType: PPButtonType.web,
                          btnTitleStyle: theme.textTheme.bodyMedium,
                          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(ColorHelper.white.color)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CommonButton(
                          onPressed: () async => await InventoryActionUtils.onDeleteInventoryItem(context, provider, productID, productName),
                          buttonTitle: 'Delete',
                          buttonType: PPButtonType.web,
                          style: ButtonStyle(backgroundColor: WidgetStatePropertyAll<Color>(ColorHelper.red500.color)),
                          showBorder: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
