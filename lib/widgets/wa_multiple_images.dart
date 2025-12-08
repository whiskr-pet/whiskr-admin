import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w_components/wa_custom_snackbar/wa_custom_snackbar.dart';
import 'package:w_image_module/providers/image_provider.dart';
import 'package:w_utils/color_helper/color_helper.dart';
import 'package:w_utils/models/response_model.dart';

/// A modern multiple image picker widget that allows selecting up to 5 images
/// with the ability to remove individual images.
class WAMultipleImagePicker extends StatefulWidget {
  final int maxImages;
  final Function(List<Uint8List>) onImagesChanged;
  final List<Uint8List>? initialImages;

  // Localized text parameters
  final String? title;
  final String? maxReachedMessage;
  final String? imageAddedMessage;
  final String? imageRemovedMessage;
  final String? addImageLabel;

  const WAMultipleImagePicker({
    super.key,
    this.maxImages = 5,
    required this.onImagesChanged,
    this.initialImages,
    this.title = '',
    this.addImageLabel = '',
    this.imageAddedMessage = '',
    this.imageRemovedMessage = '',
    this.maxReachedMessage = '',
  });

  @override
  State<WAMultipleImagePicker> createState() => _WAMultipleImagePickerState();
}

class _WAMultipleImagePickerState extends State<WAMultipleImagePicker> {
  List<Uint8List> _images = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialImages != null) {
      _images.addAll(widget.initialImages!);
    }
  }

  Future<void> _pickImage() async {
    if (_images.length >= widget.maxImages) {
      if (!mounted) return;
      WACustomSnackbar.instance.showSnack(context, widget.maxReachedMessage ?? '', type: WACustomSnackbarType.error);
      return;
    }

    final imageProvider = context.read<ImageHandleProvider>();
    final ResponseModel<List<Uint8List>?> imageResult = await imageProvider.pickMultipleImagesForWeb();

    if (!mounted) return;

    if (!imageResult.isSuccess) {
      WACustomSnackbar.instance.showSnack(context, imageResult.error!, type: WACustomSnackbarType.error);
      return;
    }

    if (imageResult.data != null) {
      setState(() {
        _images = imageResult.data!;
      });
    }

    widget.onImagesChanged(_images);

    WACustomSnackbar.instance.showSnack(context, '${widget.imageAddedMessage} (${_images.length}/${widget.maxImages})', type: WACustomSnackbarType.success);
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
    widget.onImagesChanged(_images);

    WACustomSnackbar.instance.showSnack(context, widget.imageRemovedMessage ?? '', type: WACustomSnackbarType.info);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title ?? '',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ColorHelper.grey900.color),
            ),
            Text('${_images.length}/${widget.maxImages}', style: TextStyle(fontSize: 14, color: ColorHelper.grey600.color)),
          ],
        ),
        const SizedBox(height: 16),
        _buildImageGrid(),
      ],
    );
  }

  Widget _buildImageGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ..._images.asMap().entries.map((entry) {
          return _ImageTile(imageBytes: entry.value, onRemove: () => _removeImage(entry.key));
        }),
        if (_images.length < widget.maxImages) _AddImageTile(onTap: _pickImage, addImageLabel: widget.addImageLabel),
      ],
    );
  }
}

class _ImageTile extends StatefulWidget {
  final Uint8List imageBytes;
  final VoidCallback onRemove;

  const _ImageTile({required this.imageBytes, required this.onRemove});

  @override
  State<_ImageTile> createState() => _ImageTileState();
}

class _ImageTileState extends State<_ImageTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorHelper.grey300.color, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(widget.imageBytes, fit: BoxFit.cover),
              if (_isHovered)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.red.shade500, shape: BoxShape.circle),
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                      ),
                      onPressed: widget.onRemove,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddImageTile extends StatefulWidget {
  final VoidCallback onTap;
  final String? addImageLabel;

  const _AddImageTile({required this.onTap, this.addImageLabel = ''});

  @override
  State<_AddImageTile> createState() => _AddImageTileState();
}

class _AddImageTileState extends State<_AddImageTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _isHovered ? ColorHelper.white.color : ColorHelper.grey300.color, width: 2, style: BorderStyle.solid),
            color: _isHovered ? ColorHelper.greenWeb.color.withValues(alpha: 40) : ColorHelper.grey100.color,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 32, color: _isHovered ? ColorHelper.white.color : ColorHelper.grey500.color),
              const SizedBox(height: 8),
              Text(
                widget.addImageLabel ?? '',
                style: TextStyle(fontSize: 12, color: _isHovered ? ColorHelper.white.color : ColorHelper.grey600.color, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
