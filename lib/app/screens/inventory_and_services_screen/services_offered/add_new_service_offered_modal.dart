import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:wa_inventory_services_module/providers/wa_services_providers/wa_services_provider.dart';
import 'package:whiskr_admin_panel/app/helpers/utils/service_offered_utils/service_offered_action_utils.dart';

class AddServiceOfferedModal extends StatefulWidget {
  final Function? onSave;
  final bool isEditMode;

  const AddServiceOfferedModal({super.key, required this.onSave, this.isEditMode = false});

  @override
  State<AddServiceOfferedModal> createState() => _AddServiceOfferedModalState();

  static void show(BuildContext context, {required Function onSave, bool isEditMode = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddServiceOfferedModal(onSave: onSave, isEditMode: isEditMode),
    );
  }
}

class _AddServiceOfferedModalState extends State<AddServiceOfferedModal> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack);
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final WAServicesProvider provider = context.read<WAServicesProvider>();
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 700,
            constraints: const BoxConstraints(maxHeight: 800),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 40, offset: const Offset(0, 20))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ServiceModalHeader(isEditMode: widget.isEditMode),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: provider.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ServiceTextField(
                            controller: provider.nameController,
                            label: 'Service Name',
                            icon: Icons.business_center_outlined,
                            validator: (v) => v?.isEmpty ?? true ? 'This field is required' : null,
                          ),
                          const SizedBox(height: 20),
                          _ServiceTextField(
                            controller: provider.descriptionController,
                            label: 'Description',
                            icon: Icons.description_outlined,
                            maxLines: 3,
                            validator: (v) => v?.isEmpty ?? true ? 'This field is required' : null,
                          ),
                          const SizedBox(height: 20),
                          _ServiceCategorySelector(
                            controller: provider.categoryController,
                            availableCategories: provider.serviceOfferedCategories,
                            validator: (v) => v?.isEmpty ?? true ? 'This field is required' : null,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _ServiceTextField(
                                  controller: provider.priceController,
                                  label: 'Price',
                                  icon: Icons.attach_money,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                  validator: (v) => v?.isEmpty ?? true ? 'This field is required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _ServiceDropdown(
                                  value: provider.currency,
                                  label: 'Currency',
                                  icon: Icons.currency_exchange,
                                  items: const ['BAM', 'USD', 'EUR', 'GBP'],
                                  onChanged: (v) => context.read<WAServicesProvider>().setCurrency(v!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _ServiceTagSection(
                            controller: provider.tagController,
                            selectedTags: context.watch<WAServicesProvider>().tags,
                            availableTags: context.watch<WAServicesProvider>().serviceOfferedTags,
                            onAddTag: context.read<WAServicesProvider>().addTag,
                            onRemoveTag: context.read<WAServicesProvider>().removeTag,
                          ),
                          const SizedBox(height: 24),
                          _ServiceActiveSwitch(active: context.watch<WAServicesProvider>().active, onChanged: (v) => context.read<WAServicesProvider>().setIsActive(v)),
                        ],
                      ),
                    ),
                  ),
                ),
                _ServiceModalFooter(
                  isUploading: context.watch<WAServicesProvider>().isUploading,
                  onCancel: ServiceOfferedActionUtils.handleCancel(_animationController, context),
                  onSave: ServiceOfferedActionUtils.handleSave(widget.onSave, context),
                  isEditMode: widget.isEditMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceModalHeader extends StatelessWidget {
  final bool isEditMode;

  const _ServiceModalHeader({required this.isEditMode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [ColorHelper.greenWeb.color, ColorHelper.greenWeb.color.withAlpha(200)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withAlpha(70), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.add_business, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Text(isEditMode ? 'Edit Service' : 'Add Service', style: theme.textTheme.bodyLarge!.copyWith(fontSize: 24, color: ColorHelper.white.color)),
        ],
      ),
    );
  }
}

class _ServiceCategorySelector extends StatefulWidget {
  final TextEditingController controller;
  final List<String> availableCategories;
  final String? Function(String?)? validator;

  const _ServiceCategorySelector({required this.controller, required this.availableCategories, this.validator});

  @override
  State<_ServiceCategorySelector> createState() => _ServiceCategorySelectorState();
}

