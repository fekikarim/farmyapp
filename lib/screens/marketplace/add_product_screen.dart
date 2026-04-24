import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import '../../providers/product_provider.dart';
import '../../models/product_type_model.dart';

import '../../models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();

  File? _selectedImage;
  String? _selectedProductTypeId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProductProvider>().fetchProductTypes());

    if (widget.product != null) {
      _titleController.text = widget.product!.title;
      _descriptionController.text = widget.product!.description ?? '';
      _priceController.text = widget.product!.price.toString();
      _quantityController.text = widget.product!.quantity.toString();
      _unitController.text = widget.product!.unit;
      _selectedProductTypeId = widget.product!.productTypeId;
      // Note: Image handling for edit needs care (showing existing image vs new selection)
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _onProductTypeChanged(ProductType? type) {
    if (type != null) {
      setState(() {
        _selectedProductTypeId = type.id;
        _unitController.text = type.unit;
      });
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final originalFile = File(result.files.single.path!);
      final bytes = await originalFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image != null) {
        // Resize if too large (max width 1024)
        var resized = image;
        if (image.width > 1024) {
          resized = img.copyResize(image, width: 1024);
        }

        // Compress to JPG with 85% quality
        final compressedBytes = img.encodeJpg(resized, quality: 85);

        // Save to temp file
        final tempDir = Directory.systemTemp;

        // Ensure unique filename
        final uniqueId = DateTime.now().millisecondsSinceEpoch;
        final tempFile = File('${tempDir.path}/compressed_$uniqueId.jpg');
        await tempFile.writeAsBytes(compressedBytes);

        setState(() {
          _selectedImage = tempFile;
        });
      } else {
        // Fallback if decoding fails
        setState(() {
          _selectedImage = originalFile;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectProductType)),
      );
      return;
    }

    final data = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'price': double.parse(_priceController.text),
      'quantity': double.parse(_quantityController.text),
      'unit': _unitController.text,
      'product_type_id': _selectedProductTypeId,
    };

    final provider = context.read<ProductProvider>();
    bool success;

    if (widget.product != null) {
      success = await provider.updateProduct(
        widget.product!.id,
        data,
        imageFile: _selectedImage,
      );
    } else {
      success = await provider.addProduct(data, imageFile: _selectedImage);
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.product != null
                ? AppLocalizations.of(context)!.productUpdated
                : AppLocalizations.of(context)!.productListedSuccessfully,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.product != null
                ? AppLocalizations.of(context)!.failedToUpdateProduct
                : AppLocalizations.of(context)!.failedToListProduct,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final isLoading = provider.isLoading;
    final productTypes = provider.productTypes;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? AppLocalizations.of(context)!.editProduct : AppLocalizations.of(context)!.addProduct),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : (widget.product != null &&
                            widget.product!.images.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.product!.fullImages[0],
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.tapToAddImage,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.title),
                validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.pleaseEnterTitle : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedProductTypeId,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.productType),
                items: productTypes.map((type) {
                  return DropdownMenuItem(
                    value: type.id,
                    child: Text(type.name),
                  );
                }).toList(),
                onChanged: (val) {
                  final type = productTypes.firstWhere((t) => t.id == val);
                  _onProductTypeChanged(type);
                },
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.description),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.priceCredits,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.quantity),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.unitHint,
                ),
                validator: (v) => v!.isEmpty ? AppLocalizations.of(context)!.pleaseEnterUnit : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        widget.product != null
                            ? AppLocalizations.of(context)!.updateProduct
                            : AppLocalizations.of(context)!.listProduct,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
