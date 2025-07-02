import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';

class LowStockProductsWidget extends StatelessWidget {
  final void Function()? onViewAll;
  final void Function(Product)? onProductTap;
  const LowStockProductsWidget({super.key, this.onViewAll, this.onProductTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final lowStockProducts = productProvider.lowStockProducts.take(5).toList();

        if (lowStockProducts.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'All products are well stocked',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600], fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Low Stock Products',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                    ),
                    TextButton(onPressed: onViewAll, child: const Text('View All')),
                  ],
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lowStockProducts.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final product = lowStockProducts[index];
                  return _buildProductItem(context, product);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductItem(BuildContext context, Product product) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
        child: product.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported, color: Colors.grey);
                  },
                ),
              )
            : const Icon(Icons.image_not_supported, color: Colors.grey),
      ),
      title: Text(
        product.name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.category,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'Poppins'),
          ),
          Text(
            'Stock: ${product.stockQuantity} units',
            style: TextStyle(fontSize: 12, color: product.isOutOfStock ? AppTheme.errorColor : AppTheme.warningColor, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins'),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: product.isOutOfStock ? AppTheme.errorColor.withOpacity(0.1) : AppTheme.warningColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(
              product.isOutOfStock ? 'OUT OF STOCK' : 'LOW STOCK',
              style: TextStyle(color: product.isOutOfStock ? AppTheme.errorColor : AppTheme.warningColor, fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
      onTap: () => onProductTap?.call(product),
    );
  }
}
