import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:w_components/wa_custom_snackbar/wa_custom_snackbar.dart';
import 'package:w_image_module/providers/image_provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:wa_inventory_services_module/providers/wa_inventory_services_provider.dart';

class AddInventoryModal extends StatefulWidget {
  final Function? onSave;

  const AddInventoryModal({super.key, required this.onSave});

  @override
  State<AddInventoryModal> createState() => _AddInventoryModalState();

  static void show(BuildContext context, {required Function onSave}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => ImageHandleProvider(),
        child: AddInventoryModal(onSave: onSave),
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

  Future<void> _pickImage() async {
    final imageProvider = context.read<ImageHandleProvider>();
    await imageProvider.pickImageForWeb();
  }

  Future<void> _handleSave() async {
    if (context.read<WAInventoryServicesProvider>().formKey.currentState!.validate()) {
      final imageProvider = context.read<ImageHandleProvider>();

      // Check if image is selected
      if (imageProvider.imageBytes == null) {
        WACustomSnackbar.instance.showSnack(context, 'Please select an image', type: WACustomSnackbarType.error);
        return;
      }

      context.read<WAInventoryServicesProvider>().setIsUploading(true);

      try {
        if (widget.onSave != null) {
          // todo add image when uploaded, maybe change a logic little bit
          // context.read<WAInventoryServicesProvider>().setImage();
          widget.onSave!();
        }
      } catch (e) {
        WACustomSnackbar.instance.showSnack(context, 'Error: $e', type: WACustomSnackbarType.error);
      } finally {
        context.read<WAInventoryServicesProvider>().setIsUploading(false);
      }
    }
  }

  void _handleCancel() {
    _animationController.reverse().then((_) => Navigator.of(context).pop());
  }

  @override
  Widget build(BuildContext context) {
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
                          ImagePickerWidget(onPickImage: _pickImage),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: context.read<WAInventoryServicesProvider>().nameController,
                            label: 'Product Name',
                            icon: Icons.inventory_2_outlined,
                            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: context.read<WAInventoryServicesProvider>().descriptionController,
                            label: 'Description',
                            icon: Icons.description_outlined,
                            maxLines: 3,
                            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: context.read<WAInventoryServicesProvider>().brandController,
                                  label: 'Brand',
                                  icon: Icons.business_outlined,
                                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomTextField(
                                  controller: context.read<WAInventoryServicesProvider>().categoryController,
                                  label: 'Category',
                                  icon: Icons.category_outlined,
                                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
                                  label: 'Price',
                                  icon: Icons.attach_money,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomDropdown(
                                  value: context.read<WAInventoryServicesProvider>().currency,
                                  label: 'Currency',
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
                                  label: 'Stock Quantity',
                                  icon: Icons.inventory_outlined,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                          const SizedBox(height: 24),
                          TagSection(
                            controller: context.read<WAInventoryServicesProvider>().tagController,
                            tags: context.read<WAInventoryServicesProvider>().tags,
                            onAddTag: context.read<WAInventoryServicesProvider>().addTag,
                            onRemoveTag: context.read<WAInventoryServicesProvider>().removeTag,
                          ),
                          const SizedBox(height: 24),
                          ActiveStatusSwitch(active: context.watch<WAInventoryServicesProvider>().active, onChanged: (v) => context.read<WAInventoryServicesProvider>().setIsActive(v)),
                        ],
                      ),
                    ),
                  ),
                ),
                ModalFooter(isUploading: context.watch<WAInventoryServicesProvider>().isUploading, onCancel: _handleCancel, onSave: _handleSave),
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
          Text('Add New Product', style: theme.textTheme.bodyLarge!.copyWith(fontSize: 24, color: ColorHelper.white.color)),
        ],
      ),
    );
  }
}

class ImagePickerWidget extends StatelessWidget {
  final VoidCallback onPickImage;

  const ImagePickerWidget({super.key, required this.onPickImage});

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageHandleProvider>(
      builder: (context, imageProvider, _) {
        final hasImage = imageProvider.imageBytes != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Image',
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
                            // TODO(danispreldzic):: check this out
                            child: Image.memory(base64Decode(imageProvider.imageBytes!.fileBytes), width: double.infinity, height: double.infinity, fit: BoxFit.cover),
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
                                tooltip: 'Change image',
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
                            'Click to upload product image',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Text('PNG, JPG up to 10MB', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
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

class TagSection extends StatelessWidget {
  final TextEditingController controller;
  final List<String> tags;
  final VoidCallback onAddTag;
  final Function(String) onRemoveTag;

  const TagSection({super.key, required this.controller, required this.tags, required this.onAddTag, required this.onRemoveTag});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onAddTag(),
                decoration: InputDecoration(
                  hintText: 'Add a tag...',
                  prefixIcon: Icon(Icons.label_outline, color: ColorHelper.greenWeb.color),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add_circle, color: ColorHelper.orange500.color),
                    onPressed: onAddTag,
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
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ),
          ],
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => onRemoveTag(tag),
                backgroundColor: ColorHelper.orange500.color,
                labelStyle: theme.textTheme.bodyMedium!.copyWith(color: ColorHelper.white.color),
                deleteIconColor: ColorHelper.greenWeb.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: ColorHelper.orange300.color),
                ),
              );
            }).toList(),
          ),
        ],
      ],
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

class ModalFooter extends StatelessWidget {
  final bool isUploading;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const ModalFooter({super.key, required this.isUploading, required this.onCancel, required this.onSave});

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
                : const Text('Add Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
