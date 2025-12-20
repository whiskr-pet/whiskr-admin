import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_search_provider.dart';

class InventoryFiltersWidget extends StatefulWidget {
  const InventoryFiltersWidget({super.key});

  @override
  State<InventoryFiltersWidget> createState() => _InventoryFiltersWidgetState();
}

class _InventoryFiltersWidgetState extends State<InventoryFiltersWidget> with SingleTickerProviderStateMixin {
  String? _selectedStatus;
  bool _showAdvancedFilters = false;

  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _minStockController = TextEditingController();
  final TextEditingController _maxStockController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _expandAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _minPriceController.clear();
      _maxPriceController.clear();
      _minStockController.clear();
      _maxStockController.clear();
    });

    final WAInventorySearchProvider provider = context.read<WAInventorySearchProvider>();
    provider.removeCustomFilter('status');
    provider.removeCustomFilter('minPrice');
    provider.removeCustomFilter('maxPrice');
    provider.removeCustomFilter('minStock');
    provider.removeCustomFilter('maxStock');
  }

  void _applyFilters() async {
    final WAInventorySearchProvider provider = context.read<WAInventorySearchProvider>();

    if (_selectedStatus != null) {
      await provider.searchByStatus(_selectedStatus!);
    }

    final double? minPrice = _minPriceController.text.isNotEmpty ? double.tryParse(_minPriceController.text) : null;
    final double? maxPrice = _maxPriceController.text.isNotEmpty ? double.tryParse(_maxPriceController.text) : null;

    if (minPrice != null || maxPrice != null) {
      await provider.searchByPriceRange(minPrice, maxPrice);
    }

    final int? minStock = _minStockController.text.isNotEmpty ? int.tryParse(_minStockController.text) : null;
    final int? maxStock = _maxStockController.text.isNotEmpty ? int.tryParse(_maxStockController.text) : null;

    if (minStock != null || maxStock != null) {
      await provider.searchByStockRange(minStock, maxStock);
    }
  }

  void _toggleAdvancedFilters() {
    setState(() {
      _showAdvancedFilters = !_showAdvancedFilters;
    });
    if (_showAdvancedFilters) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters =
        _selectedStatus != null ||
        _minPriceController.text.isNotEmpty ||
        _maxPriceController.text.isNotEmpty ||
        _minStockController.text.isNotEmpty ||
        _maxStockController.text.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(Responsive.value(context: context, mobile: 12.0, tablet: 16.0, desktop: 16.0, widescreen: 20.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorHelper.greenWeb.color.withValues(alpha: 0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Icon(Icons.filter_list_rounded, size: 20, color: ColorHelper.greenWeb.color),
              const SizedBox(width: 8),
              Text(
                'Filters',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
              ),
              const Spacer(),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: Icon(Icons.clear_rounded, size: 16, color: Colors.red[400]),
                  label: Text(
                    'Clear All',
                    style: TextStyle(color: Colors.red[400], fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Filter Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'In Stock',
                isSelected: _selectedStatus == 'inStock',
                onSelected: (bool selected) {
                  setState(() {
                    _selectedStatus = selected ? 'inStock' : null;
                  });
                  if (selected) {
                    context.read<WAInventorySearchProvider>().searchByStatus('inStock');
                  } else {
                    context.read<WAInventorySearchProvider>().removeCustomFilter('status');
                  }
                },
                icon: Icons.check_circle_outline,
              ),
              _FilterChip(
                label: 'Low Stock',
                isSelected: _selectedStatus == 'lowStock',
                onSelected: (bool selected) {
                  setState(() {
                    _selectedStatus = selected ? 'lowStock' : null;
                  });
                  if (selected) {
                    context.read<WAInventorySearchProvider>().searchByStatus('lowStock');
                  } else {
                    context.read<WAInventorySearchProvider>().removeCustomFilter('status');
                  }
                },
                icon: Icons.warning_amber_rounded,
              ),
              _FilterChip(
                label: 'Out of Stock',
                isSelected: _selectedStatus == 'outOfStock',
                onSelected: (bool selected) {
                  setState(() {
                    _selectedStatus = selected ? 'outOfStock' : null;
                  });
                  if (selected) {
                    context.read<WAInventorySearchProvider>().searchByStatus('outOfStock');
                  } else {
                    context.read<WAInventorySearchProvider>().removeCustomFilter('status');
                  }
                },
                icon: Icons.cancel_outlined,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Advanced Filters Toggle
          InkWell(
            onTap: _toggleAdvancedFilters,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Advanced Filters',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ColorHelper.greenWeb.color),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _showAdvancedFilters ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: ColorHelper.greenWeb.color),
                  ),
                ],
              ),
            ),
          ),

          // Advanced Filters Content with proper animation
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),

                // Price Range
                _AdvancedFilterSection(
                  title: 'Price Range',
                  icon: Icons.attach_money_rounded,
                  child: Row(
                    children: [
                      Expanded(
                        child: _FilterTextField(controller: _minPriceController, hint: 'Min', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'to',
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: _FilterTextField(controller: _maxPriceController, hint: 'Max', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Stock Range
                _AdvancedFilterSection(
                  title: 'Stock Quantity',
                  icon: Icons.inventory_2_outlined,
                  child: Row(
                    children: [
                      Expanded(
                        child: _FilterTextField(controller: _minStockController, hint: 'Min', keyboardType: TextInputType.number),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'to',
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                      ),
                      Expanded(
                        child: _FilterTextField(controller: _maxStockController, hint: 'Max', keyboardType: TextInputType.number),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorHelper.greenWeb.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Apply Filters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;
  final IconData icon;

  const _FilterChip({required this.label, required this.isSelected, required this.onSelected, required this.icon});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : ColorHelper.greenWeb.color),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: ColorHelper.greenWeb.color,
      backgroundColor: ColorHelper.greenWeb.color.withValues(alpha: 0.1),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(color: isSelected ? Colors.white : ColorHelper.greenWeb.color, fontWeight: FontWeight.w500, fontSize: 13),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? ColorHelper.greenWeb.color : ColorHelper.greenWeb.color.withValues(alpha: 0.3), width: 1.5),
      ),
    );
  }
}

class _AdvancedFilterSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _AdvancedFilterSection({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _FilterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _FilterTextField({required this.controller, required this.hint, this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: ColorHelper.greenWeb.color, width: 1.5),
        ),
        isDense: true,
      ),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }
}
