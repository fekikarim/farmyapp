import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/land_model.dart';
import '../../providers/land_provider.dart';
import 'dart:ui';

class RentalCheckoutScreen extends StatefulWidget {
  final Land land;

  const RentalCheckoutScreen({super.key, required this.land});

  @override
  State<RentalCheckoutScreen> createState() => _RentalCheckoutScreenState();
}

class _RentalCheckoutScreenState extends State<RentalCheckoutScreen> {
  int _months = 12;
  bool _isLoading = false;
  bool _acceptedTerms = false;
  final double _monthlyRent = 1200.0;
  DateTime _startDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    print('RentalCheckoutScreen: isDark=$isDark'); // Using it to avoid lint

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Checkout',
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPremiumHeader(),
                Text(
                  'Lease Start Date',
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
                  'Rental Duration',
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
                  'Payment Security',
                  style: TextStyle(
                    color: theme.textTheme.titleLarge?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPaymentMethod(),
                const SizedBox(height: 32),
                _buildTotalBreakdown(),
                const SizedBox(height: 32),
                _buildTermsAndConditions(),
                const SizedBox(height: 120), // Spacer for button
              ],
            ),
          ),
          if (_isLoading) _buildProcessingOverlay(),
        ],
      ),
      bottomSheet: _buildBottomActionCard(),
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
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
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
                    child: const Text(
                      'AVAILABLE',
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
                    '${widget.land.gridWidth}x${widget.land.gridHeight} Organic Plot',
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
                    'Starting From',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMMM dd, yyyy').format(_startDate),
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
        children: [3, 6, 12].map((m) {
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
                  '$m Months',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black54),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D21),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.credit_card_rounded, color: Colors.blue),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Visa ending in 4242',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Default Payment Method',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'EDIT',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
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
          _buildRow('Monthly Rent', '1,200 TND'),
          const SizedBox(height: 16),
          _buildRow('Duration', '$_months Months'),
          const SizedBox(height: 16),
          Divider(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Project',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${NumberFormat('#,###').format(_monthlyRent * _months)} TND',
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
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _acceptedTerms,
            activeColor: Colors.green,
            checkColor: Colors.white,
            side: BorderSide(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
            ),
            onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'I agree to the Terms of Service & Privacy Policy',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                'Total Amount',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${NumberFormat('#,###').format(_monthlyRent * _months)} TND',
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
              onPressed: _acceptedTerms ? _handlePayment : null,
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
              child: const Text(
                'PAY NOW',
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
                'Securing Rental...',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Allocating spatial resources',
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
        'payment_status': 'paid',
      });

      if (success && mounted) {
        _showSuccessDialog();
      } else if (mounted) {
        _showErrorSnackBar(
          context.read<LandProvider>().error ??
              'Payment failed, please try again.',
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
        content: Text(message),
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
                'Rental Confirmed!',
                style: TextStyle(
                  color: theme.textTheme.titleLarge?.color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your plot has been secured. You can now start managing your crops.',
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
                    Navigator.of(context).pop(); // Back to Explore
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
                  child: const Text(
                    'GO TO DASHBOARD',
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
