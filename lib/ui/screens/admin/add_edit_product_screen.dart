import 'dart:io';

import 'package:ecommerce_frontend/core/constants/app_colors.dart';
import 'package:ecommerce_frontend/ui/screens/admin/widgets/admin_text_field.dart';
import 'package:ecommerce_frontend/models/product_model.dart';
import 'package:ecommerce_frontend/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Single screen for both creating and editing a product.
///
/// - `existingProduct == null`  → "Add Product" mode → calls addProduct()
/// - `existingProduct != null`  → "Edit Product" mode → calls updateProduct()

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? existingProduct;

  const AddEditProductScreen({super.key, this.existingProduct});

  bool get isEditing => existingProduct != null;

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;
  late final TextEditingController _stockController;
  late final TextEditingController _urlController;

  bool _isSaving = false;
  File? selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => selectedImage = File(image.path));
    }
  }

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '');
    _urlController = TextEditingController(text: p?.url ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (widget.isEditing) {
        await _productService.updateProduct(
          productId: widget.existingProduct!.id,
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          category: _categoryController.text.trim(),
          stock: int.parse(_stockController.text.trim()),
          url: _urlController.text.trim(),
        );
      } else {
        await _productService.addProduct(
          name: _nameController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          category: _categoryController.text.trim(),
          stock: int.parse(_stockController.text.trim()),
          url: selectedImage!,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true); // true → caller should refresh list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Product' : 'Add Product',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AdminTextField(
              label: 'Product Name',
              controller: _nameController,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            AdminTextField(
              label: 'Price (Rs.)',
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Price is required';
                if (double.tryParse(v.trim()) == null)
                  return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AdminTextField(
              label: 'Category',
              controller: _categoryController,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Category is required'
                  : null,
            ),
            const SizedBox(height: 16),
            AdminTextField(
              label: 'Stock',
              controller: _stockController,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Stock is required';
                if (int.tryParse(v.trim()) == null)
                  return 'Enter a valid integer';
                return null;
              },
            ),
            const SizedBox(height: 16),
            // AdminTextField(
            //   label: 'Image URL',
            //   controller: _urlController,
            //   maxLines: 2,
            //   validator: (v) => (v == null || v.trim().isEmpty)
            //       ? 'Image URL is required'
            //       : null,
            // ),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(selectedImage!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            "Tap to select image",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 28),
            _SaveButton(
              isSaving: _isSaving,
              onTap: _handleSave,
              isEditing: isEditing,
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isSaving;
  final bool isEditing;
  final VoidCallback onTap;

  const _SaveButton({
    required this.isSaving,
    required this.isEditing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSaving ? null : onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  isEditing ? 'Save Changes' : 'Add Product',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