class _ServiceCategorySelectorState extends State<_ServiceCategorySelector> {
  bool _isCustom = false;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isNotEmpty) {
      if (widget.availableCategories.contains(widget.controller.text)) {
        _selectedCategory = widget.controller.text;
      } else {
        _isCustom = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCustom) {
      return _ServiceTextField(controller: widget.controller, label: 'Category', icon: Icons.category_outlined, validator: widget.validator);
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: Icon(Icons.category_outlined, color: ColorHelper.greenWeb.color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorHelper.greenWeb.color, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: widget.validator,
      items: [
        ...widget.availableCategories.map((category) {
          return DropdownMenuItem<String>(value: category, child: Text(category));
        }),
        DropdownMenuItem<String>(
          value: '__custom__',
          child: Row(
            children: [
              Icon(Icons.add_circle_outline, size: 18, color: ColorHelper.orange500.color),
              const SizedBox(width: 8),
              Text(
                'Custom Category',
                style: TextStyle(color: ColorHelper.orange500.color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        if (value == '__custom__') {
          setState(() {
            _isCustom = true;
            _selectedCategory = null;
          });
        } else {
          setState(() {
            _selectedCategory = value;
            widget.controller.text = value ?? '';
          });
        }
      },
    );
  }
}

class _ServiceTagSection extends StatelessWidget {
  final TextEditingController controller;
  final List<String> selectedTags;
  final List<String> availableTags;
  final VoidCallback onAddTag;
  final Function(String) onRemoveTag;

  const _ServiceTagSection({required this.controller, required this.selectedTags, required this.availableTags, required this.onAddTag, required this.onRemoveTag});

  void _toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      onRemoveTag(tag);
    } else {
      controller.text = tag;
      onAddTag();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unselectedTags = availableTags.where((tag) => !selectedTags.contains(tag)).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer_rounded, size: 20, color: ColorHelper.greenWeb.color),
              const SizedBox(width: 8),
              Text('Tags', style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          if (unselectedTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Quick Select:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: unselectedTags.map((tag) {
                return InkWell(
                  onTap: () => _toggleTag(tag),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ColorHelper.greenWeb.color.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_outline, size: 16, color: ColorHelper.greenWeb.color),
                        const SizedBox(width: 4),
                        Text(
                          tag,
                          style: TextStyle(color: ColorHelper.greenWeb.color, fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (selectedTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Selected Tags:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedTags.map((tag) {
                return Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.close_rounded, size: 18),
                  onDeleted: () => onRemoveTag(tag),
                  backgroundColor: ColorHelper.orange500.color,
                  labelStyle: theme.textTheme.bodyMedium!.copyWith(color: ColorHelper.white.color, fontWeight: FontWeight.w600),
                  deleteIconColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: ColorHelper.orange300.color),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => onAddTag(),
                  decoration: InputDecoration(
                    hintText: 'Add custom tag',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: Icon(Icons.edit_outlined, color: ColorHelper.greenWeb.color, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add_circle, color: ColorHelper.orange500.color, size: 24),
                      onPressed: onAddTag,
                      tooltip: 'Add custom tag',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: ColorHelper.greenWeb.color, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _ServiceTextField({required this.controller, required this.label, required this.icon, this.maxLines = 1, this.keyboardType, this.inputFormatters, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: ColorHelper.greenWeb.color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorHelper.greenWeb.color, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}

class _ServiceDropdown extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final List<String> items;
  final Function(String?) onChanged;

  const _ServiceDropdown({required this.value, required this.label, required this.icon, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: ColorHelper.greenWeb.color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: ColorHelper.greenWeb.color, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
    );
  }
}

class _ServiceActiveSwitch extends StatelessWidget {
  final bool active;
  final Function(bool) onChanged;

  const _ServiceActiveSwitch({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.toggle_on_outlined, color: ColorHelper.greenWeb.color),
          const SizedBox(width: 12),
          Expanded(child: Text('Active Status', style: theme.textTheme.bodyMedium)),
          Switch(value: active, onChanged: onChanged, activeThumbColor: ColorHelper.orange500.color),
        ],
      ),
    );
  }
}

class _ServiceModalFooter extends StatelessWidget {
  final bool isUploading;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isEditMode;

  const _ServiceModalFooter({required this.isUploading, required this.onCancel, required this.onSave, required this.isEditMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: isUploading ? null : onCancel,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isUploading ? Colors.grey.shade400 : Colors.grey.shade700),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: isUploading ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorHelper.greenWeb.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: isUploading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                : Text(isEditMode ? 'Update Service' : 'Add Service', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
