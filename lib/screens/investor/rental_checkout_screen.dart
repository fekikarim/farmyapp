import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/land_model.dart';
import '../../providers/land_provider.dart';
import '../../providers/wallet_provider.dart';
import '../wallet/payment_methods_screen.dart'; // Added
import 'dart:ui';
import 'package:farmyapp/l10n/app_localizations.dart';

class RentalCheckoutScreen extends StatefulWidget {
  final Land land;

  const RentalCheckoutScreen({super.key, required this.land});

  @override
  State<RentalCheckoutScreen> createState() => _RentalCheckoutScreenState();
}

class _RentalCheckoutScreenState extends State<RentalCheckoutScreen> {
  int _months = 1; // Default to 1 month

  bool _isLoading = false;
  bool _acceptedTerms = false;
  late final double _monthlyRent = widget.land.price;
  DateTime _startDate = DateTime.now();
  PaymentMethod? _selectedPaymentMethod;
  bool _highlightTerms = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch wallet status to get payment methods
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchWalletStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Auto-select logic is now inside _buildPaymentMethodSelector to react to state changes and credits
    final walletProvider = context.watch<WalletProvider>(); // Keep watcher here

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.checkout,
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPremiumHeader(),
                Text(
                  AppLocalizations.of(context)!.leaseStartDate,
                  style: TextStyle(
                    color: theme.textTheme.titleLarge?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStartDateSelector(),
                const SizedBox(height: 32),
                Text(
                  AppLocalizations.of(context)!.rentalDuration,
                  style: TextStyle(
                    color: theme.textTheme.titleLarge?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPeriodSelector(),
                const SizedBox(height: 32),
                Text(
                  AppLocalizations.of(context)!.paymentSecurity,
                  style: TextStyle(
                    color: theme.textTheme.titleLarge?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPaymentMethodSelector(walletProvider), // Modified
                const SizedBox(height: 32),
                _buildTotalBreakdown(),
                const SizedBox(height: 32),
                _buildTermsAndConditions(),
                const SizedBox(height: 32), // Spacer
              ],
            ),
          ),
          if (_isLoading) _buildProcessingOverlay(),
        ],
      ),
      bottomNavigationBar: _buildBottomActionCard(),
    );
  }

  Widget _buildPremiumHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final center =
        widget.land.boundaries != null && widget.land.boundaries!.isNotEmpty
        ? LatLng(
            widget.land.boundaries!
                    .map((p) => p.latitude)
                    .reduce((a, b) => a + b) /
                widget.land.boundaries!.length,
            widget.land.boundaries!
                    .map((p) => p.longitude)
                    .reduce((a, b) => a + b) /
                widget.land.boundaries!.length,
          )
        : const LatLng(36.8065, 10.1815);

    return Container(
      height: 180,
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            IgnorePointer(
              child: FlutterMap(
                options: MapOptions(initialCenter: center, initialZoom: 16.5),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    tileBuilder: (context, tileWidget, tile) {
                      if (!isDark) return tileWidget;
                      return ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          -1,
                          0,
                          0,
                          0,
                          255,
                          0,
                          -1,
                          0,
                          0,
                          255,
                          0,
                          0,
                          -1,
                          0,
                          255,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ]),
                        child: tileWidget,
                      );
                    },
                  ),
                  if (widget.land.boundaries != null)
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: widget.land.boundaries!,
                          color: Colors.green.withOpacity(0.4),
                          borderColor: Colors.green,
                          borderStrokeWidth: 2,
                          isFilled: true,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    theme.cardColor.withOpacity(0.95),
                    theme.cardColor.withOpacity(0.4),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.availableUpper,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.land.name,
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.organicPlotGrid(widget.land.gridWidth.toString(), widget.land.gridHeight.toString()),
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 14,
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

  Widget _buildStartDateSelector() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _selectStartDate(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.startingFrom,
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(_startDate),
                    style: TextStyle(
                      color: theme.textTheme.titleMedium?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.edit_calendar_rounded,
              color: Colors.green,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: Colors.green,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      HapticFeedback.lightImpact();
      setState(() {
        _startDate = picked;
      });
    }
  }

  Widget _buildPeriodSelector() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final options = [1, 3, 6, 12]; // Added 1 month option as requested

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        ),
      ),
      child: Row(
        children: options.map((m) {
          final isSelected = _months == m;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _months = m);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  m == 1 ? AppLocalizations.of(context)!.monthAbbreviation : AppLocalizations.of(context)!.monthsAbbreviation(m.toString()),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black54),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentMethodSelector(WalletProvider walletProvider) {
    // 1. Check if credits are sufficient
    final totalAmount = _monthlyRent * _months;
    final canUseCredits = walletProvider.credits >= totalAmount;

    // Define a "Credits" payment method placeholder
    final creditsMethod = PaymentMethod(
      id: 'WALLET_CREDITS',
      type: 'credits',
      last4: '',
      brand: 'Wallet Credits',
      expiryMonth: '',
      expiryYear: '',
      isDefault: false,
    );

    // Auto-select credits if available and sufficient, AND no other method explicitly selected yet
    if (_selectedPaymentMethod == null) {
      if (canUseCredits) {
        _selectedPaymentMethod = creditsMethod;
      } else if (walletProvider.paymentMethods.isNotEmpty) {
        try {
          _selectedPaymentMethod = walletProvider.paymentMethods.firstWhere(
            (p) => p.isDefault,
          );
        } catch (_) {
          _selectedPaymentMethod = walletProvider.paymentMethods.first;
        }
      }
    }

    final allMethods = [
      if (canUseCredits) creditsMethod,
      ...walletProvider.paymentMethods,
    ];

    // Safety check: Ensure selected method exists in the current list (or is credits which is dynamic)
    if (_selectedPaymentMethod != null) {
      bool exists = false;
      if (_selectedPaymentMethod!.id == 'WALLET_CREDITS') {
        exists = canUseCredits; // Only exists if credits are sufficient
      } else {
        exists = walletProvider.paymentMethods.any(
          (p) => p.id == _selectedPaymentMethod!.id,
        );
      }

      if (!exists) {
        _selectedPaymentMethod = null;
        // Try to re-select something valid
        if (canUseCredits) {
          _selectedPaymentMethod = creditsMethod;
        } else if (walletProvider.paymentMethods.isNotEmpty) {
          _selectedPaymentMethod = walletProvider.paymentMethods.first;
        }
      }
    }

    if (allMethods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D21),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.insufficientCredits(NumberFormat('#,###').format(walletProvider.credits)),
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              icon: Icon(Icons.add_card, color: Colors.green),
              label: Text(
                AppLocalizations.of(context)!.addPaymentMethod,
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () => _handleAddCard(context),
            ),
          ],
        ),
      );
    }

    // New UI: Selected Card Display with "Change" action
    final isCredits = _selectedPaymentMethod?.id == 'WALLET_CREDITS';

    return GestureDetector(
      onTap: () => _showPaymentMethodPicker(context, allMethods, creditsMethod),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D21),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCredits
                ? Colors.amber.withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
            width: isCredits ? 1.5 : 1,
          ),
          boxShadow: isCredits
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isCredits ? Colors.amber : Colors.blue).withOpacity(
                  0.1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCredits
                    ? Icons.account_balance_wallet_rounded
                    : Icons.credit_card_rounded,
                color: isCredits ? Colors.amber : Colors.blue,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCredits
                        ? AppLocalizations.of(context)!.walletCredits
                        : '${_selectedPaymentMethod?.brand.toUpperCase()} •••• ${_selectedPaymentMethod?.last4}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCredits
                        ? AppLocalizations.of(context)!.balanceAmount(NumberFormat('#,###').format(walletProvider.credits))
                        : (_selectedPaymentMethod?.isDefault == true
                              ? AppLocalizations.of(context)!.defaultMethod
                              : AppLocalizations.of(context)!.savedCard),
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppLocalizations.of(context)!.changeAction,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodPicker(
    BuildContext context,
    List<PaymentMethod> methods,
    PaymentMethod creditsMethod, // Pass this to identify credits
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D21),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.selectPaymentMethod,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // "Add New Card" Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context); // Close sheet
                    _handleAddCard(context); // Trigger add card
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.of(context)!.addNewCard,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: methods.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final method = methods[index];
                    final isSelected = method == _selectedPaymentMethod;
                    final isCredit = method.id == 'WALLET_CREDITS';

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedPaymentMethod = method);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isCredit
                                    ? Colors.amber.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1))
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? (isCredit ? Colors.amber : Colors.green)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isCredit
                                  ? Icons.account_balance_wallet_rounded
                                  : Icons.credit_card_rounded,
                              color: isCredit ? Colors.amber : Colors.blue,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isCredit
                                        ? AppLocalizations.of(context)!.walletCredits
                                        : '${method.brand.toUpperCase()} •••• ${method.last4}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (isCredit)
                                    Text(
                                      AppLocalizations.of(context)!.availableInstantPayment,
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: isCredit ? Colors.amber : Colors.green,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalBreakdown() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          _buildRow(
            AppLocalizations.of(context)!.monthlyRent,
            AppLocalizations.of(context)!.amountTND(NumberFormat('#,###').format(_monthlyRent)),
          ),
          const SizedBox(height: 16),
          _buildRow(AppLocalizations.of(context)!.duration, AppLocalizations.of(context)!.nMonths(_months.toString())),
          const SizedBox(height: 16),
          Divider(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.totalProject,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.amountTND(NumberFormat('#,###').format(_monthlyRent * _months)),
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: _highlightTerms
                ? Border.all(color: Colors.redAccent, width: 2)
                : null,
          ),
          child: SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: _acceptedTerms,
              activeColor: Colors.green,
              checkColor: Colors.white,
              side: BorderSide(
                color: _highlightTerms
                    ? Colors.redAccent
                    : (isDark ? Colors.white : Colors.black).withOpacity(0.2),
              ),
              onChanged: (val) {
                setState(() {
                  _acceptedTerms = val ?? false;
                  if (_acceptedTerms) _highlightTerms = false;
                });
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.agreeToTermsAndPrivacy,
            style: TextStyle(
              color: _highlightTerms
                  ? Colors.redAccent
                  : (isDark ? Colors.white54 : Colors.black54),
              fontSize: 13,
              fontWeight: _highlightTerms ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Check if payment method is selected
    final canPay = _acceptedTerms && _selectedPaymentMethod != null;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.totalAmount,
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.amountTND(NumberFormat('#,###').format(_monthlyRent * _months)),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(width: 32),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (!_acceptedTerms) {
                  setState(() => _highlightTerms = true);
                  // Auto-scroll to bottom to show checkbox
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  );

                  Future.delayed(const Duration(milliseconds: 800), () {
                    if (mounted) setState(() => _highlightTerms = false);
                  });
                  return;
                }
                if (_selectedPaymentMethod == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: Colors.white,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.pleaseSelectPaymentMethod,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                _handlePayment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: Colors.green.withOpacity(0.3),
              ),
              child: Text(
                AppLocalizations.of(context)!.payNowUpper,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: (isDark ? Colors.black : Colors.white).withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Colors.green,
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.securingRental,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.allocatingSpatialResources,
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    setState(() => _isLoading = true);

    try {
      final startDate = _startDate;
      final endDate = DateTime(
        startDate.year,
        startDate.month + _months,
        startDate.day,
      );

      final success = await context.read<LandProvider>().rentLand({
        'land_id': widget.land.id,
        'rental_start_date': startDate.toIso8601String(),
        'rental_end_date': endDate.toIso8601String(),
        'monthly_rent': _monthlyRent,
        'payment_due_date': DateTime.now()
            .toIso8601String(), // Due today for immediate lease
        'payment_status': 'paid', // Intention to pay
        'payment_method_id': _selectedPaymentMethod?.id, // Added
      });

      // Wait for loading to finish
      if (mounted) setState(() => _isLoading = false);

      if (success) {
        if (mounted) _showSuccessDialog();
      } else {
        // This block might not be reached if provider throws exception,
        // but if it returns false, we show error.
        if (mounted) {
          _showErrorSnackBar(
            context.read<LandProvider>().error ??
                AppLocalizations.of(context)!.paymentFailedTryAgain,
          );
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
        final errorMsg = e.toString();
        // Check for payment-related errors
        if (errorMsg.contains("PaymentMethod") ||
            errorMsg.contains("payment") ||
            errorMsg.contains("Stripe")) {
          _showPaymentFailureDialog(errorMsg);
        } else {
          _showErrorSnackBar(errorMsg);
        }
      }
    }
  }

  void _showPaymentFailureDialog(String errorMsg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.paymentFailedGeneric,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.paymentIssueHint,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMsg
                          .replaceAll("Exception: ", "")
                          .replaceAll("HttpException: ", ""),
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
              ).then((_) {
                // Refresh wallet when coming back
                context.read<WalletProvider>().fetchWalletStatus();
              });
            },
            child: Text(AppLocalizations.of(context)!.manageCards),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAddCard(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final success = await context.read<WalletProvider>().addCard();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.cardAddedSuccessfully)),
        );
        // Auto-select the new card (logic relies on provider list update)
        // We can assume the last added card is the one we want, or just let the user pick it.
        // But better to find the one that wasn't there before?
        // For simplicity, we just refresh. build() will pick it up or user can select it.

        // Force select if it's the only one or default logic handles it
        final provider = context.read<WalletProvider>();
        if (provider.paymentMethods.isNotEmpty) {
          setState(() {
            // Prefer the one that is default, or just the first one if we can't tell which is new
            // Usually Stripe newly added card becomes default or is just added.
            _selectedPaymentMethod = provider.paymentMethods.firstWhere(
              (p) => p.isDefault,
              orElse: () => provider.paymentMethods.first,
            );
          });
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cancelledOrFailedToAddCard),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) _showErrorSnackBar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
            ), // Assuming network-related error mostly
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 64,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                AppLocalizations.of(context)!.rentalConfirmed,
                style: TextStyle(
                  color: theme.textTheme.titleLarge?.color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.rentalConfirmedDescription,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(
                      context,
                    ).pop(true); // Back to Explore with success result
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.goToDashboardUpper,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
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
