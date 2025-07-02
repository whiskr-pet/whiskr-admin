import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';
import '../widgets/product_card.dart';
import '../widgets/add_edit_product_dialog.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  bool _showLowStockOnly = false;
  bool _showOutOfStockOnly = false;
  bool _showActiveOnly = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilterDialog),
          IconButton(icon: const Icon(Icons.sort), onPressed: _showSortDialog),
        ],
      ),
      body: Column(
        children: [
          // Demo Mode Indicator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Demo Mode: Click on any product to edit or use quick actions', style: TextStyle(fontSize: 12, color: AppTheme.primaryColor)),
                ),
                ElevatedButton.icon(
                  onPressed: _createDemoProduct,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Demo', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                ),
              ],
            ),
          ),

          // Search and Add Product Section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) {
                      Provider.of<ProductProvider>(context, listen: false).setSearchQuery(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _showAddProductDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                ),
              ],
            ),
          ),

          // Quick Stats
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    _buildQuickStat('Total', productProvider.products.length.toString(), AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    _buildQuickStat('Low Stock', productProvider.lowStockProducts.length.toString(), AppTheme.warningColor),
                    const SizedBox(width: 12),
                    _buildQuickStat('Out of Stock', productProvider.outOfStockProducts.length.toString(), AppTheme.errorColor),
                  ],
                ),
              );
            },
          ),

          // Category Filter
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              if (productProvider.categories.length <= 1) return const SizedBox.shrink();

              return Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productProvider.categories.length,
                  itemBuilder: (context, index) {
                    final category = productProvider.categories[index];
                    final isSelected = category == productProvider.selectedCategory;

                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(category, style: TextStyle(fontSize: 11)),
                        selected: isSelected,
                        onSelected: (selected) {
                          productProvider.setSelectedCategory(category);
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Products List
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (productProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'Error loading products',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600], fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          productProvider.error!,
                          style: TextStyle(color: Colors.grey[500], fontFamily: 'Poppins'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: () => productProvider.loadProducts(), child: const Text('Retry')),
                      ],
                    ),
                  );
                }

                final products = _getFilteredProducts(productProvider);

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          productProvider.searchQuery.isNotEmpty ? 'No products found' : 'No products yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600], fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          productProvider.searchQuery.isNotEmpty ? 'Try adjusting your search terms' : 'Add your first product to get started',
                          style: TextStyle(color: Colors.grey[500], fontFamily: 'Poppins'),
                        ),
                        if (productProvider.searchQuery.isEmpty) ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(onPressed: _showAddProductDialog, icon: const Icon(Icons.add), label: const Text('Add Product')),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => productProvider.loadProducts(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, childAspectRatio: 0.85, crossAxisSpacing: 18, mainAxisSpacing: 28),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(product: product, onTap: () => _showEditProductDialog(product), onDelete: () => _showDeleteConfirmation(product));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color, fontFamily: 'Poppins'),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color.withOpacity(0.8), fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }

  List<Product> _getFilteredProducts(ProductProvider productProvider) {
    List<Product> products = productProvider.filteredProducts;

    if (_showLowStockOnly) {
      products = products.where((product) => product.isLowStock).toList();
    }

    if (_showOutOfStockOnly) {
      products = products.where((product) => product.isOutOfStock).toList();
    }

    if (_showActiveOnly) {
      products = products.where((product) => product.isActive).toList();
    }

    return products;
  }

  void _showAddProductDialog() {
    showDialog(context: context, builder: (context) => const AddEditProductDialog());
  }

  void _showEditProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AddEditProductDialog(product: product),
    );
  }

  void _showDeleteConfirmation(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await Provider.of<ProductProvider>(context, listen: false).deleteProduct(product.id);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product deleted successfully'), backgroundColor: AppTheme.successColor));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Products'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text('Show only low stock'),
                  value: _showLowStockOnly,
                  onChanged: (value) {
                    setState(() {
                      _showLowStockOnly = value ?? false;
                      if (_showLowStockOnly) {
                        _showOutOfStockOnly = false;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Show only out of stock'),
                  value: _showOutOfStockOnly,
                  onChanged: (value) {
                    setState(() {
                      _showOutOfStockOnly = value ?? false;
                      if (_showOutOfStockOnly) {
                        _showLowStockOnly = false;
                      }
                    });
                  },
                ),
                CheckboxListTile(
                  title: const Text('Show only active products'),
                  value: _showActiveOnly,
                  onChanged: (value) {
                    setState(() {
                      _showActiveOnly = value ?? true;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {}); // Refresh the UI
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Products'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Name (A-Z)'),
              onTap: () {
                Navigator.of(context).pop();
                _sortProducts('name_asc');
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Name (Z-A)'),
              onTap: () {
                Navigator.of(context).pop();
                _sortProducts('name_desc');
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Price (Low to High)'),
              onTap: () {
                Navigator.of(context).pop();
                _sortProducts('price_asc');
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Price (High to Low)'),
              onTap: () {
                Navigator.of(context).pop();
                _sortProducts('price_desc');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Stock (Low to High)'),
              onTap: () {
                Navigator.of(context).pop();
                _sortProducts('stock_asc');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sortProducts(String sortType) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    // TODO: Implement sorting in ProductProvider
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sorting by $sortType'), backgroundColor: AppTheme.infoColor));
  }

  void _createDemoProduct() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final success = await productProvider.createDemoProduct();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Demo product created successfully!'), backgroundColor: AppTheme.successColor));
    }
  }
}
