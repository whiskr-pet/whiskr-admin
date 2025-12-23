import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_dashboard/helpers/stock_status_type.dart';
import 'package:w_search_module/w_search_module.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/responsive_web/responsive_web_helper.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_providers/wa_inventory_search_provider.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_providers/wa_inventory_services_provider.dart';

import '../../../../localization_models/inventory_text/inventory_text.dart';
import '../../../providers/texts_provider.dart';

class InventoryFiltersWidget extends StatefulWidget {
  final List<String> availableCategories;
  final List<String> availableTags;

  const InventoryFiltersWidget({super.key, required this.availableCategories, required this.availableTags});

  @override
  State<InventoryFiltersWidget> createState() => _InventoryFiltersWidgetState();
}

class _InventoryFiltersWidgetState extends State<InventoryFiltersWidget> with SingleTickerProviderStateMixin {
  String? _selectedStatus;
  bool? _selectedActiveStatus;
  String? _selectedCategory;
  String? _selectedSortBy;
  SortOrder? _selectedSortOrder;
  final List<String> _selectedTags = [];
  bool _showAdvancedFilters = false;

  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  final List<String> _sortOptions = ['created_at', 'updated_at', 'stock_quantity', 'price'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _expandAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _enableSearchMode() {
    final WAInventoryServicesProvider inventoryProvider = context.read<WAInventoryServicesProvider>();
    inventoryProvider.setSearchMode(true);
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedActiveStatus = null;
      _selectedCategory = null;
      _selectedSortBy = null;
      _selectedSortOrder = null;
      _selectedTags.clear();
    });

