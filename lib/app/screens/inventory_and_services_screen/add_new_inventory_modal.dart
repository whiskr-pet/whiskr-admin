import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:w_image_module/providers/image_provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/models/image_model.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_services_provider.dart';
import 'package:whiskr_admin_panel/app/helpers/utils/inventory_utils/inventory_action_utils.dart';

import '../../../localization_models/localization_models.dart';
import '../../providers/texts_provider.dart';

class AddInventoryModal extends StatefulWidget {
  final Function? onSave;
  final bool isEditMode;

  const AddInventoryModal({super.key, required this.onSave, this.isEditMode = false});

  @override
  State<AddInventoryModal> createState() => _AddInventoryModalState();

  static void show(BuildContext context, {required Function onSave, bool isEditMode = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => ImageHandleProvider(),
        child: AddInventoryModal(onSave: onSave, isEditMode: isEditMode),
      ),
    );
  }
}

class _AddInventoryModalState extends State<AddInventoryModal> with SingleTickerProviderStateMixin {
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
    final InventoryTexts texts = TextsProvider.of(context)!.inventoryTexts;
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
                const ModalHeader(),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: context.read<WAInventoryServicesProvider>().formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ImagePickerWidget(
                            onPickImage: InventoryActionUtils.pickInventoryImage(context),
                            image: context.watch<WAInventoryServicesProvider>().productToEdit?.image,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: context.read<WAInventoryServicesProvider>().nameController,
                            label: texts.inventoryProductNameLabel,
                            icon: Icons.inventory_2_outlined,
                            validator: (v) => v?.isEmpty ?? true ? texts.inventoryRequiredField : null,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: context.read<WAInventoryServicesProvider>().descriptionController,
                            label: texts.inventoryDescriptionLabel,
                            icon: Icons.description_outlined,
                            maxLines: 3,
                            validator: (v) => v?.isEmpty ?? true ? texts.inventoryRequiredField : null,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: context.read<WAInventoryServicesProvider>().brandController,
                                  label: texts.inventoryBrandLabel,
                                  icon: Icons.business_outlined,
                                  validator: (v) => v?.isEmpty ?? true ? texts.inventoryRequiredField : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CategorySelector(
                                  controller: context.read<WAInventoryServicesProvider>().categoryController,
                                  availableCategories: context.watch<WAInventoryServicesProvider>().inventoryCategories,
                                  validator: (v) => v?.isEmpty ?? true ? texts.inventoryRequiredField : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: context.read<WAInventoryServicesProvider>().priceController,
                                  label: texts.inventoryPriceLabel,
                                  icon: Icons.attach_money,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                  validator: (v) => v?.isEmpty ?? true ? texts.inventoryRequiredField : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomDropdown(
                                  value: context.read<WAInventoryServicesProvider>().currency,
                                  label: texts.inventoryCurrencyLabel,
                                  icon: Icons.currency_exchange,
                                  items: const ['USD', 'EUR', 'GBP', 'BAM'],
                                  onChanged: (v) => context.read<WAInventoryServicesProvider>().setCurrency(v!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: context.read<WAInventoryServicesProvider>().stockController,
                                  label: texts.inventoryStockQuantityLabel,
                                  icon: Icons.inventory_outlined,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: (v) => v?.isEmpty ?? true ? texts.inventoryRequiredField : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                          const SizedBox(height: 24),
                          EnhancedTagSection(
                            controller: context.read<WAInventoryServicesProvider>().tagController,
                            selectedTags: context.watch<WAInventoryServicesProvider>().tags,
                            availableTags: context.watch<WAInventoryServicesProvider>().inventoryTags,
                            onAddTag: context.read<WAInventoryServicesProvider>().addTag,
                            onRemoveTag: context.read<WAInventoryServicesProvider>().removeTag,
                          ),
                          const SizedBox(height: 24),
                          ActiveStatusSwitch(
                            active: context.watch<WAInventoryServicesProvider>().active,
                            onChanged: (v) => context.read<WAInventoryServicesProvider>().setIsActive(v),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ModalFooter(
                  isUploading: context.watch<WAInventoryServicesProvider>().isUploading,
                  onCancel: InventoryActionUtils.handleCancel(_animationController, context),
                  onSave: InventoryActionUtils.handleSave(widget.onSave, context),
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

// Stateless Widgets

class ModalHeader extends StatelessWidget {
  const ModalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final InventoryTexts texts = TextsProvider.of(context)!.inventoryTexts;
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
            child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Text(texts.inventoryAddProductButton, style: theme.textTheme.bodyLarge!.copyWith(fontSize: 24, color: ColorHelper.white.color)),
        ],
      ),
    );
  }
}

class CategorySelector extends StatefulWidget {
  final TextEditingController controller;
  final List<String> availableCategories;
  final String? Function(String?)? validator;

  const CategorySelector({super.key, required this.controller, required this.availableCategories, this.validator});

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  bool _isCustom = false;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Check if controller has existing value
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
    final InventoryTexts texts = TextsProvider.of(context)!.inventoryTexts;

    if (_isCustom) {
      return CustomTextField(controller: widget.controller, label: texts.inventoryCategoryLabel, icon: Icons.category_outlined, validator: widget.validator);
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: texts.inventoryCategoryLabel,
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
        ...widget.availableCategories.map((String category) {
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
      onChanged: (String? value) {
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

class EnhancedTagSection extends StatelessWidget {
  final TextEditingController controller;
  final List<String> selectedTags;
  final List<String> availableTags;
  final VoidCallback onAddTag;
  final Function(String) onRemoveTag;

  const EnhancedTagSection({super.key, required this.controller, required this.selectedTags, required this.availableTags, required this.onAddTag, required this.onRemoveTag});

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
    final ThemeData theme = Theme.of(context);
    final InventoryTexts texts = TextsProvider.of(context)!.inventoryTexts;

    // Get available tags that aren't already selected
    final List<String> unselectedAvailableTags = availableTags.where((String tag) => !selectedTags.contains(tag)).toList();

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
              Text(texts.inventoryTagsLabel, style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),

          // Show available tags if there are any
          if (unselectedAvailableTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Quick Select:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: unselectedAvailableTags.map((String tag) {
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

          // Selected tags
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
              children: selectedTags.map((String tag) {
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

          // Custom tag input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => onAddTag(),
                  decoration: InputDecoration(
                    hintText: texts.inventoryAddTagHint,
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

class ImagePickerWidget extends StatelessWidget {
  final VoidCallback onPickImage;
  final ImageModel? image;

  const ImagePickerWidget({super.key, required this.onPickImage, this.image});

  @override
  Widget build(BuildContext context) {
    final InventoryTexts texts = TextsProvider.of(context)!.inventoryTexts;
    return Consumer<ImageHandleProvider>(
      builder: (context, imageProvider, _) {
        final hasImage = image != null || imageProvider.imageBytes != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              texts.inventoryProductImageLabel,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onPickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: hasImage ? Colors.grey.shade100 : Colors.grey.shade50,
                  border: Border.all(color: hasImage ? Colors.blue.shade300 : Colors.grey.shade300, width: 2, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: hasImage
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: image != null && image?.url != null && image!.url!.isNotEmpty
                                ? Image.network(image!.url!, width: double.infinity, height: double.infinity, fit: BoxFit.contain)
                                : Image.memory(base64Decode(imageProvider.imageBytes!.fileBytes), width: double.infinity, height: double.infinity, fit: BoxFit.contain),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: onPickImage,
                                tooltip: texts.inventoryChangeImage,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            texts.inventoryUploadImageHint,
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text(texts.inventoryUploadImageFormats, style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const CustomTextField({super.key, required this.controller, required this.label, required this.icon, this.maxLines = 1, this.keyboardType, this.inputFormatters, this.validator});

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

class CustomDropdown extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final List<String> items;
  final Function(String?) onChanged;

  const CustomDropdown({super.key, required this.value, required this.label, required this.icon, required this.items, required this.onChanged});

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

class ActiveStatusSwitch extends StatelessWidget {
  final bool active;
  final Function(bool) onChanged;

  const ActiveStatusSwitch({super.key, required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final InventoryTexts texts = TextsProvider.of(context)!.inventoryTexts;
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
          Expanded(child: Text(texts.inventoryActiveStatusLabel, style: theme.textTheme.bodyMedium)),
          Switch(value: active, onChanged: onChanged, activeThumbColor: ColorHelper.orange500.color),
        ],
      ),
    );
  }
}

class ModalFooter extends StatelessWidget {
  final bool isUploading;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool isEditMode;

  const ModalFooter({super.key, required this.isUploading, required this.onCancel, required this.onSave, this.isEditMode = false});

  @override
  Widget build(BuildContext context) {
    final InventoryTexts texts = TextsProvider.of(context)!.inventoryTexts;
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
              texts.inventoryCancelButton,
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
                : Text(isEditMode ? texts.inventoryEditProductButton : texts.inventoryAddProductButton, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
