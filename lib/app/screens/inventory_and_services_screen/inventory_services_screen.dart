import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:w_components/buttons/common_button.dart';
import 'package:w_components/text_fields/wa_custom_search_text.dart';
import 'package:w_components/wa_custom_inventory_data_widget/wa_custom_inventory_data_widget.dart';
import 'package:w_components/wa_custom_snackbar/wa_custom_snackbar.dart';
import 'package:w_components/wa_inventory_table/wa_inventory_table.dart';
import 'package:w_dashboard/helpers/stock_status_type.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/models/image_model.dart';
import 'package:w_utils/models/response_model.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:wa_inventory_services_module/models/wa_inventory_stats_model.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_services_provider.dart';
import 'package:whiskr_admin_panel/app/helpers/inventory_services_screen_helper.dart';
import 'package:whiskr_admin_panel/app/screens/inventory_and_services_screen/wa_services_model.dart';
import 'package:whiskr_admin_panel/app/screens/inventory_and_services_screen/wa_services_table.dart';

import 'add_new_inventory_modal.dart';

class InventoryServicesScreen extends StatelessWidget {
  const InventoryServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _BuildBody());
  }
}

class _BuildBody extends StatelessWidget {
  const _BuildBody({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = Responsive.value(context: context, mobile: 24.0, tablet: 16.0, desktop: 24.0, widescreen: 32.0);

    final verticalPadding = Responsive.value(context: context, mobile: 16.0, tablet: 12.0, desktop: 16.0, widescreen: 20.0);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
      child: Column(
        children: [
          _BuildHeader(),
          SizedBox(height: Responsive.value(context: context, mobile: 20.0, tablet: 16.0, desktop: 20.0, widescreen: 24.0)),
          // _BuildInventoryTable(),
          // todo when BE is ready
          // _BuildServicesTable(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _BuildHeader extends StatelessWidget {
  const _BuildHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleSize = Responsive.value(context: context, mobile: 24.0, tablet: 22.0, desktop: 24.0, widescreen: 28.0);
    final isTablet = Responsive.isTablet(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Inventory', style: theme.textTheme.headlineMedium!.copyWith(fontSize: titleSize)),
        SizedBox(height: Responsive.value(context: context, mobile: 25.0, tablet: 20.0, desktop: 25.0, widescreen: 30.0)),
        Card(
          color: ColorHelper.white.color,
          child: SizedBox(
            height: Responsive.value(context: context, mobile: 320.0, tablet: 370.0, desktop: 330.0, widescreen: 370.0),
            child: isTablet ? _buildTabletLayout(context) : _buildDesktopLayout(context),
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: _BuildAddInventoryOrServiceButton()),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: WASearchTextField(
                    onChanged: (String value) {
                      _handleSearch(value, context);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer(
              builder: (BuildContext context, WAInventoryServicesProvider provider, Widget? child) {
                return InventorySummaryWidget(
                  stats: InventoryStats(total: provider.productsValueList.length, lowStock: provider.lowStockProducts.length, outOfStock: provider.outOfStockProducts.length),
                  onTotalTap: () => provider.clearStatusFilter(),
                  onLowStockTap: () => provider.setStatusFilter(LowStockProductStatus.lowStock),
                  onOutOfStockTap: () => provider.setStatusFilter(LowStockProductStatus.outOfStock),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final summaryWidth = Responsive.value(context: context, mobile: 800.0, tablet: 600.0, desktop: 800.0, widescreen: 900.0);
    final controlsWidth = Responsive.value(context: context, mobile: 500.0, tablet: 400.0, desktop: 400.0, widescreen: 550.0);
    final spacing = Responsive.value(context: context, mobile: 50.0, tablet: 30.0, desktop: 50.0, widescreen: 60.0);

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            width: summaryWidth,
            child: Consumer(
              builder: (BuildContext context, WAInventoryServicesProvider provider, Widget? child) {
                return InventorySummaryWidget(
                  stats: InventoryStats(total: provider.productsValueList.length, lowStock: provider.lowStockProducts.length, outOfStock: provider.outOfStockProducts.length),
                  onTotalTap: () => provider.clearStatusFilter(),
                  onLowStockTap: () => provider.setStatusFilter(LowStockProductStatus.lowStock),
                  onOutOfStockTap: () => provider.setStatusFilter(LowStockProductStatus.outOfStock),
                );
              },
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: Responsive.value(context: context, mobile: 20.0, tablet: 16.0, desktop: 20.0, widescreen: 24.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _BuildAddInventoryOrServiceButton(),
                SizedBox(
                  width: controlsWidth,
                  child: WASearchTextField(
                    onChanged: (String value) {
                      _handleSearch(value, context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static void _handleSearch(String value, BuildContext context) {
    context.read<WAInventoryServicesProvider>().updateSearchQuery(value);
  }
}

class _BuildAddInventoryOrServiceButton extends StatelessWidget {
  const _BuildAddInventoryOrServiceButton({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonHeight = Responsive.value(context: context, mobile: 45.0, tablet: 45.0, desktop: 45.0, widescreen: 48.0);
    final isTablet = Responsive.isTablet(context);

    return SizedBox(
      width: isTablet ? null : Responsive.value(context: context, mobile: 500.0, tablet: null, desktop: 500.0, widescreen: 550.0),
      height: buttonHeight,
      child: CommonButton(
        onPressed: () => AddInventoryModal.show(
          context,
          onSave: () {
            final ResponseModel response = context.read<WAInventoryServicesProvider>().addProduct();
            if (response.isSuccess) {
              WACustomSnackbar.instance.showSnack(context, 'Successfully added new item to your inventory');
              context.read<WAInventoryServicesProvider>().resetControllers();
            }
            context.pop();
          },
        ),
        buttonTitle: '+ Add Inventory',
        buttonType: PPButtonType.web,
        showBorder: false,
      ),
    );
  }
}

class _BuildInventoryTable extends StatelessWidget {
  _BuildInventoryTable();
  final InventoryServicesHelper helper = InventoryServicesHelper();

  @override
  Widget build(BuildContext context) {
    final tableHeight = Responsive.value(context: context, mobile: 640.0, tablet: 500.0, desktop: 640.0, widescreen: 720.0);

    return WAInventoryTable(
      orders: context.watch<WAInventoryServicesProvider>().products,
      height: tableHeight,
      onDelete: (String id, String inventoryName) {
        helper.showDeleteDialog(context, id, inventoryName);
      },
      onEdit: (String id) {
        debugPrint("edit FROM ABOVE");
      },
    );
  }
}

class _BuildServicesTable extends StatelessWidget {
  _BuildServicesTable();
  final InventoryServicesHelper helper = InventoryServicesHelper();

  @override
  Widget build(BuildContext context) {
    final tableHeight = Responsive.value(context: context, mobile: 640.0, tablet: 500.0, desktop: 640.0, widescreen: 720.0);

    return WaServicesTable(
      services: _localServices,
      height: tableHeight,
      onDelete: (String id, String serviceName) {
        // helper.showDeleteDialog(context, id, serviceName);
      },
      onEdit: (String id) {
        debugPrint("edit FROM ABOVE");
      },
    );
  }
}

final List<WAServiceModel> _localServices = [
  WAServiceModel(
    id: '1',
    name: 'Basic Bath & Brush',
    description: 'Includes bath, blow dry, brushing, and light trimming. Perfect for quick clean-ups.',
    category: 'Grooming',
    image: ImageModel(url: 'https://example.com/images/bath_brush.jpg', thumbnail: 'https://example.com/thumbs/bath_brush.jpg'),
    price: 25.0,
    currency: 'BAM',
    active: true,
  ),
  WAServiceModel(
    id: '2',
    name: 'Full Grooming Package',
    description: 'Complete grooming with bath, haircut, nail trim, ear cleaning, and paw care.',
    category: 'Grooming',
    image: ImageModel(url: 'https://example.com/images/full_grooming.jpg', thumbnail: 'https://example.com/thumbs/full_grooming.jpg'),
    price: 45.0,
    currency: 'BAM',
    active: true,
  ),
  WAServiceModel(
    id: '3',
    name: 'Puppy Intro Grooming',
    description: 'Gentle introduction to grooming for puppies. Includes light wash, brushing, and nail trimming.',
    category: 'Grooming',
    image: ImageModel(url: 'https://example.com/images/puppy_groom.jpg', thumbnail: 'https://example.com/thumbs/puppy_groom.jpg'),
    price: 20.0,
    currency: 'BAM',
    active: true,
  ),
  WAServiceModel(
    id: '4',
    name: 'De-Shedding Treatment',
    description: 'Reduces shedding with deep conditioning, brushing, and blowout using special tools.',
    category: 'Grooming',
    image: ImageModel(url: 'https://example.com/images/deshedding.jpg', thumbnail: 'https://example.com/thumbs/deshedding.jpg'),
    price: 35.0,
    currency: 'BAM',
    active: true,
  ),
  WAServiceModel(
    id: '5',
    name: 'Nail Clipping & Paw Care',
    description: 'Quick nail trim, paw pad cleaning, and moisturizing treatment.',
    category: 'Grooming',
    image: ImageModel(url: 'https://example.com/images/nail_care.jpg', thumbnail: 'https://example.com/thumbs/nail_care.jpg'),
    price: 15.0,
    currency: 'BAM',
    active: true,
  ),
  WAServiceModel(
    id: '6',
    name: 'Ear Cleaning & Hygiene',
    description: 'Safe and gentle ear cleaning to remove dirt and reduce odor or infection risk.',
    category: 'Grooming',
    image: ImageModel(url: 'https://example.com/images/ear_clean.jpg', thumbnail: 'https://example.com/thumbs/ear_clean.jpg'),
    price: 10.0,
    currency: 'BAM',
    active: true,
  ),
  WAServiceModel(
    id: '7',
    name: 'Teeth Brushing & Breath Freshener',
    description: 'Brushing with pet-safe toothpaste and finishing spray for fresh breath.',
    category: 'Grooming',
    image: ImageModel(url: 'https://example.com/images/teeth_clean.jpg', thumbnail: 'https://example.com/thumbs/teeth_clean.jpg'),
    price: 12.0,
    currency: 'BAM',
    active: true,
  ),
  WAServiceModel(
    id: '8',
    name: 'Spa & Aromatherapy Bath',
    description: 'Relaxing spa bath with natural oils and aromatherapy massage for pets.',
    category: 'Grooming',
    image: ImageModel(url: 'https://example.com/images/spa_bath.jpg', thumbnail: 'https://example.com/thumbs/spa_bath.jpg'),
    price: 50.0,
    currency: 'BAM',
    active: true,
  ),
];