    final WAInventorySearchProvider searchProvider = context.read<WAInventorySearchProvider>();
    final WAInventoryServicesProvider inventoryProvider = context.read<WAInventoryServicesProvider>();
    searchProvider.clearAllFilters();
    // Disable search mode to show all products
    inventoryProvider.setSearchMode(false);
  }

  void _applyStatusFilter(String? status) async {
    setState(() {
      _selectedStatus = status;
    });

    _enableSearchMode();
    final WAInventorySearchProvider searchProvider = context.read<WAInventorySearchProvider>();

    if (status != null) {
      await searchProvider.searchByStatus(status);
    } else {
      searchProvider.removeCustomFilter('status');
      await searchProvider.refresh();
    }
  }

  void _applyActiveFilter(bool? active) async {
    setState(() {
      _selectedActiveStatus = active;
    });

    _enableSearchMode();
    final WAInventorySearchProvider searchProvider = context.read<WAInventorySearchProvider>();
    await searchProvider.filterByActive(active);
  }

  void _applyCategoryFilter(String? category) async {
    setState(() {
      _selectedCategory = category;
    });

    _enableSearchMode();
    final WAInventorySearchProvider searchProvider = context.read<WAInventorySearchProvider>();
    await searchProvider.filterByCategory(category);
  }

  void _applyTagsFilter() async {
    _enableSearchMode();
    final WAInventorySearchProvider searchProvider = context.read<WAInventorySearchProvider>();

    if (_selectedTags.isNotEmpty) {
      await searchProvider.filterByTags(_selectedTags);
    } else {
      await searchProvider.filterByTags(null);
    }
  }

  void _addTag(String tag) {
    if (!_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
      });
      _applyTagsFilter();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
    _applyTagsFilter();
  }

  void _applySorting(String? sortBy, SortOrder? order) async {
    setState(() {
      _selectedSortBy = sortBy;
      _selectedSortOrder = order;
    });

    _enableSearchMode();
    final WAInventorySearchProvider searchProvider = context.read<WAInventorySearchProvider>();
    await searchProvider.setSorting(sortBy, order);
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

  String _getSortDisplayName(String sortBy) {
    final InventoryTexts texts = TextsProvider.of(context)!.inventoryTexts;

    switch (sortBy) {
      case 'created_at':
        return texts.inventoryFiltersSortDateCreated;
      case 'updated_at':
        return texts.inventoryFiltersSortLastUpdated;
      case 'stock_quantity':
        return texts.inventoryFiltersSortStockQuantity;
      case 'price':
        return texts.inventoryFiltersSortPrice;
      default:
        return sortBy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters = _selectedStatus != null || _selectedActiveStatus != null || _selectedCategory != null || _selectedTags.isNotEmpty || _selectedSortBy != null;
    final InventoryTexts texts = TextsProvider.of(context)!.inventoryTexts;

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
                texts.inventoryFiltersTitle,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800]),
              ),
              if (hasActiveFilters)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: ColorHelper.greenWeb.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '${_getActiveFilterCount()}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: ColorHelper.greenWeb.color),
                  ),
                ),
              const Spacer(),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: Icon(Icons.clear_rounded, size: 16, color: Colors.red[400]),
                  label: Text(
                    texts.inventoryFiltersClearAll,
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

          // Stock Status Filter Chips
          _SectionLabel(icon: Icons.inventory_rounded, label: texts.inventoryFiltersStockStatus),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: texts.inventoryFiltersInStock,
                isSelected: _selectedStatus == LowStockProductStatus.inStock.name,
                onSelected: (bool selected) {
                  _applyStatusFilter(selected ? LowStockProductStatus.inStock.name : null);
                },
                icon: Icons.check_circle_outline,
              ),
              _FilterChip(
                label: texts.inventoryFiltersLowStock,
                isSelected: _selectedStatus == LowStockProductStatus.lowStock.name,
                onSelected: (bool selected) {
                  _applyStatusFilter(selected ? LowStockProductStatus.lowStock.name : null);
                },
                icon: Icons.warning_amber_rounded,
              ),
              _FilterChip(
                label: texts.inventoryFiltersOutOfStock,
                isSelected: _selectedStatus == LowStockProductStatus.outOfStock.name,
                onSelected: (bool selected) {
                  _applyStatusFilter(selected ? LowStockProductStatus.outOfStock.name : null);
                },
                icon: Icons.cancel_outlined,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Active Status Filter
          _SectionLabel(icon: Icons.toggle_on_rounded, label: texts.inventoryFiltersProductStatus),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: texts.inventoryFiltersActive,
                isSelected: _selectedActiveStatus == true,
                onSelected: (bool selected) {
                  _applyActiveFilter(selected ? true : null);
                },
                icon: Icons.visibility_rounded,
              ),
              _FilterChip(
                label: texts.inventoryFiltersInactive,
                isSelected: _selectedActiveStatus == false,
                onSelected: (bool selected) {
                  _applyActiveFilter(selected ? false : null);
                },
                icon: Icons.visibility_off_rounded,
              ),
            ],
          ),

          const SizedBox(height: 12),

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
                    texts.inventoryFiltersAdvanced,
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

          // Advanced Filters Content
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Category Filter
                _SectionLabel(icon: Icons.category_rounded, label: texts.inventoryFiltersCategory),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      hint: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          widget.availableCategories.isEmpty ? texts.inventoryFiltersCategoryNoneAvailable : texts.inventoryFiltersCategorySelectHint,
                          style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                      ),
                      isExpanded: true,
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(Icons.arrow_drop_down_rounded, color: ColorHelper.greenWeb.color),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(texts.inventoryFiltersAllCategories, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          ),
                        ),
                        ...widget.availableCategories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(category, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            ),
                          );
                        }),
                      ],
                      onChanged: widget.availableCategories.isEmpty
                          ? null
                          : (String? newValue) {
                              _applyCategoryFilter(newValue);
                            },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Tags Filter
                _SectionLabel(icon: Icons.local_offer_rounded, label: texts.inventoryFiltersTags),
                const SizedBox(height: 8),

                // Selected Tags Display
                if (_selectedTags.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _selectedTags.map((String tag) {
                      return Chip(
                        label: Text(tag),
                        deleteIcon: const Icon(Icons.close_rounded, size: 16),
                        onDeleted: () => _removeTag(tag),
                        backgroundColor: ColorHelper.greenWeb.color.withValues(alpha: 0.1),
                        labelStyle: TextStyle(color: ColorHelper.greenWeb.color, fontSize: 12, fontWeight: FontWeight.w500),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],

                // Tags Dropdown
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: null,
                      hint: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          widget.availableTags.isEmpty ? texts.inventoryFiltersTagsNoneAvailable : texts.inventoryFiltersTagsAddHint,
                          style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                      ),
                      isExpanded: true,
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(Icons.arrow_drop_down_rounded, color: ColorHelper.greenWeb.color),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      items: widget.availableTags.where((String tag) => !_selectedTags.contains(tag)).map((String tag) {
                        return DropdownMenuItem<String>(
                          value: tag,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(tag, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          ),
                        );
                      }).toList(),
                      onChanged: widget.availableTags.isEmpty
                          ? null
                          : (String? newValue) {
                              if (newValue != null) {
                                _addTag(newValue);
                              }
                            },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sorting Options
                _SectionLabel(icon: Icons.sort_rounded, label: texts.inventoryFiltersSortBy),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSortBy,
                      hint: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(texts.inventoryFiltersSortSelectHint, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                      ),
                      isExpanded: true,
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(Icons.arrow_drop_down_rounded, color: ColorHelper.greenWeb.color),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(texts.inventoryFiltersSortDefault, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          ),
                        ),
                        ..._sortOptions.map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(_getSortDisplayName(option), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            ),
                          );
                        }),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue == null) {
                          _applySorting(null, null);
                        } else {
                          _applySorting(newValue, _selectedSortOrder ?? SortOrder.asc);
                        }
                      },
                    ),
                  ),
                ),

                if (_selectedSortBy != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _FilterChip(
                          label: texts.inventoryFiltersSortAscending,
                          isSelected: _selectedSortOrder == SortOrder.asc,
                          onSelected: (bool selected) {
                            _applySorting(_selectedSortBy, selected ? SortOrder.asc : SortOrder.desc);
                          },
                          icon: Icons.arrow_upward_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FilterChip(
                          label: texts.inventoryFiltersSortDescending,
                          isSelected: _selectedSortOrder == SortOrder.desc,
                          onSelected: (bool selected) {
                            _applySorting(_selectedSortBy, selected ? SortOrder.desc : SortOrder.asc);
                          },
                          icon: Icons.arrow_downward_rounded,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedStatus != null) count++;
    if (_selectedActiveStatus != null) count++;
    if (_selectedCategory != null) count++;
    if (_selectedTags.isNotEmpty) count++;
    if (_selectedSortBy != null) count++;
    return count;
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

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
