import 'package:flutter/material.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ProductCard({super.key, required this.product, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  color: Colors.grey[200],
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.image_not_supported, size: 24, color: Colors.grey));
                          },
                        ),
                      )
                    : const Center(child: Icon(Icons.image_not_supported, size: 24, color: Colors.grey)),
              ),
            ),

            // Product Info
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Category
                    Text(
                      product.category,
                      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontFamily: 'Poppins'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Price and Stock
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ColorHelper.blue500.color, fontFamily: 'Poppins'),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(color: _getStockColor().withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            '${product.stockQuantity}',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _getStockColor(), fontFamily: 'Poppins'),
                          ),
                        ),
                      ],
                    ),

                    // Stock Status
                    if (product.isLowStock || product.isOutOfStock)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(color: _getStatusColor().withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          product.isOutOfStock ? 'OUT' : 'LOW',
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: _getStatusColor(), fontFamily: 'Poppins'),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 28,
                      child: OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text('Edit', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: SizedBox(
                      height: 28,
                      child: OutlinedButton(
                        onPressed: onDelete,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          foregroundColor: ColorHelper.red500.color,
                          side: BorderSide(color: ColorHelper.red500.color),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text('Del', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStockColor() {
    if (product.isOutOfStock) {
      return ColorHelper.red500.color;
    } else if (product.isLowStock) {
      return ColorHelper.yellow500.color;
    } else {
      return ColorHelper.green500.color;
    }
  }

  Color _getStatusColor() {
    if (product.isOutOfStock) {
      return ColorHelper.red500.color;
    } else if (product.isLowStock) {
      return ColorHelper.yellow500.color;
    } else {
      return ColorHelper.green500.color;
    }
  }
}
