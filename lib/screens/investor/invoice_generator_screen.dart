import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:farmyapp/l10n/app_localizations.dart';
import '../../services/invoice_service.dart';
import '../../services/invoice_preview_service.dart';

class InvoiceGeneratorScreen extends StatefulWidget {
  const InvoiceGeneratorScreen({super.key});

  @override
  State<InvoiceGeneratorScreen> createState() => _InvoiceGeneratorScreenState();
}

class _InvoiceGeneratorScreenState extends State<InvoiceGeneratorScreen>
    with SingleTickerProviderStateMixin {
  // ── Brand colours ────────────────────────────────────────────────────────────
  static const _primary = Color(0xFF90A53E);
  static const _dark = Color(0xFF1A2111);
  static const _accent = Color(0xFFC5D196);
  static const _green = Color(0xFF4ADE80);

  // ── State ────────────────────────────────────────────────────────────────────
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  final _selectedTypes = <String>{
    'land_rental',
    'item_purchase',
    'product_purchase',
  };

  InvoicePreviewData? _preview;
  bool _loadingPreview = false;
  bool _generatingPdf = false;
  String? _previewError;

  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _loadPreview();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _range,
      builder: (ctx, child) {
        final theme = Theme.of(ctx);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: _primary,
              onPrimary: Colors.white,
              surface: theme.colorScheme.surface,
              onSurface: theme.textTheme.bodyLarge?.color ?? Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _primary),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _range = picked);
      _loadPreview();
    }
  }

  Future<void> _loadPreview() async {
    if (_selectedTypes.isEmpty) {
      setState(() => _preview = null);
      return;
    }
    setState(() {
      _loadingPreview = true;
      _previewError = null;
    });
    try {
      final data = await InvoicePreviewService.fetchPreview(
        from: _range.start,
        to: _range.end,
        types: _selectedTypes.toList(),
      );
      if (mounted) setState(() { _preview = data; _loadingPreview = false; });
    } catch (e) {
      if (mounted) setState(() { _previewError = e.toString(); _loadingPreview = false; });
    }
  }

  Future<void> _generatePdf() async {
    if (_selectedTypes.isEmpty) {
      _showSnack(AppLocalizations.of(context)!.selectActivityTypeWarning, isError: true);
      return;
    }
    setState(() => _generatingPdf = true);
    try {
      final bytes = await InvoiceService.generateInvoice(
        from: _range.start,
        to: _range.end,
        types: _selectedTypes.toList(),
      );
      if (!mounted) return;
      // Open native share / print sheet
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (e) {
      if (mounted) _showSnack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? const Color(0xFFF87171) : _primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF1A2111),
                          const Color(0xFF0D1208),
                          const Color(0xFF121A0A)
                        ]
                      : [
                          theme.colorScheme.surface,
                          _primary.withOpacity(0.05),
                          theme.colorScheme.surface,
                        ],
                ),
              ),
            ),
          ),

          // Ambient glow orb top-right
          Positioned(
            top: -60, right: -40,
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Container(
                width: 220, height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    _primary.withOpacity(isDark ? 0.18 + _pulseCtrl.value * 0.06 : 0.08 + _pulseCtrl.value * 0.03),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ),

          SafeArea(
            child: _generatingPdf ? _buildGeneratingOverlay(context, theme, isDark) : _buildContent(context, theme, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildHeader(context, theme, isDark),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel(theme, isDark, l10n.dateRangeUpper.toUpperCase()),
                const SizedBox(height: 8),
                _buildDateRangeCard(context, theme, isDark),
                const SizedBox(height: 24),
                _buildSectionLabel(theme, isDark, l10n.activityTypesUpper.toUpperCase()),
                const SizedBox(height: 10),
                _buildTypeChips(theme, isDark),
                const SizedBox(height: 24),
                _buildSectionLabel(theme, isDark, l10n.previewUpper.toUpperCase()),
                const SizedBox(height: 10),
                _buildPreviewCard(context, theme, isDark),
                const SizedBox(height: 32),
                _buildGenerateButton(theme, isDark),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new, color: theme.iconTheme.color?.withOpacity(0.8), size: 18),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF2D6A4F), Color(0xFF1B4332)]),
              boxShadow: [BoxShadow(color: const Color(0xFF2D6A4F).withOpacity(0.5), blurRadius: 10, offset: const Offset(0,2))],
            ),
            child: const Center(
              child: Icon(Icons.receipt_long_rounded, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.invoiceGenerator.toUpperCase(), style: TextStyle(
                color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w900,
                fontSize: 14, letterSpacing: 1.5,
              )),
              Text(AppLocalizations.of(context)!.blockchainVerifiedPdf, style: TextStyle(
                color: isDark ? _accent.withOpacity(0.7) : theme.textTheme.bodySmall?.color?.withOpacity(0.7), fontSize: 11,
              )),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(ThemeData theme, bool isDark, String label) {
    return Text(label, style: TextStyle(
      color: isDark ? _accent.withOpacity(0.6) : theme.textTheme.bodySmall?.color?.withOpacity(0.8),
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.4,
    ));
  }

  // ── Date range card ───────────────────────────────────────────────────────────
  Widget _buildDateRangeCard(BuildContext context, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: _pickDateRange,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? _primary.withOpacity(0.25) : _primary.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : _primary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent,
              child: Row(
                children: [
                  Expanded(child: _dateBox(theme, isDark, AppLocalizations.of(context)!.fromUpper, _range.start)),
                  Container(width: 1, height: 40, color: isDark ? _primary.withOpacity(0.3) : _primary.withOpacity(0.1)),
                  Expanded(child: _dateBox(theme, isDark, AppLocalizations.of(context)!.toUpper, _range.end)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_primary, Color(0xFF4F7035)]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateBox(ThemeData theme, bool isDark, String label, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: isDark ? _accent.withOpacity(0.6) : theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 9, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(_fmtDate(date), style: TextStyle(
            color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w700, fontSize: 15,
          )),
        ],
      ),
    );
  }

  // ── Type chips ────────────────────────────────────────────────────────────────
  Widget _buildTypeChips(ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final chips = [
      {'key': 'land_rental', 'label': l10n.landRentals, 'color': _green},
      {'key': 'item_purchase', 'label': l10n.assetPurchases, 'color': _primary},
      {'key': 'product_purchase', 'label': l10n.products, 'color': const Color(0xFF60A5FA)},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: chips.map((chip) {
        final key = chip['key'] as String;
        final selected = _selectedTypes.contains(key);
        final color = chip['color'] as Color;

        return GestureDetector(
          onTap: () {
            setState(() {
              if (selected) {
                _selectedTypes.remove(key);
              } else {
                _selectedTypes.add(key);
              }
            });
            _loadPreview();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? color.withOpacity(0.15) : (isDark ? Colors.white.withOpacity(0.04) : theme.colorScheme.surfaceContainerHighest),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? color.withOpacity(0.5) : (isDark ? Colors.white.withOpacity(0.1) : Colors.transparent),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected)
                  Icon(Icons.check_circle_rounded, size: 14, color: color)
                else
                  Icon(Icons.radio_button_unchecked_rounded, size: 14, color: theme.iconTheme.color?.withOpacity(0.3)),
                const SizedBox(width: 6),
                Text(chip['label'] as String, style: TextStyle(
                  color: selected ? color : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                  fontSize: 13,
                )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Preview card ──────────────────────────────────────────────────────────────
  Widget _buildPreviewCard(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? _primary.withOpacity(0.25) : _primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : _primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.transparent,
            child: _loadingPreview
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(color: _primary, strokeWidth: 2),
                      ),
                    ),
                  )
                : _previewError != null
                    ? Row(children: [
                        const Icon(Icons.info_outline, color: Color(0xFFF87171), size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(AppLocalizations.of(context)!.couldNotLoadPreview, style: const TextStyle(color: Color(0xFFF87171)))),
                      ])
                    : _preview == null
                        ? Text(AppLocalizations.of(context)!.selectTypesToSeePreview,
                            style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)))
                        : Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.analytics_outlined, color: _primary, size: 18),
                                  const SizedBox(width: 8),
                                  Text(AppLocalizations.of(context)!.summaryUpper.toUpperCase(), style: TextStyle(
                                    color: isDark ? _accent.withOpacity(0.7) : _primary.withOpacity(0.8),
                                    fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2,
                                  )),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  _statPill(theme, isDark, _preview!.recordCount.toString(), AppLocalizations.of(context)!.records, Icons.link_rounded, _primary),
                                  const SizedBox(width: 12),
                                  _statPill(
                                    theme,
                                    isDark,
                                    '\$${_preview!.totalAmount.toStringAsFixed(2)}',
                                    AppLocalizations.of(context)!.totalUsd,
                                    Icons.attach_money_rounded,
                                    _green,
                                  ),
                                ],
                              ),
                              if (_preview!.countByType.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                ..._preview!.countByType.entries.map((e) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      Text(_typeLabel(e.key), style: TextStyle(
                                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6), fontSize: 11,
                                      )),
                                      const Spacer(),
                                      Text('${e.value} record${e.value != 1 ? 's' : ''}',
                                          style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8), fontSize: 11)),
                                    ],
                                  ),
                                )),
                              ],
                            ],
                          ),
          ),
        ),
      ),
    );
  }

  Widget _statPill(ThemeData theme, bool isDark, String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(
                  color: color, fontWeight: FontWeight.w900, fontSize: 16,
                )),
                Text(label, style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case 'land_rental': return l10n.landRentals;
      case 'item_purchase': return l10n.assetPurchases;
      case 'product_purchase': return l10n.productPurchases;
      default: return type;
    }
  }

  // ── Generate button ───────────────────────────────────────────────────────────
  Widget _buildGenerateButton(ThemeData theme, bool isDark) {
    final canGenerate = _selectedTypes.isNotEmpty &&
        (_preview == null || _preview!.recordCount > 0);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canGenerate ? _generatePdf : null,
        icon: const Icon(Icons.picture_as_pdf_rounded),
        label: Text(
          _preview != null && _preview!.recordCount == 0
              ? AppLocalizations.of(context)!.noRecordsInRange
              : AppLocalizations.of(context)!.generatePdfInvoice,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D6A4F),
          foregroundColor: Colors.white,
          disabledBackgroundColor: isDark ? Colors.white.withOpacity(0.06) : theme.disabledColor.withOpacity(0.1),
          disabledForegroundColor: isDark ? Colors.white30 : theme.disabledColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

  // ── Generating overlay ────────────────────────────────────────────────────────
  Widget _buildGeneratingOverlay(BuildContext context, ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF2D6A4F), Color(0xFF1B4332)]),
                boxShadow: [BoxShadow(
                  color: const Color(0xFF2D6A4F).withOpacity(0.3 + _pulseCtrl.value * 0.4),
                  blurRadius: 40, spreadRadius: 4,
                )],
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(height: 24),
          Text(AppLocalizations.of(context)!.generatingInvoice, style: TextStyle(
            color: theme.textTheme.bodyLarge?.color, fontSize: 16, fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)!.fetchingBlockchainRecords, style: TextStyle(
            color: theme.textTheme.bodySmall?.color, fontSize: 12,
          )),
        ],
      ),
    );
  }
}
