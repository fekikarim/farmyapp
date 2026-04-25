import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/shop_service.dart';
import '../../widgets/profile_preview_sheet.dart';
import 'package:farmyapp/l10n/app_localizations.dart';

class FarmerRentalRequestsScreen extends StatefulWidget {
  const FarmerRentalRequestsScreen({super.key});

  @override
  State<FarmerRentalRequestsScreen> createState() =>
      _FarmerRentalRequestsScreenState();
}

class _FarmerRentalRequestsScreenState
    extends State<FarmerRentalRequestsScreen> {
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String? _error;
  String? _processingId;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final requests = await ShopService.getIncomingItemRequests();
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context)!.failedToLoadRequests;
          _isLoading = false;
        });
      }
    }
  }
  String _translateCategory(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context)!;
    switch (category.toLowerCase()) {
      case 'animal':
        return l10n.animal;
      case 'vegetation':
        return l10n.vegetation;
      case 'tree':
        return l10n.tree;
      case 'structure':
        return l10n.structure;
      case 'machine':
        return l10n.machine;
      default:
        return category.isEmpty ? l10n.itemUpper : category;
    }
  }

  Future<void> _handleApprove(String id) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      // User cancelled taking a photo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.imageProofRequiredToApprove,
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _processingId = id);
    final error = await ShopService.approveItemRequest(id, proofImage: image);
    if (mounted) {
      setState(() => _processingId = null);
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text(AppLocalizations.of(context)!.requestApprovedItemPlaced),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        _loadRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: $error')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showRejectDialog(String id) async {
    final TextEditingController reasonController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.redAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.rejectRequest),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.rejectionReasonPrompt,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: reasonController,
                    maxLines: 3,
                    maxLength: 500,
                    enabled: !isSubmitting,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enterRejectionReason,
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!.pleaseEnterRejectionReason;
                      }
                      if (value.trim().length < 5) {
                        return AppLocalizations.of(context)!.reasonTooShort;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () => Navigator.pop(context, false),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setDialogState(() => isSubmitting = true);
                        final success = await ShopService.rejectItemRequest(
                          id,
                          reasonController.text.trim(),
                        );
                        if (context.mounted) {
                          Navigator.pop(context, success);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context)!.confirmReject,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.requestRejectedRefunded),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      _loadRequests();
    } else if (result == false && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.failedToRejectRequest),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  /// Extracts a display name from email (e.g., "karim.feki" from "karim.feki@gmail.com")
  String _getDisplayNameFromEmail(String email) {
    final parts = email.split('@');
    if (parts.isNotEmpty) {
      return parts[0];
    }
    return AppLocalizations.of(context)!.investor;
  }

  /// Gets the investor's display name with proper fallback
  String _getInvestorDisplayName(Map<String, dynamic> user) {
    final profile = user['profile'];
    if (profile != null &&
        profile['name'] != null &&
        profile['name'].toString().isNotEmpty) {
      return profile['name'];
    }
    final email = user['email'];
    if (email != null && email.toString().isNotEmpty) {
      return _getDisplayNameFromEmail(email);
    }
    return AppLocalizations.of(context)!.unknownInvestor;
  }

  /// Gets the investor's avatar URL with fallback
  String? _getInvestorAvatar(Map<String, dynamic> user) {
    final profile = user['profile'];
    if (profile != null &&
        profile['avatar'] != null &&
        profile['avatar'].toString().isNotEmpty) {
      return profile['avatar'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.itemRequests,
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textTheme.titleLarge?.color),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRequests,
        color: Colors.green,
        child: _buildBody(theme, isDark),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, bool isDark) {
    if (_isLoading) {
      return _buildLoadingState(isDark);
    }

    if (_error != null) {
      return _buildErrorState(theme, isDark);
    }

    if (_requests.isEmpty) {
      return _buildEmptyState(theme, isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _requests.length,
      itemBuilder: (context, index) =>
          _buildRequestCard(_requests[index], theme, isDark),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) => _buildShimmerCard(isDark),
    );
  }

  Widget _buildShimmerCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 180,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadRequests,
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.noPendingRequests,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.noPendingRequestsHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(dynamic req, ThemeData theme, bool isDark) {
    final user = req['user'] ?? {};
    final land = req['land'] ?? {};
    final itemDetails = req['item_details'] ?? {};
    final isProcessing = _processingId == req['id'];

    final investorName = _getInvestorDisplayName(user);
    final avatarUrl = _getInvestorAvatar(user);
    final itemName = itemDetails['name'] ?? AppLocalizations.of(context)!.unknownItem;
    final variantName = itemDetails['variant_name'] ?? '';
    final itemImage = itemDetails['image_url'];
    final landName = land['name'] ?? AppLocalizations.of(context)!.unknownLand;
    final rawPrice = req['price_paid'];
    final pricePaid = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0;
    final assetCategory = req['asset_category'] ?? 'item';

    return AnimatedOpacity(
      opacity: isProcessing ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Investor Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: () {
                      final investorId = user['_id'] ?? user['id'];
                      if (investorId != null) {
                        ProfilePreviewSheet.show(context, investorId);
                      }
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: avatarUrl == null
                            ? LinearGradient(
                                colors: [
                                  Colors.green.shade400,
                                  Colors.green.shade600,
                                ],
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: avatarUrl != null
                          ? ClipOval(
                              child: Image.network(
                                avatarUrl,
                                fit: BoxFit.cover,
                                width: 52,
                                height: 52,
                                errorBuilder: (_, __, ___) =>
                                    _buildDefaultAvatar(investorName),
                              ),
                            )
                          : _buildDefaultAvatar(investorName),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          investorName,
                          style: TextStyle(
                            color: theme.textTheme.titleLarge?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.investor,
                            style: TextStyle(
                              color: Colors.blue.shade400,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Item Info Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.03)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(
                    0.05,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Item Image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildItemImage(itemImage, assetCategory, isDark),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemName,
                          style: TextStyle(
                            color: theme.textTheme.titleLarge?.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (variantName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            variantName,
                            style: TextStyle(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withOpacity(0.5),
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _translateCategory(context, assetCategory.toString()).toUpperCase(),
                            style: TextStyle(
                              color: Colors.orange.shade600,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailChip(
                    context,
                    Icons.landscape_rounded,
                    AppLocalizations.of(context)!.land,
                    landName,
                    Colors.blue,
                    isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailChip(
                    context,
                    Icons.monetization_on_rounded,
                    AppLocalizations.of(context)!.amount,
                    '\$${pricePaid.toStringAsFixed(2)}',
                    Colors.green,
                    isDark,
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isProcessing
                          ? null
                          : () => _showRejectDialog(req['id']),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: BorderSide(
                          color: isProcessing ? Colors.grey : Colors.redAccent,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.rejectUpper,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : () => _handleApprove(req['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.approveUpper,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'I';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  /// Builds the item image with path mapping from database to local assets
  Widget _buildItemImage(String? url, String category, bool isDark) {
    if (url == null || url.isEmpty) {
      return _buildItemPlaceholder(category, isDark);
    }

    // Network images
    if (url.startsWith('http')) {
      return _NetworkItemImage(url: url, category: category);
    }

    // Database path mapping (e.g., '/icons/animals/cow.png' -> 'assets/game_images/icons/animals/cow.png')
    String assetPath = url;
    if (url.startsWith('/')) {
      assetPath = 'assets/game_images$url';
    } else if (!url.startsWith('assets/')) {
      assetPath = 'assets/game_images/$url';
    }

    return _LocalAssetImage(assetPath: assetPath, category: category);
  }

  Widget _buildItemPlaceholder(String category, bool isDark) {
    IconData icon;
    switch (category.toLowerCase()) {
      case 'animal':
        icon = Icons.pets;
        break;
      case 'vegetation':
        icon = Icons.grass;
        break;
      case 'tree':
        icon = Icons.park;
        break;
      case 'structure':
        icon = Icons.home_work;
        break;
      case 'machine':
        icon = Icons.precision_manufacturing;
        break;
      default:
        icon = Icons.inventory_2;
    }
    return Container(
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
      child: Center(
        child: Icon(
          icon,
          size: 28,
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildDetailChip(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A StatefulWidget that handles network image loading with:
/// - Shimmer loading animation
/// - Smooth fade-in transition when loaded
/// - Error handling with retry capability
/// - Category-aware placeholder fallbacks
class _NetworkItemImage extends StatefulWidget {
  final String url;
  final String? category;

  const _NetworkItemImage({required this.url, this.category});

  @override
  State<_NetworkItemImage> createState() => _NetworkItemImageState();
}

class _NetworkItemImageState extends State<_NetworkItemImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isLoading = true;
  bool _hasError = false;
  int _retryCount = 0;
  static const int _maxRetries = 2;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleImageError() {
    if (_retryCount < _maxRetries) {
      setState(() {
        _retryCount++;
        _hasError = false;
        _isLoading = true;
      });
    } else {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.category?.toLowerCase()) {
      case 'animal':
        return Icons.pets_rounded;
      case 'vegetation':
        return Icons.grass_rounded;
      case 'tree':
        return Icons.park_rounded;
      case 'structure':
        return Icons.home_work_rounded;
      case 'machine':
        return Icons.precision_manufacturing_rounded;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getCategoryIcon(), size: 32, color: Colors.white24),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                _retryCount = 0;
                _hasError = false;
                _isLoading = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 10, color: Colors.white38),
                  SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.retry,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        if (_isLoading)
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                    stops: [0.0, _shimmerController.value, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  size: 28,
                  color: Colors.white.withOpacity(0.2),
                ),
              );
            },
          ),
        AnimatedOpacity(
          opacity: _isLoading ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: Image.network(
            _retryCount > 0
                ? '${widget.url}${widget.url.contains('?') ? '&' : '?'}retry=$_retryCount'
                : widget.url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _isLoading) {
                    setState(() => _isLoading = false);
                  }
                });
                return child;
              }
              return const SizedBox.shrink();
            },
            errorBuilder: (_, __, ___) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _handleImageError();
              });
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

/// A StatefulWidget that handles local asset image loading with:
/// - Shimmer loading animation
/// - Smooth fade-in transition when loaded
/// - Error handling with category-aware placeholders
class _LocalAssetImage extends StatefulWidget {
  final String assetPath;
  final String? category;

  const _LocalAssetImage({required this.assetPath, this.category});

  @override
  State<_LocalAssetImage> createState() => _LocalAssetImageState();
}

class _LocalAssetImageState extends State<_LocalAssetImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _loadAsset();
  }

  Future<void> _loadAsset() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon() {
    switch (widget.category?.toLowerCase()) {
      case 'animal':
        return Icons.pets_rounded;
      case 'vegetation':
        return Icons.grass_rounded;
      case 'tree':
        return Icons.park_rounded;
      case 'structure':
        return Icons.home_work_rounded;
      case 'machine':
        return Icons.precision_manufacturing_rounded;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Icon(_getCategoryIcon(), size: 32, color: Colors.white24);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        if (_isLoading)
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.12),
                      Colors.white.withOpacity(0.05),
                    ],
                    stops: [0.0, _shimmerController.value, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  size: 28,
                  color: Colors.white.withOpacity(0.2),
                ),
              );
            },
          ),
        AnimatedOpacity(
          opacity: _isLoading ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Image.asset(
            widget.assetPath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_hasError) {
                  setState(() => _hasError = true);
                }
              });
              return Icon(_getCategoryIcon(), size: 32, color: Colors.white24);
            },
          ),
        ),
      ],
    );
  }
  String _translateCategory(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context)!;
    switch (category.toLowerCase()) {
      case 'animal':
        return l10n.animal;
      case 'vegetation':
        return l10n.vegetation;
      case 'tree':
        return l10n.tree;
      case 'structure':
        return l10n.structure;
      case 'machine':
        return l10n.machine;
      default:
        return category.isEmpty ? l10n.itemUpper : category;
    }
  }
}
