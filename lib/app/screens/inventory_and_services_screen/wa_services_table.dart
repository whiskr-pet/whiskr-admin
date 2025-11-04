import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:whiskr_admin_panel/app/screens/inventory_and_services_screen/wa_services_model.dart';

class WaServicesTable extends StatelessWidget {
  const WaServicesTable({super.key, required this.services, this.height = 430, this.onDelete, this.onEdit});

  final double height;
  final List<WAServiceModel> services;
  final Function(String, String)? onDelete;
  final Function(String)? onEdit;

  @override
  Widget build(BuildContext context) {
    final cardHeight = Responsive.value(context: context, mobile: 400.0, tablet: height + 20.0, desktop: height + 100.0, widescreen: height + 50.0);

    return Container(
      width: double.infinity,
      height: cardHeight,
      decoration: BoxDecoration(
        border: Border.all(color: ColorHelper.grey200.color),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _WATable(columns: columns(context), rows: rows(context, services, onDelete, onEdit)),
          ),
        ],
      ),
    );
  }
}

class _WATable extends StatelessWidget {
  const _WATable({required this.columns, required this.rows});

  final List<DataColumn> columns;
  final List<DataRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final columnSpacing = Responsive.value(context: context, mobile: 12.0, tablet: 24.0, desktop: 32.0, widescreen: 40.0);

    final horizontalMargin = Responsive.value(context: context, mobile: 8.0, tablet: 12.0, desktop: 16.0, widescreen: 20.0);

    final dataRowHeight = Responsive.value(context: context, mobile: 60.0, tablet: 70.0, desktop: 80.0, widescreen: 90.0);

    final minWidth = Responsive.value(context: context, mobile: 500.0, tablet: 600.0, desktop: 800.0, widescreen: 1000.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DataTable2(
        headingTextStyle: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
        headingRowDecoration: BoxDecoration(color: ColorHelper.white.color),
        decoration: BoxDecoration(color: ColorHelper.white.color),
        columnSpacing: columnSpacing,
        horizontalMargin: horizontalMargin,
        minWidth: minWidth,
        dataRowHeight: dataRowHeight,
        scrollController: ScrollController(),
        fixedTopRows: 1,
        columns: columns,
        rows: rows,
        empty: const Center(child: Text('No Services data')),
      ),
    );
  }
}

List<DataColumn> columns(BuildContext context) {
  return [
    DataColumn2(label: Text('Image'), size: ColumnSize.S),
    DataColumn2(label: Text('Service Name'), size: ColumnSize.M),
    DataColumn2(label: Text('Category'), size: ColumnSize.M),
    DataColumn2(label: Text('Price'), size: ColumnSize.S),
    DataColumn2(label: Text('Description'), size: ColumnSize.L),
    DataColumn2(label: Text('Action'), size: ColumnSize.S),
  ];
}

List<DataRow> rows(BuildContext context, List<WAServiceModel> orders, Function? onDelete, Function? onEdit) {
  final theme = Theme.of(context);
  final avatarRadius = Responsive.value(context: context, mobile: 14.0, tablet: 20.0, desktop: 22.0, widescreen: 26.0);

  final nameFontSize = Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 17.0);

  final amountFontSize = Responsive.value(context: context, mobile: 13.0, tablet: 14.0, desktop: 15.0, widescreen: 16.0);

  final dateFontSize = Responsive.value(context: context, mobile: 12.0, tablet: 13.0, desktop: 14.0, widescreen: 15.0);
  return orders
      .map(
        (WAServiceModel product) => DataRow(
          cells: [
            // Image Column
            DataCell(ServicesAvatar(imageUrl: product.image.url ?? '', radius: avatarRadius)),
            DataCell(
              Text(
                product.name,
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500, fontSize: nameFontSize),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            // Category
            DataCell(
              Text(
                product.category,
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500, fontSize: amountFontSize),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            // Price
            DataCell(
              Text(
                '${product.currency} ${product.price}',
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: dateFontSize),
              ),
            ),
            // Description
            DataCell(
              Text(
                product.description,
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: dateFontSize),
              ),
            ),
            // Action
            DataCell(
              _InventoryActions(
                onDelete: () {
                  debugPrint("Delete service with ID: ${product.id}");
                  if (onDelete != null) {
                    onDelete(product.id, product.name);
                  }
                },
                onEdit: () {
                  debugPrint("Edit service with ID: ${product.id}");
                  if (onEdit != null) {
                    onEdit(product.id);
                  }
                },
              ),
            ),
          ],
        ),
      )
      .toList();
}

class _InventoryActions extends StatelessWidget {
  const _InventoryActions({super.key, required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              onTap: onEdit,
              child: Center(child: Icon(Icons.edit_outlined, color: ColorHelper.grey700.color, size: 18)),
            ),
          ),
          Container(width: 1, color: const Color(0xFFE0E0E0)),
          Expanded(
            child: InkWell(
              borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
              onTap: onDelete,
              child: Center(child: Icon(Icons.delete_outline, color: ColorHelper.red500.color, size: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

class ServicesAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;

  const ServicesAvatar({super.key, required this.imageUrl, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: ColorHelper.blue500.color,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: radius * 2,
              height: radius * 2,
              color: ColorHelper.blue500.color,
              child: Center(child: Icon(Icons.shopping_basket_outlined)),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: radius * 2,
              height: radius * 2,
              color: Colors.grey.shade200,
              child: Center(
                child: SizedBox(
                  width: radius,
                  height: radius,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
