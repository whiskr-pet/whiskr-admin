import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:w_components/wa_custom_chip_widget/wa_chip_widget.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/models/image_model.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';

// todo move to models
class WAProduct {
  final String id;
  final String name;
  final String description;
  final String brandName;
  final String category;
  final List<String> tags;
  final ImageModel image;
  final int stockQuantity;
  final double price;
  final String currency;
  final String status;
  final bool active;

  WAProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.brandName,
    required this.category,
    required this.tags,
    required this.image,
    required this.stockQuantity,
    required this.price,
    required this.currency,
    required this.active,
    required this.status,
  });

  factory WAProduct.fromJson(Map<String, dynamic> json) {
    return WAProduct(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      brandName: json['brandName'] ?? '',
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      image: ImageModel.fromJson(json['image'] ?? {}),
      stockQuantity: json['stockQuantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
      'description': description,
      'brandName': brandName,
      'category': category,
      'tags': tags,
      'image': image.toJson(),
      'stockQuantity': stockQuantity,
      'price': price,
      'currency': currency,
      'active': active,
    };
  }
}

class WAInventoryTable extends StatelessWidget {
  const WAInventoryTable({super.key, required this.orders, this.height = 430, this.onDelete, this.onEdit});

  final double height;
  final List<WAProduct> orders;
  final Function? onDelete;
  final Function? onEdit;

  @override
  Widget build(BuildContext context) {
    final cardHeight = Responsive.value(context: context, mobile: 400.0, tablet: height + 20.0, desktop: height + 100.0, widescreen: height + 150.0);

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
            child: _WATable(columns: columns(context), rows: rows(context, orders, onDelete, onEdit)),
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
        empty: const Center(child: Text('No Inventory data')),
      ),
    );
  }
}

List<DataColumn> columns(BuildContext context) {
  final fixedWidth = Responsive.value(context: context, mobile: 0.0, tablet: 250.0, desktop: 350.0, widescreen: 400.0);

  return [
    DataColumn2(label: Text('Image'), size: ColumnSize.S),
    DataColumn2(label: Text('Product Name'), size: ColumnSize.M),
    DataColumn2(label: Text('Category'), size: ColumnSize.M),
    DataColumn2(label: Text('Price'), size: ColumnSize.S),
    DataColumn2(label: Text('Stock Quantity'), size: ColumnSize.S),
    DataColumn2(label: Text('Status'), size: ColumnSize.S),
    DataColumn2(label: Text('Action'), size: ColumnSize.S),
  ];
}

List<DataRow> rows(BuildContext context, List<WAProduct> orders, Function? onDelete, Function? onEdit) {
  final theme = Theme.of(context);
  final avatarRadius = Responsive.value(context: context, mobile: 14.0, tablet: 20.0, desktop: 22.0, widescreen: 26.0);

  final avatarSpacing = Responsive.value(context: context, mobile: 6.0, tablet: 8.0, desktop: 10.0, widescreen: 12.0);

  final nameFontSize = Responsive.value(context: context, mobile: 14.0, tablet: 15.0, desktop: 16.0, widescreen: 17.0);

  final amountFontSize = Responsive.value(context: context, mobile: 13.0, tablet: 14.0, desktop: 15.0, widescreen: 16.0);

  final dateFontSize = Responsive.value(context: context, mobile: 12.0, tablet: 13.0, desktop: 14.0, widescreen: 15.0);
  return orders
      .map(
        (WAProduct product) => DataRow(
          cells: [
            // Image Column
            DataCell(ProductAvatar(imageUrl: product.image.url ?? '', radius: avatarRadius)),
            // Product Name
            DataCell(
              Flexible(
                child: Text(
                  product.name,
                  style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500, fontSize: nameFontSize),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Category
            DataCell(
              Text(
                product.category,
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w500, fontSize: amountFontSize),
              ),
            ),
            // Price
            DataCell(
              Text(
                '${product.currency} ${product.price}',
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: dateFontSize),
              ),
            ),
            // Stock Quantity
            DataCell(
              Text(
                '${product.stockQuantity}',
                style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, fontSize: dateFontSize),
              ),
            ),
            // Status
            DataCell(StatusChip.stockStatus(product.status)),
            // Action
            DataCell(
              _InventoryActions(
                onDelete: () {
                  debugPrint("Delete product with ID: ${product.id}");
                  if (onDelete != null) {
                    onDelete();
                  }
                },
                onEdit: () {
                  debugPrint("Edit product with ID: ${product.id}");
                  if (onEdit != null) {
                    onEdit();
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

class ProductAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;

  const ProductAvatar({super.key, required this.imageUrl, this.radius = 16});

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
