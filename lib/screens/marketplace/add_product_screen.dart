import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import '../../providers/product_provider.dart';
import '../../models/product_type_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/land_provider.dart';
import '../../providers/roi_provider.dart';

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
  String? _selectedLandId;
  String? _selectedLandRentalId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().fetchProductTypes();
      final authProvider = context.read<AuthProvider>();
      final role = authProvider.user?.role;
      if (role == 'farmer') {
        context.read<LandProvider>().fetchMyLands();
      } else if (role == 'investor') {
        context.read<RoiProvider>().fetchDashboardData();
      }
    });

    if (widget.product != null) {
      _titleController.text = widget.product!.title;
      _descriptionController.text = widget.product!.description ?? '';
      _priceController.text = widget.product!.price.toString();
      _quantityController.text = widget.product!.quantity.toString();
      _unitController.text = widget.product!.unit;
      _selectedProductTypeId = widget.product!.productTypeId;
      _selectedLandId = widget.product!.landId;
      _selectedLandRentalId = widget.product!.landRentalId;
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseSelectProductType),
        ),
      );
      return;
    }

    final data = <String, dynamic>{
      'title': _titleController.text,
      'description': _descriptionController.text,
      'price': double.parse(_priceController.text),
      'quantity': double.parse(_quantityController.text),
      'unit': _unitController.text,
      'product_type_id': _selectedProductTypeId,
      'land_id': _selectedLandId ?? '',
      'land_rental_id': _selectedLandRentalId ?? '',
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
        title: Text(
          widget.product != null
              ? AppLocalizations.of(context)!.editProduct
              : AppLocalizations.of(context)!.addProduct,
        ),
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
                      : Column(
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.title,
                ),
                validator: (v) => v!.isEmpty
                    ? AppLocalizations.of(context)!.pleaseEnterTitle
                    : null,
              ),
              const SizedBox(height: 16),
              _buildSelectionTile(
                label: AppLocalizations.of(context)!.productType,
                value: _selectedProductTypeId != null
                    ? productTypes
                          .firstWhere((t) => t.id == _selectedProductTypeId)
                          .name
                    : 'Select Type',
                icon: Icons.category_outlined,
                onTap: () => _showProductTypeSheet(productTypes),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.description,
                ),
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
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.quantity,
                      ),
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
                validator: (v) => v!.isEmpty
                    ? AppLocalizations.of(context)!.pleaseEnterUnit
                    : null,
              ),
              const SizedBox(height: 24),
              _buildProductOriginSection(),
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

  Widget _buildProductOriginSection() {
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.user?.role;

    if (role != 'farmer' && role != 'investor') {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Origin (Optional)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (role == 'farmer')
          _buildFarmerOriginDropdown()
        else if (role == 'investor')
          _buildInvestorOriginDropdown(),
      ],
    );
  }

  Widget _buildFarmerOriginDropdown() {
    final landProvider = context.watch<LandProvider>();

    if (landProvider.isLoading) {
      return const Center(child: LinearProgressIndicator());
    }

    final lands = landProvider.myLands;
    if (lands.isEmpty) {
      return const Text(
        'No owned lands found to link.',
        style: TextStyle(color: Colors.grey),
      );
    }

    return _buildSelectionTile(
      label: 'Owned Land',
      value: _selectedLandId != null
          ? lands.firstWhere((l) => l.id == _selectedLandId).name
          : 'Not Linked',
      icon: Icons.landscape_outlined,
      onTap: () => _showFarmerLandSheet(lands),
    );
  }

  Widget _buildInvestorOriginDropdown() {
    final roiProvider = context.watch<RoiProvider>();

    if (roiProvider.isLoading) {
      return const Center(child: LinearProgressIndicator());
    }

    final rentals = roiProvider.dashboardData?.rentals ?? [];
    if (rentals.isEmpty) {
      return const Text(
        'No rented lands found to link.',
        style: TextStyle(color: Colors.grey),
      );
    }

    return _buildSelectionTile(
      label: 'Rented Land',
      value: _selectedLandRentalId != null
          ? rentals.firstWhere((r) => r.id == _selectedLandRentalId).landName
          : 'Not Linked',
      icon: Icons.real_estate_agent_outlined,
      onTap: () => _showInvestorRentalSheet(rentals),
    );
  }

  Widget _buildSelectionTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  void _showProductTypeSheet(List<ProductType> types) {
    _showModernSelectionSheet(
      title: 'Product Type',
      items: types
          .map(
            (t) => _SelectionItem(
              id: t.id,
              title: t.name,
              icon: Icons.grass_rounded,
            ),
          )
          .toList(),
      selectedId: _selectedProductTypeId,
      onSelected: (id) {
        final type = types.firstWhere((t) => t.id == id);
        _onProductTypeChanged(type);
      },
    );
  }

  void _showFarmerLandSheet(List<dynamic> lands) {
    _showModernSelectionSheet(
      title: 'Owned Land',
      items: [
        _SelectionItem(
          id: null,
          title: 'Not Linked',
          icon: Icons.link_off_rounded,
        ),
        ...lands.map(
          (l) => _SelectionItem(
            id: l.id,
            title: l.name,
            icon: Icons.landscape_rounded,
          ),
        ),
      ],
      selectedId: _selectedLandId,
      onSelected: (id) {
        setState(() {
          _selectedLandId = id;
          _selectedLandRentalId = null;
        });
      },
    );
  }

  void _showInvestorRentalSheet(List<dynamic> rentals) {
    _showModernSelectionSheet(
      title: 'Rented Land',
      items: [
        _SelectionItem(
          id: null,
          title: 'Not Linked',
          icon: Icons.link_off_rounded,
        ),
        ...rentals.map(
          (r) => _SelectionItem(
            id: r.id,
            title: r.landName,
            icon: Icons.real_estate_agent_rounded,
          ),
        ),
      ],
      selectedId: _selectedLandRentalId,
      onSelected: (id) {
        setState(() {
          _selectedLandRentalId = id;
          _selectedLandId = null;
        });
      },
    );
  }

  void _showModernSelectionSheet({
    required String title,
    required List<_SelectionItem> items,
    required String? selectedId,
    required Function(String?) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item.id == selectedId;

                    return InkWell(
                      onTap: () {
                        onSelected(item.id);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : (isDark ? Colors.white38 : Colors.black26),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item.title,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : null,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: theme.colorScheme.primary,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _SelectionItem {
  final String? id;
  final String title;
  final IconData icon;

  _SelectionItem({required this.id, required this.title, required this.icon});
}
