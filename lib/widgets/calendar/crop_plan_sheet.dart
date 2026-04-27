import 'package:flutter/material.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../models/crop_plan_model.dart';
import '../../models/shop_item_model.dart';
import '../../providers/crop_calendar_provider.dart';
import '../../services/crop_calendar_service.dart';
import '../../services/shop_service.dart';
import '../../theme/app_theme.dart';

/// Bottom sheet for creating a new crop rotation plan
class CropPlanSheet extends StatefulWidget {
  final String? initialLandId;
  final DateTime? initialDate;

  const CropPlanSheet({
    super.key,
    this.initialLandId,
    this.initialDate,
  });

  static Future<void> show(BuildContext context, {
    String? initialLandId,
    DateTime? initialDate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CropPlanSheet(
        initialLandId: initialLandId,
        initialDate: initialDate,
      ),
    );
  }

  @override
  State<CropPlanSheet> createState() => _CropPlanSheetState();
}

class _CropPlanSheetState extends State<CropPlanSheet> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  String? _selectedLandId;
  String? _selectedVariantId;
  String? _selectedVariantName;
  String? _selectedCategory;
  DateTime _plantingDate = DateTime.now();
  int? _cycleDays;
  int? _growthDays;
  bool _isPerennial = false;
  
  List<ShopItemType> _availableCrops = [];
  bool _isLoading = true;
  bool _isSaving = false;
  DateTime? _computedHarvestDate;

  @override
  void initState() {
    super.initState();
    _selectedLandId = widget.initialLandId;
    _plantingDate = widget.initialDate ?? DateTime.now();
    _loadAvailableCrops();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableCrops() async {
    setState(() => _isLoading = true);
    
    try {
      final crops = await CropCalendarService.fetchAvailableCrops();
      
      setState(() {
        _availableCrops = crops.map((c) => ShopItemType.fromJson(c)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.failedToLoadCrops}: $e')),
        );
      }
    }
  }

  void _computeHarvestDate() {
    if (_cycleDays != null || _growthDays != null) {
      final days = _growthDays ?? _cycleDays ?? 30;
      setState(() {
        _computedHarvestDate = _plantingDate.add(Duration(days: days));
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _plantingDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryColor,
              surface: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _plantingDate = picked;
      });
      _computeHarvestDate();
    }
  }

  String? _landError;
  String? _cropError;

  Future<void> _savePlan() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState?.validate() != true) return;
    
    // Validate required fields
    setState(() {
      _landError = _selectedLandId == null ? l10n.pleaseSelectLand : null;
      _cropError = _selectedVariantId == null ? l10n.pleaseSelectCrop : null;
    });
    
    if (_selectedLandId == null || _selectedVariantId == null) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_landError ?? _cropError ?? l10n.fillAllRequiredFields),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final plan = CropPlan(
      landId: _selectedLandId!,
      variantId: _selectedVariantId!,
      variantName: _selectedVariantName!,
      assetCategory: _selectedCategory ?? 'vegetation',
      plannedPlantingDate: _plantingDate,
      expectedHarvestDate: _computedHarvestDate,
      cycleDays: _cycleDays,
      growthDays: _growthDays,
      isPerennial: _isPerennial,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    final provider = context.read<CropCalendarProvider>();
    final success = await provider.addCropPlan(plan);

    if (mounted) {
      setState(() => _isSaving = false);
      
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cropPlanCreatedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? l10n.failedToCreatePlan),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<CropCalendarProvider>();
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.event_note,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.newCropPlan,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.schedulePlanting,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Form
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Land Selector
                          _buildSectionTitle(l10n.selectLand),
                          const SizedBox(height: 8),
                          _buildLandDropdown(provider),
                          const SizedBox(height: 24),
                          
                          // Crop Selector
                          _buildSectionTitle(l10n.selectCrop),
                          const SizedBox(height: 8),
                          _buildCropSelector(),
                          const SizedBox(height: 24),
                          
                          // Planting Date
                          _buildSectionTitle(l10n.plantingDate),
                          const SizedBox(height: 8),
                          _buildDateSelector(),
                          const SizedBox(height: 24),
                          
                          // Harvest Preview
                          if (_computedHarvestDate != null) ...[
                            _buildSectionTitle(l10n.expectedHarvest),
                            const SizedBox(height: 8),
                            _buildHarvestPreview(),
                            const SizedBox(height: 24),
                          ],
                          
                          // Notes
                          _buildSectionTitle(l10n.notesOptional),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: l10n.addNotesHint,
                              filled: true,
                              fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _savePlan,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(_isSaving ? l10n.saving : l10n.createPlan),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.secondaryColor,
      ),
    );
  }

  Widget _buildLandDropdown(CropCalendarProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedLandId,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.landscape),
        ),
        hint: Text(l10n.selectALand),
        items: provider.lands.map((land) {
          return DropdownMenuItem(
            value: land.id,
            child: Text(land.name),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedLandId = value;
            _landError = null;
          });
        },
        validator: (value) {
          if (value == null) return l10n.pleaseSelectLand;
          return null;
        },
      ),
    );
  }

  Widget _buildCropSelector() {
    final l10n = AppLocalizations.of(context)!;
    // Show loading state
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.loadingCrops,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    // Show empty state with retry button
    if (_availableCrops.isEmpty || 
        _availableCrops.every((t) => (t.variants ?? []).isEmpty)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.noCropsAvailable,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addCropsFirst,
              style: TextStyle(
                color: Colors.orange.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _loadAvailableCrops,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.reload),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      );
    }

    // Build crop selector chips
    final allVariants = _availableCrops
        .expand((type) => (type.variants ?? []).map((v) => MapEntry(type, v)))
        .toList();

    if (allVariants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.noCropVariantsFound,
                style: const TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allVariants.map((entry) {
        final type = entry.key;
        final variant = entry.value;
        final isSelected = _selectedVariantId == variant.id;
        
        return ChoiceChip(
          avatar: type.iconUrl != null 
              ? Image.network(
                  type.iconUrl!,
                  width: 20,
                  height: 20,
                  errorBuilder: (_, __, ___) => const Icon(Icons.local_florist, size: 18),
                )
              : const Icon(Icons.local_florist, size: 18),
          label: Text('${type.name} - ${variant.variantCode}'),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedVariantId = variant.id;
                _selectedVariantName = '${type.name} (${variant.variantCode})';
                _selectedCategory = type.name.toLowerCase().contains('tree') 
                    ? 'tree' 
                    : 'vegetation';
                _cropError = null;
                
                // Extract attributes
                final attrs = variant.attributes ?? {};
                _growthDays = attrs['growth_days'] != null 
                    ? int.tryParse(attrs['growth_days'].toString())
                    : null;
                _isPerennial = attrs['is_perennial'] == true;
              });
              
              // Load production info
              _loadVariantProduction(variant.id);
            }
          },
          selectedColor: AppTheme.primaryColor,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
        );
      }).toList(),
    );
  }

  Future<void> _loadVariantProduction(String variantId) async {
    // In a real implementation, fetch production info
    // For now, use defaults
    setState(() {
      _cycleDays = _growthDays ?? 30;
    });
    _computeHarvestDate();
  }

  Widget _buildDateSelector() {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.plantingDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.6)
                          : Colors.black.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    '${_plantingDate.day}/${_plantingDate.month}/${_plantingDate.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.4)
                  : Colors.black.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHarvestPreview() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.event_available, color: Colors.green),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.expectedHarvestDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
                Text(
                  '${_computedHarvestDate!.day}/${_computedHarvestDate!.month}/${_computedHarvestDate!.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                if (_cycleDays != null)
                  Text(
                    '${l10n.cycleDaysLabel(_cycleDays.toString())}${_isPerennial ? ' ${l10n.perennialSuffix}' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.withOpacity(0.8),
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
